//
//  LoadingViewController.swift
//  ShengJi
//
//  Created by Ray Kim on 7/20/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

final class LoadingViewController: UIViewController {
    
    private lazy var loadingSpinner: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        indicatorView.addRoundedCorners(radius: 8)
        indicatorView.color = .white
        return indicatorView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loadingSpinner)
        
        loadingSpinner.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.size.equalTo(54)
        }
        
        loadingSpinner.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        loadingSpinner.stopAnimating()
    }
}
