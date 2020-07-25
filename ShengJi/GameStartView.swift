//
//  GameStartView.swift
//  ShengJi
//
//  Created by Ray Kim on 7/24/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

protocol GameStartViewDelegate: class {
    func gameStartViewDidTapLeaveButton()
}

final class GameStartView: UIView {
    
    private lazy var leaveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Leave", for: .normal)
        button.addTarget(self, action: #selector(leaveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private weak var delegate: GameStartViewDelegate?
    
    init(delegate: GameStartViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        
        addSubview(leaveButton)
        
        leaveButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(24)
            make.leading.equalToSuperview().inset(24)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func leaveButtonTapped() {
        self.delegate?.gameStartViewDidTapLeaveButton()
    }
}
