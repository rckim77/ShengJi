//
//  JoinRoomViewController.swift
//  ShengJi
//
//  Created by Ray Kim on 7/19/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit
import Combine
import PusherSwift

final class JoinRoomViewController: UIViewController {
    
    private lazy var codeField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter code (e.g., 1234)"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemGray6
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private lazy var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        button.setTitleColor(.systemGray, for: .normal)
        button.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let loadingVC = LoadingViewController()
    private var joinCancellable: AnyCancellable?
    private var channel: PusherPresenceChannel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        view.backgroundColor = .systemBackground
        view.addSubview(codeField)
        view.addSubview(joinButton)
        
        codeField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-90)
            make.height.equalTo(48)
        }
        
        joinButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(codeField.snp.bottom).offset(28)
        }
        
        codeField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate.pusher?.delegate = self
        codeField.text = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appDelegate.pusher?.delegate = nil
    }
    
    @objc
    private func joinButtonTapped() {
        guard let code = codeField.text, !code.isEmpty else {
            displayEmptyTextFieldAlert()
            return
        }
        
        guard let url = URL(string: "https://fast-garden-35127.herokuapp.com/join/presence-\(code)") else {
            return
        }
        
        add(loadingVC)

        joinCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: JoinResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.loadingVC.remove()
                if case Subscribers.Completion.failure(_) = completion {
                    self?.displayErrorAlert(for: "presence-\(code)")
                }
            }, receiveValue: { [weak self] response in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.bindChannelOnSubscriptionSuccess(channelName: "presence-\(code)", hostUsername: response.host)
            })
    }
    
    /// We do a test subscription to see if the user is allowed to join (e.g., cannot join if there's already 4 people).
    /// If they are, then we navigate to the next screen and they'll re-subscribe. Otherwise, we remove the temporary
    /// subscription.
    private func bindChannelOnSubscriptionSuccess(channelName: String, hostUsername: String) {
        channel = appDelegate.pusher?.subscribeToPresenceChannel(channelName: channelName)

        channel?.bind(eventName: "pusher:subscription_succeeded", callback: { [weak self] _ in
            if let members = self?.channel?.members, members.count > 4 {
                self?.displayFullAlert(for: channelName)
            } else {
                self?.appDelegate.pusher?.unsubscribe(channelName)
                self?.channel?.unbindAll()
                let playerLobbbyVC = PlayerGameViewController(channelName: channelName, hostUsername: hostUsername)
                self?.navigationController?.pushViewController(playerLobbbyVC, animated: true)
            }
        })
    }
    
    private func displayEmptyTextFieldAlert() {
        let invalidValuesAlert = UIAlertController(title: "Please enter a 4-digit code.", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Got it", style: .cancel, handler: nil)
        invalidValuesAlert.addAction(confirmAction)
        present(invalidValuesAlert, animated: true, completion: nil)
    }
    
    private func displayFullAlert(for channelName: String) {
        let presencePrefix = "presence-"
        let startingIndex = channelName.index(channelName.startIndex, offsetBy: presencePrefix.count)
        let roomCode = channelName.suffix(from: startingIndex)
        let message = "Room \(roomCode) looks like it's already full. Try another room code."
        showErrorAlert(message: message) { [weak self] in
            self?.appDelegate.pusher?.unsubscribe(channelName)
            self?.channel?.unbindAll()
        }
    }
    
    private func displayErrorAlert(for channelName: String) {
        let presencePrefix = "presence-"
        let startingIndex = channelName.index(channelName.startIndex, offsetBy: presencePrefix.count)
        let roomCode = channelName.suffix(from: startingIndex)
        let message = "We could not connect you to room \(roomCode). Try another code."
        showErrorAlert(message: message, completion: {})
    }
}

extension JoinRoomViewController: PusherDelegate {
    func failedToSubscribeToChannel(name: String, response: URLResponse?, data: String?, error: NSError?) {
        loadingVC.remove()
        displayErrorAlert(for: name)
    }
}
