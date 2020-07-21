//
//  MenuViewController.swift
//  ShengJi
//
//  Created by Ray Kim on 7/17/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit
import Combine
import PusherSwift

final class MenuViewController: UIViewController, PusherDelegate {
    
    private lazy var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join room", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        button.setTitleColor(.darkGray, for: .normal)
        button.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create a room", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        button.setTitleColor(.darkGray, for: .normal)
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var codeCancellable: AnyCancellable?
    private let pusher: Pusher
    
    init?(keys: APIKeys?) {
        // Pusher setup
        guard let pusherKey = keys?.pusher else {
            return nil
        }
        let options = PusherClientOptions(host: .cluster("us2"))
        pusher = Pusher(key: pusherKey, options: options)
        super.init(nibName: nil, bundle: nil)
        
        pusher.delegate = self
        let channel = pusher.subscribe("my-channel")
        let _ = channel.bind(eventName: "my-event", eventCallback: { event in
            if let data = event.data {
                print(data)
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(joinButton)
        view.addSubview(createButton)
        
        joinButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-24)
        }
        
        createButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(joinButton.snp.bottom).offset(8)
        }
        
        pusher.connect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        pusher.disconnect()
    }
    
    @objc
    private func joinButtonTapped() {
        let joinRoomVC = JoinRoomViewController()
        navigationController?.pushViewController(joinRoomVC, animated: true)
    }
    
    @objc
    private func createButtonTapped() {
        let loadingVC = LoadingViewController()
        add(loadingVC)
        
        guard let url = URL(string: "https://fast-garden-35127.herokuapp.com/create_code") else {
            return
        }
        codeCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Int.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                loadingVC.remove()
            }, receiveValue: { [weak self] code in
//                let lobbyVC = LobbyViewController(roomCode: "\(code)")
//                self?.navigationController?.pushViewController(lobbyVC, animated: true)
            })
    }
    
    /// Used for Pusher debugging
    func debugLog(message: String) {
        print("Pusher debug: \(message)")
    }
}
