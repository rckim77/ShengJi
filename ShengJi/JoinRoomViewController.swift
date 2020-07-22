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
        textField.placeholder = "Enter code"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var usernameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter username"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        button.setTitleColor(.darkGray, for: .normal)
        button.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var joinCancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
     
        view.addSubview(codeField)
        view.addSubview(usernameField)
        view.addSubview(joinButton)
        
        codeField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-80)
        }
        
        usernameField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(codeField.snp.bottom).offset(16)
        }
        
        joinButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(usernameField.snp.bottom).offset(32)
        }
    }
    
    @objc
    private func joinButtonTapped() {
        let loadingVC = LoadingViewController()
        add(loadingVC)
        
        guard let code = codeField.text,
            let username = usernameField.text,
            let url = URL(string: "https://fast-garden-35127.herokuapp.com/join") else {
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let json: [String: Any] = ["code": code, "username": username]
        let joinJSON = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
        urlRequest.httpBody = joinJSON
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        joinCancellable = URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                if httpResponse.statusCode == 404 {
                    throw NetworkError.notFound
                }
                return data
            }
            .decode(type: String.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] response in
                loadingVC.remove()
                guard let gameVC = GameViewController(roomCode: code) else {
                    return
                }
                self?.navigationController?.pushViewController(gameVC, animated: true)
            }, receiveValue: { _ in })
    }
}
