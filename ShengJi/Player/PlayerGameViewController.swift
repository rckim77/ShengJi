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
    private var gameStartView: GameStartView?
    private let channelName: String
    private var channel: PusherPresenceChannel?
    private let hostUsername: String
    private var pairs: [[String]] = []
    private var username: String? {
        channel?.myId
    }
    
    // MARK: - AnyCancellables
    
    private var drawCancellable: AnyCancellable?
    
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
                let hostLeftAlert = UIAlertController(title: "The host has left the room.", message: "Please try a new room.", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "Got it", style: .default) { _ in
                    self?.navigationController?.popViewController(animated: true)
                }
                hostLeftAlert.addAction(confirmAction)
                self?.present(hostLeftAlert, animated: true, completion: nil)
            } else if self?.lobbyView?.isHidden == true {
                self?.showPlayerLeftAlert()
            }
        })
        
        channel?.bind(eventName: "pusher:subscription_succeeded", callback: { [weak self] _ in
            guard let strongSelf = self, let playerUsername = strongSelf.username else {
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
        
        channel?.bind(eventName: "start", callback: { [weak self] _ in
            self?.lobbyView?.isHidden = true
            self?.startGame()
        })
        
        channel?.bind(eventName: "pair", eventCallback: { [weak self] pairEventData in
            guard let data = pairEventData.data?.data(using: .utf8),
                let pairEvent = try? JSONDecoder().decode(PairEvent.self, from: data) else {
                    return
            }
            self?.pairs.append(pairEvent.pair)
            self?.lobbyView?.pair(pairEvent.pair)
        })
    }
    
    private func startGame() {
        guard let username = username, pairs.count == 2 else {
            return
        }
//        var mockPairs = pairs
//        mockPairs.append(["usernameMock1", "usernameMock2"])
        gameStartView = GameStartView(as: .player, hostUsername: hostUsername, username: username, pairs: pairs, delegate: self)
        guard let gameStartView = gameStartView else {
            return
        }
        view.addSubview(gameStartView)
        gameStartView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension PlayerGameViewController: PusherDelegate {
    /// Used for Pusher debugging
    func debugLog(message: String) {
        print("Pusher debug: \(message)")
    }
}

extension PlayerGameViewController: PlayerLobbyViewDelegate {
    func playerLobbyViewDidTapLeave() {
        showLeaveWarningAlert(as: .player)
    }
}

extension PlayerGameViewController: GameStartViewDelegate {
    func gameStartViewDidTapLeaveButton() { // for host only
    }
    
    func gameStartViewDidTapDrawButton() {
        guard let username = username,
            let url = URL(string: "https://fast-garden-35127.herokuapp.com/draw/\(channelName)/\(username)") else {
            return
        }
//        drawCancellable = URLSession.shared.dataTaskPublisher(for: url)
    }
}
