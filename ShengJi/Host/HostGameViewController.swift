//
//  HostGameViewController.swift
//  ShengJi
//
//  Created by Ray Kim on 7/19/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit
import Combine
import PusherSwift

final class HostGameViewController: UIViewController {
    
    private var lobbyView: HostLobbyView?
    private var gameStartView: GameStartView?
    /// Note: this does not include the 'presence-' prefix
    private var roomCode: String {
        channelName.presenceStripped()
    }
    private let channelName: String
    private var hostUsername: String?
    private var channel: PusherPresenceChannel?
    private var pairs: [[String]] = []
    private let loadingVC = LoadingViewController()
    
    // MARK: - Helper vars

    private var hostPair: [String]? {
        guard let hostUsername = hostUsername, pairs.count == 2 else {
            return nil
        }
        return pairs.first(where: { $0.contains(hostUsername) })
    }
    private var otherPair: [String]? {
        guard let hostUsername = hostUsername, pairs.count == 2 else {
            return nil
        }
        return pairs.first(where: { !$0.contains(hostUsername) })
    }
    
    // MARK: - AnyCancellable methods
    
    private var startCancellable: AnyCancellable?
    private var pairCancellable: AnyCancellable?
    private var drawCancellable: AnyCancellable?
    private var dealerExchangeCancellable: AnyCancellable?
    private var getScoreCancellable: AnyCancellable?
    
    // MARK: - Init methods
    
    init(channelName: String) {
        self.channelName = channelName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: true)
        view.backgroundColor = .systemBackground
        
        setupPusher()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        appDelegate.pusher?.unsubscribe(channelName)
        appDelegate.pusher?.delegate = nil
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Setup methods
    
    private func setupPusher() {
        appDelegate.pusher?.delegate = self
        channel = appDelegate.pusher?.subscribeToPresenceChannel(channelName: channelName, onMemberAdded: { [weak self] member in
            self?.lobbyView?.addUsername(member.userId)
        }, onMemberRemoved: { [weak self] member in
            if self?.lobbyView?.isHidden == true { // proxy for game has started
                self?.showPlayerLeftAlert()
            } else {
                self?.lobbyView?.removeUsername(member.userId)
            }
        })
        
        channel?.bindPairEvent { [weak self] pairEvent in
            self?.pairs.append(pairEvent.pair)
            self?.lobbyView?.pair(pairEvent.pair)
        }
        
        channel?.bindDrawEvent { [weak self] drawEvent in
            self?.gameStartView?.update(drawEvent)
        }
        
        channel?.bindDealerExchangedEvent { [weak self] in
            self?.gameStartView?.updateForDealerExchanged()
        }
    }
    
    private func setupLobby(username: String) {
        lobbyView = HostLobbyView(roomCode: roomCode, username: username, delegate: self)
        guard let lobbyView = lobbyView else {
            return
        }
        view.addSubview(lobbyView)
        lobbyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        lobbyView.clearUsernames()
    }
    
    private func startGame(playerTurnOrder: [String]) {
        guard let hostUsername = hostUsername else {
            return
        }
        
        gameStartView = GameStartView(as: .host, hostUsername: hostUsername, username: hostUsername, playerTurnOrder: playerTurnOrder, delegate: self)
        guard let gameStartView = gameStartView else {
            return
        }
        view.addSubview(gameStartView)
        gameStartView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func pair(_ username: String, with otherUsername: String) {
        guard let url = URL(string: "https://fast-garden-35127.herokuapp.com/pair/\(channelName)/\(username)/\(otherUsername)") else {
            return
        }
        pairCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap({ data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw APIError.genericError
                }
                return data
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case Subscribers.Completion.failure(_) = completion {
                    self?.showErrorAlert(message: "Could not pair those players. Please try another pair.", completion: {})
                }
            }, receiveValue: { _ in })
    }
}

extension HostGameViewController: PusherDelegate {
    func subscribedToChannel(name: String) {
        guard let username = channel?.myId else {
            return
        }
        hostUsername = username
        setupLobby(username: username)
    }
    
    func failedToSubscribeToChannel(name: String, response: URLResponse?, data: String?, error: NSError?) {
        let presencePrefix = "presence-"
        let startingIndex = name.index(name.startIndex, offsetBy: presencePrefix.count)
        let roomCode = name.suffix(from: startingIndex)
        let alertVC = UIAlertController(title: "Oops, that didn't work. 😦", message: "Unable to connect to room \(roomCode).", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Got it", style: .cancel, handler: nil)
        alertVC.addAction(confirmAction)
        present(alertVC, animated: true, completion: nil)
    }
}

extension HostGameViewController: HostLobbyViewDelegate {
    func didDebugTap() {
        let debugVC = DebugViewController(delegate: self)
        present(debugVC, animated: true, completion: nil)
    }
    
    func didTapPairButton() {
        let currentlyUnpairedPlayers = lobbyView?.currentlyUnpairedPlayers.joined(separator: ", ") ?? ""
        let currentlyUnpairedPlayersMessage = "Available players to pair:\n\(currentlyUnpairedPlayers)"
        let pairAlert = UIAlertController(title: "Who would you like to pair?",
                                          message: currentlyUnpairedPlayersMessage,
                                          preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        pairAlert.addAction(cancelAction)
        let firstPredictedText = lobbyView?.currentlyUnpairedPlayers.count == 2 ? lobbyView?.currentlyUnpairedPlayers[0] : hostUsername
        pairAlert.addTextField { textField in
            textField.placeholder = "Enter a username"
            textField.text = firstPredictedText
        }
        let secondPredictedText = lobbyView?.currentlyUnpairedPlayers.count == 2 ? lobbyView?.currentlyUnpairedPlayers[1] : nil
        pairAlert.addTextField { textField in
            textField.placeholder = "Enter a username"
            textField.text = secondPredictedText
        }
        let pairAction = UIAlertAction(title: "Pair", style: .default) { _ in
            guard let firstUsername = pairAlert.textFields?.first?.text,
                let secondUsername = pairAlert.textFields?[1].text,
                !firstUsername.isEmpty && !secondUsername.isEmpty else {
                    // neither field can be empty
                    return
            }
            self.pair(firstUsername, with: secondUsername)
        }
        pairAlert.addAction(pairAction)
        present(pairAlert, animated: true, completion: nil)
    }
    
    func didTapAutoPairButton() {
        guard let currentlyUnpairedPlayers = lobbyView?.currentlyUnpairedPlayers, currentlyUnpairedPlayers.count > 1 else {
            return
        }
        pair(currentlyUnpairedPlayers[0], with: currentlyUnpairedPlayers[1])
    }
    
    func didTapStartButton() {
        guard let channelName = channel?.name,
            let url = URL(string: "https://fast-garden-35127.herokuapp.com/start/\(channelName)") else {
            return
        }
        
        add(loadingVC)
        
        startCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap({ data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw APIError.genericError
                }
                return data
            })
            .decode(type: StartResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.loadingVC.remove()
                if case Subscribers.Completion.failure(_) = completion {
                    self?.showErrorAlert(message: "Please check your pairs are correct.", completion: {})
                }
            }, receiveValue: { [weak self] startResponse in
                self?.lobbyView?.isHidden = true
                self?.startGame(playerTurnOrder: startResponse.playerTurnOrder)
            })
    }
    
    func didTapLeaveButton() {
        showLeaveWarningAlert(as: .host)
    }
}

extension HostGameViewController: DebugViewControllerDelegate {
    func debugViewControllerDidAddPlayer() {
        
    }
}

extension HostGameViewController: GameStartViewDelegate {
    func gameStartViewDidTapLeaveButton() {
        showLeaveWarningAlert(as: .host)
    }
    
    func gameStartViewDidTapScoreButton() {
        guard let url = URL(string: "https://fast-garden-35127.herokuapp.com/score/\(channelName)") else {
            return
        }
        
        getScoreCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: ScoreResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case Subscribers.Completion.failure(_) = completion {
                    self?.showErrorAlert(message: "Try again.", completion: {})
                }
            }, receiveValue: { [weak self] scoreResponse in
                guard let strongSelf = self, let hostPair = strongSelf.hostPair, let otherPair = strongSelf.otherPair else {
                    return
                }
                strongSelf.showScoreAlert(scoreResponse, hostPair: hostPair, otherPair: otherPair)
            })
    }
    
    func gameStartViewDidTapDrawButton() {
        guard let username = hostUsername,
            let url = URL(string: "https://fast-garden-35127.herokuapp.com/draw/\(channelName)/\(username)") else {
            return
        }
        drawCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw APIError.genericError
                }
                return data
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case Subscribers.Completion.failure(_) = completion {
                    self?.showErrorAlert(message: "Could not draw. Try again.", completion: {})
                }
            }, receiveValue: { _ in })
    }
    
    func gameStartViewDealerFinishedExchanging() {
        guard let url = URL(string: "https://fast-garden-35127.herokuapp.com/finish_exchanging/\(channelName)") else {
            return
        }
        dealerExchangeCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw APIError.genericError
                }
                return data
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case Subscribers.Completion.failure(_) = completion {
                    self?.showErrorAlert(message: "Try again.", completion: {})
                }
            }, receiveValue: { [weak self] _ in
                self?.gameStartView?.hideExchangeView()
            })
    }
}
