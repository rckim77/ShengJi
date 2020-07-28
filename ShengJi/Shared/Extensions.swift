//
//  Extensions.swift
//  ShengJi
//
//  Created by Ray Kim on 7/20/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit

extension UIViewController {

    var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }

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
    
    func showLeaveWarningAlert(as participant: ParticipantType) {
        let message: String
        switch participant {
        case .host:
            message = "If you leave, all currently joined players will be kicked out."
        case .player:
            message = "If you leave, you will be disconnected from the room."
        }
        
        let warningAlert = UIAlertController(title: "Are you sure?", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Leave", style: .destructive) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        warningAlert.addAction(confirmAction)
        warningAlert.addAction(cancelAction)
        
        present(warningAlert, animated: true, completion: nil)
    }
    
    func showPlayerLeftAlert() {
        let playerLeftAlert = UIAlertController(title: "Uh oh, a player left 😦", message: "Unfortunately, the game is now over.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Got it", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        
        playerLeftAlert.addAction(confirmAction)
        present(playerLeftAlert, animated: true, completion: nil)
    }
}

extension UIView {
    func addRoundedCorners(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
}
