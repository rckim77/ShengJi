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
        textField.backgroundColor = .systemGray6
        textField.textAlignment = .center
        return textField
    }()
    
    private lazy var usernameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter username"
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
    
    private var joinCancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        view.backgroundColor = .systemBackground
        view.addSubview(codeField)
        view.addSubview(usernameField)
        view.addSubview(joinButton)
        
        codeField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-90)
            make.width.equalTo(usernameField.snp.width)
            make.height.equalTo(48)
        }
        
        usernameField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(codeField.snp.bottom).offset(16)
            make.height.equalTo(48)
        }
        
        joinButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(usernameField.snp.bottom).offset(28)
        }
    }
    
    @objc
    private func joinButtonTapped() {
        guard let code = codeField.text,
            let username = usernameField.text,
            let url = URL(string: "https://fast-garden-35127.herokuapp.com/join"),
            !code.isEmpty && !username.isEmpty else {
                let invalidValuesAlert = UIAlertController(title: "Please enter a valid code and username.", message: nil, preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "Got it", style: .cancel, handler: nil)
                invalidValuesAlert.addAction(confirmAction)
            present(invalidValuesAlert, animated: true, completion: nil)
            return
        }
        
        let loadingVC = LoadingViewController()
        add(loadingVC)

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
            .decode(type: JoinResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                loadingVC.remove()
                if case Subscribers.Completion.failure(_) = completion {
                    let errorAlert = UIAlertController(title: "Oops, that didn't work. 😦", message: "Try confirming the code is valid and the username you chose is unique.", preferredStyle: .alert)
                        let confirmAction = UIAlertAction(title: "Got it", style: .cancel, handler: nil)
                        errorAlert.addAction(confirmAction)
                    self?.present(errorAlert, animated: true, completion: nil)
                }
            }, receiveValue: { [weak self] joinResponse in
                guard let gameVC = GameViewController(roomCode: joinResponse.code) else {
                    let errorAlert = UIAlertController(title: "Oops, that didn't work. 😦", message: "Looks like there's a backend issue.", preferredStyle: .alert)
                        let confirmAction = UIAlertAction(title: "Got it", style: .cancel, handler: nil)
                        errorAlert.addAction(confirmAction)
                    self?.present(errorAlert, animated: true, completion: nil)
                    return
                }
                self?.navigationController?.pushViewController(gameVC, animated: true)
            })
    }
}
