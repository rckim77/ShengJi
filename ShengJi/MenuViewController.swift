//
//  MenuViewController.swift
//  ShengJi
//
//  Created by Ray Kim on 7/17/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

final class MenuViewController: UIViewController {
    
    private lazy var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join game", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        button.setTitleColor(.darkGray, for: .normal)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create a game", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        button.setTitleColor(.darkGray, for: .normal)
        return button
    }()
    
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
    }
}
