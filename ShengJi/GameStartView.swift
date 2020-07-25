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
        button.setTitle("End game", for: .normal)
        button.addTarget(self, action: #selector(leaveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var drawDeckLabel: UILabel = {
        let label = UILabel()
        label.text = "🂠"
        label.font = .systemFont(ofSize: 100)
        return label
    }()
    
    private weak var delegate: GameStartViewDelegate?
    
    init(delegate: GameStartViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        
        addSubview(leaveButton)
        addSubview(drawDeckLabel)
        
        leaveButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).inset(16)
            make.leading.equalToSuperview().inset(16)
        }
        
        drawDeckLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
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
