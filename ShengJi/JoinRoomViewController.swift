//
//  JoinRoomViewController.swift
//  ShengJi
//
//  Created by Ray Kim on 7/19/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

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
        
    }
}
