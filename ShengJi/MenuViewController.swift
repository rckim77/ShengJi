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

final class MenuViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "升级"
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .largeTitle)
        return label
    }()
    
    private lazy var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join room", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        button.setTitleColor(.systemGray, for: .normal)
        button.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create a room", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        button.setTitleColor(.systemGray, for: .normal)
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var versionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            label.text = "Version \(appVersion) (\(bundleVersion))"
        }
        return label
    }()
    
    private var codeCancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(joinButton)
        view.addSubview(createButton)
        view.addSubview(versionLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
        }
        
        joinButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-24)
        }
        
        createButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(joinButton.snp.bottom).offset(8)
        }
        
        versionLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(4)
            make.centerX.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc
    private func joinButtonTapped() {
        let joinRoomVC = JoinRoomViewController()
        navigationController?.pushViewController(joinRoomVC, animated: true)
    }
    
    @objc
    private func createButtonTapped() {
        guard let url = URL(string: "https://fast-garden-35127.herokuapp.com/random_code") else {
            return
        }

        let loadingVC = LoadingViewController()
        add(loadingVC)
        
        codeCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Int.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                loadingVC.remove()
            }, receiveValue: { [weak self] code in
                let gameVC = HostGameViewController(channelName: "presence-\(code)")
                self?.navigationController?.pushViewController(gameVC, animated: true)
            })
    }
}
