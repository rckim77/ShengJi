//
//  DebugViewController.swift
//  ShengJi
//
//  Created by Ray Kim on 7/25/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

protocol DebugViewControllerDelegate: class {
    func debugViewControllerDidAddPlayer()
}

final class DebugViewController: UIViewController {
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .close)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var addPlayerButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title2)
        button.backgroundColor = .secondarySystemBackground
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        button.addRoundedCorners(radius: 8)
        button.setTitle("Add player", for: .normal)
        button.addTarget(self, action: #selector(addPlayerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private weak var delegate: DebugViewControllerDelegate?
    
    init(delegate: DebugViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.6)
        view.addSubview(closeButton)
        view.addSubview(addPlayerButton)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaInsets.top).offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
        
        addPlayerButton.snp.makeConstraints { make in
            make.top.equalTo(closeButton).inset(48)
            make.centerX.equalToSuperview()
            make.height.equalTo(48)
        }
    }
    
    @objc
    private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func addPlayerButtonTapped() {
        
    }
}
