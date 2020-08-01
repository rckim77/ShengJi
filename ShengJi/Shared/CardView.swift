//
//  CardView.swift
//  ShengJi
//
//  Created by Ray Kim on 8/1/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

final class CardView: UIView {

    private lazy var cardLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 118)
        return label
    }()
    
    init(text: String) {
        super.init(frame: .zero)

        backgroundColor = .systemGroupedBackground
        addSubview(cardLabel)
        
        cardLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cardLabel.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
