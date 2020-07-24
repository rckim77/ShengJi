//
//  LobbyViewController.swift
//  ShengJi
//
//  Created by Ray Kim on 7/19/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit
import Combine
import PusherSwift

final class HostLobbyViewController: UIViewController {
    
    private lazy var roomCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var roomCodeTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .systemGray
        textView.addRoundedCorners(radius: 8)
        textView.font = .preferredFont(forTextStyle: .title1)
        return textView
    }()
    
    private lazy var usersJoinedLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.text = "Users joined:"
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var leaveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Leave room", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        button.addTarget(self, action: #selector(leaveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Waiting for players...", for: .disabled)
        button.setTitle("Start game", for: .normal)
        button.setTitleColor(.systemGray, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private let roomCode: String // Note: this does not include the 'presence-' prefix
    private var channel: PusherPresenceChannel?
    private var otherMembers: [PusherPresenceChannelMember] = [] {
        didSet {
            var text = "Players currently joined:"
            if let hostUsername = channel?.myId {
                text += "\n \(hostUsername) (me)"
            }
            for member in otherMembers {
                text += "\n \(member.userId)"
            }
            usersJoinedLabel.text = text
            startButton.isEnabled = otherMembers.count == 3
        }
    }
    private var startCancellable: AnyCancellable?
    
    init(roomCode: String) {
        self.roomCode = roomCode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: true)
        view.backgroundColor = .systemBackground
        view.addSubview(roomCodeLabel)
        view.addSubview(roomCodeTextView)
        view.addSubview(usersJoinedLabel)
        view.addSubview(startButton)
        view.addSubview(leaveButton)
        
        roomCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        roomCodeTextView.snp.makeConstraints { make in
            make.top.equalTo(roomCodeLabel.snp.bottom).offset(16)
            make.centerX.equalTo(roomCodeLabel.snp.centerX)
        }
        
        usersJoinedLabel.snp.makeConstraints { make in
            make.top.equalTo(roomCodeTextView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        startButton.snp.makeConstraints { make in
            make.bottom.equalTo(leaveButton.snp.top).inset(0)
            make.centerX.equalToSuperview()
        }
        
        leaveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
            make.centerX.equalToSuperview()
        }
        
        setupPusher()
        roomCodeLabel.text = "You are now the host. Have your friends join by sending them the code below."
        roomCodeTextView.text = roomCode
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        appDelegate.pusher?.unsubscribe("presence-\(roomCode)")
        appDelegate.pusher?.delegate = nil
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupPusher() {
        appDelegate.pusher?.delegate = self
        channel = appDelegate.pusher?.subscribeToPresenceChannel(channelName: "presence-\(roomCode)", onMemberAdded: { [weak self] member in
            self?.otherMembers.append(member)
        }, onMemberRemoved: { [weak self] member in
            self?.otherMembers.removeAll(where: { $0.userId == member.userId })
        })
    }
    
    @objc
    private func startButtonTapped() {
        guard let channelName = channel?.name,
            let url = URL(string: "https://fast-garden-35127.herokuapp.com/start/\(channelName)") else {
            return
        }

        let loadingVC = LoadingViewController()
        add(loadingVC)
        
        startCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                loadingVC.remove()
            }, receiveValue: { _ in
                print("started game and notified other users")
            })
    }
    
    @objc
    private func leaveButtonTapped() {
        let warningAlert = UIAlertController(title: "Are you sure?", message: "If you leave, all joined players will be kicked out.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Leave", style: .destructive) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        warningAlert.addAction(confirmAction)
        warningAlert.addAction(cancelAction)
        present(warningAlert, animated: true, completion: nil)
    }
}

extension HostLobbyViewController: PusherDelegate {
    /// Used for Pusher debugging
    func debugLog(message: String) {
        print(message)
    }
    
    func subscribedToChannel(name: String) {
        otherMembers = []
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
