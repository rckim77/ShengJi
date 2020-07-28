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
    private let roomCode: String
    private var hostUsername: String?
    private var channel: PusherPresenceChannel?
    
    // MARK: - AnyCancellable methods
    
    private var startCancellable: AnyCancellable?
    private var pairCancellable: AnyCancellable?
    
    // MARK: - Init methods
    
    init(roomCode: String) {
        self.roomCode = roomCode
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

        appDelegate.pusher?.unsubscribe("presence-\(roomCode)")
        appDelegate.pusher?.delegate = nil
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Setup methods
    
    private func setupPusher() {
        appDelegate.pusher?.delegate = self
        channel = appDelegate.pusher?.subscribeToPresenceChannel(channelName: "presence-\(roomCode)", onMemberAdded: { [weak self] member in
            self?.lobbyView?.addUsername(member.userId)
        }, onMemberRemoved: { [weak self] member in
            if self?.lobbyView?.isHidden == true { // proxy for game has started
                self?.showPlayerLeftAlert()
            } else {
                self?.lobbyView?.removeUsername(member.userId)
            }
        })
        
        channel?.bind(eventName: "pair", eventCallback: { [weak self] pairEventData in
            guard let data = pairEventData.data?.data(using: .utf8),
                let pairEvent = try? JSONDecoder().decode(PairEvent.self, from: data) else {
                    return
            }
            self?.lobbyView?.pair(pairEvent.pair)
        })
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
    
    private func startGame() {
        guard let pairs = lobbyView?.pairs, let hostUsername = hostUsername else {
            return
        }
        
        gameStartView = GameStartView(as: .host, hostUsername: hostUsername, username: hostUsername, pairs: pairs, delegate: self)
        guard let gameStartView = gameStartView else {
            return
        }
        view.addSubview(gameStartView)
        gameStartView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func pair(_ username: String, with otherUsername: String) {
        guard let url = URL(string: "https://fast-garden-35127.herokuapp.com/pair/presence-\(roomCode)/\(username)/\(otherUsername)") else {
            return
        }
        pairCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                // todo: display error alert if pairing failed
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
        let pairAlert = UIAlertController(title: "Who would you like to pair?", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        pairAlert.addAction(cancelAction)
        pairAlert.addTextField { textField in
            textField.placeholder = "Enter a username"
            textField.text = self.hostUsername
        }
        pairAlert.addTextField { textField in
            textField.placeholder = "Enter a username"
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
    
    func didTapStartButton() {
        guard let channelName = channel?.name,
            let url = URL(string: "https://fast-garden-35127.herokuapp.com/start/\(channelName)") else {
            return
        }
        
        startCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.lobbyView?.isHidden = true
                self?.startGame()
            }, receiveValue: { _ in })
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
}
