//
//  Extensions.swift
//  ShengJi
//
//  Created by Ray Kim on 7/20/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit

extension UIViewController {
    func add(_ childVC: UIViewController) {
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}

extension UIView {
    func addRoundedCorners(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
}
