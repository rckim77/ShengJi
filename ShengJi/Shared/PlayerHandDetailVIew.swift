//
//  PlayerHandDetailVIew.swift
//  ShengJi
//
//  Created by Ray Kim on 8/1/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

final class PlayerHandDetailView: UIView {
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = -20
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCard(_ card: String) {
        let label = UILabel()
        label.text = card
        label.font = .systemFont(ofSize: 80)
        stackView.addArrangedSubview(label)
    }
}
