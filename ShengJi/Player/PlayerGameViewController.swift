//
//  PlayerGameViewController.swift
//  ShengJi
//
//  Created by Ray Kim on 7/21/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit
import PusherSwift
import Combine

final class PlayerGameViewController: UIViewController {
    
    private var lobbyView: PlayerLobbyView?
    private var gameView: GameView?
    private let channelName: String
    private let hostUsername: String
    private var channel: PusherPresenceChannel?
    private var pairs: [[String]] = []
    
    // MARK: - Helper vars

    private var username: String? {
        channel?.myId
    }
    
    // MARK: - AnyCancellables
    
    private var drawCancellable: AnyCancellable?
    private var dealerExchangeCancellable: AnyCancellable?
    private var getScoreCancellable: AnyCancellable?
    private var playCancellable: AnyCancellable?
    
    // MARK: - Init methods
    
    init(channelName: String, hostUsername: String) {
        self.channelName = channelName
        self.hostUsername = hostUsername
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground

        setupPusher()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        appDelegate.pusher?.delegate = nil
        appDelegate.pusher?.unsubscribe(channelName)
    }
    
    private func setupPusher() {
        appDelegate.pusher?.delegate = self
        channel = appDelegate.pusher?.subscribeToPresenceChannel(channelName: channelName, onMemberAdded: { _ in }, onMemberRemoved: { [weak self] member in
            if member.userId == self?.hostUsername {
                self?.showHostLeftAlert { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            } else if self?.lobbyView?.isHidden == true {
                self?.showPlayerLeftAlert()
            }
        })
        
        channel?.bind(eventName: "pusher:subscription_succeeded", callback: { [weak self] _ in
            guard let strongSelf = self, let playerUsername = strongSelf.username, strongSelf.lobbyView?.superview == nil else {
                return
            }
            
            strongSelf.lobbyView = PlayerLobbyView(channelName: strongSelf.channelName,
                                                   playerUsername: playerUsername,
                                                   hostUsername: strongSelf.hostUsername,
                                                   delegate: strongSelf)
            guard let lobbyView = strongSelf.lobbyView else {
                return
            }
            strongSelf.view.addSubview(lobbyView)
            lobbyView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        })
        
        channel?.bind(eventName: "start", eventCallback: { [weak self] startEventData in
            guard let data = startEventData.data?.data(using: .utf8),
                let startEvent = try? JSONDecoder().decode(StartResponse.self, from: data) else {
                    return
            }

            self?.lobbyView?.isHidden = true
            self?.startGame(playerTurnOrder: startEvent.playerTurnOrder)
        })
        
        channel?.bindPairEvent { [weak self] pairEvent in
            self?.pairs.append(pairEvent.pair)
            self?.lobbyView?.pair(pairEvent.pair)
        }
        
        channel?.bindDrawEvent { [weak self] drawEvent in
            self?.gameView?.updateOnDraw(drawEvent)
        }
        
        channel?.bindDealerExchangedEvent { [weak self] in
            self?.gameView?.updateForDealerExchanged()
        }
        
        channel?.bindPlayEvent({ [weak self] playEvent in
            self?.gameView?.updateOnPlay(playEvent)
        })
    }
    
    private func startGame(playerTurnOrder: [String]) {
        guard let username = username else {
            return
        }

        gameView = GameView(as: .player, hostUsername: hostUsername, username: username, playerTurnOrder: playerTurnOrder, delegate: self)
        guard let gameView = gameView else {
            return
        }
        view.addSubview(gameView)
        gameView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension PlayerGameViewController: PusherDelegate {
    /// Used for Pusher debugging
    func debugLog(message: String) {
        print("Pusher debug: \(message)")
    }
    
    func changedConnectionState(from old: ConnectionState, to new: ConnectionState) {
        if new == .disconnected {
            showDisconnectedAlert { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension PlayerGameViewController: PlayerLobbyViewDelegate {
    func playerLobbyViewDidTapLeave() {
        showLeaveWarningAlert(as: .player)
    }
}

extension PlayerGameViewController: GameViewDelegate {
    func gameViewDidTapLeaveButton() { // for host only
    }
    
    func gameViewDidTapScoreButton() {
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
                guard let username = self?.username else {
                    return
                }
                self?.showScoreAlert(scoreResponse, currentPlayer: username)
            })
    }
    
    func gameViewDidTapDrawButton() {
        guard let username = username,
            let url = URL(string: "https://fast-garden-35127.herokuapp.com/draw/\(channelName)/\(username)") else {
            return
        }

        drawCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap({ data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw APIError.genericError
                }
                return data
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case Subscribers.Completion.failure(_) = completion {
                    self?.showErrorAlert(message: "Could not draw. Try again.", completion: {})
                }
            }, receiveValue: { _ in })
    }
    
    func gameViewDealerFinishedExchanging() {
        guard let leaderTeam = gameView?.leaderTeam,
            let url = URL(string: "https://fast-garden-35127.herokuapp.com/finish_exchanging/\(channelName)/\(leaderTeam.dealer)/\(leaderTeam.leader)") else {
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
                self?.gameView?.hideExchangeView()
            })
    }
    
    func gameViewUser(_ username: String, didPlay card: String) {
        guard let url = URL(string: "https://fast-garden-35127.herokuapp.com/play/\(channelName)/\(username)/\(card)") else {
            return
        }
        playCancellable = URLSession.shared.dataTaskPublisher(for: url)
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
            }, receiveValue: { _ in })
    }
    
    func gameViewUserDidTryToPlayInvalidCard() {
        showInvalidTurnAlert()
    }
}
