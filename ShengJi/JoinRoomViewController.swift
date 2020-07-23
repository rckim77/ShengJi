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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate.pusher?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appDelegate.pusher?.delegate = nil
    }
    
    @objc
    private func joinButtonTapped() {
        guard let code = codeField.text, !code.isEmpty else {
            let invalidValuesAlert = UIAlertController(title: "Please enter a 4-digit code.", message: nil, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Got it", style: .cancel, handler: nil)
            invalidValuesAlert.addAction(confirmAction)
            present(invalidValuesAlert, animated: true, completion: nil)
            return
        }
        add(loadingVC)
        
        guard let url = URL(string: "https://fast-garden-35127.herokuapp.com/join/presence-\(code)") else {
            return
        }
        joinCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: JoinResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case Subscribers.Completion.failure(_) = completion {
                    self?.loadingVC.remove()
                    self?.displayErrorAlert(for: "presence-\(code)")
                }
            }, receiveValue: { [weak self] response in
                self?.loadingVC.remove()
                let playerLobbbyVC = PlayerLobbyViewController(channelName: response.code, hostUsername: response.host)
                self?.navigationController?.pushViewController(playerLobbbyVC, animated: true)
            })
    }
    
    private func displayErrorAlert(for channelName: String) {
        let presencePrefix = "presence-"
        let startingIndex = channelName.index(channelName.startIndex, offsetBy: presencePrefix.count)
        let roomCode = channelName.suffix(from: startingIndex)
        let alertVC = UIAlertController(title: "Oops, that didn't work. 😦", message: "Unable to connect to room \(roomCode).", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Got it", style: .cancel, handler: nil)
        alertVC.addAction(confirmAction)
        present(alertVC, animated: true, completion: nil)
    }
}

extension JoinRoomViewController: PusherDelegate {
    func failedToSubscribeToChannel(name: String, response: URLResponse?, data: String?, error: NSError?) {
        loadingVC.remove()
        displayErrorAlert(for: name)
    }
}
