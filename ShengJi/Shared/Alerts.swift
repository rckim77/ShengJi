//
//  Alerts.swift
//  ShengJi
//
//  Created by Ray Kim on 8/6/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit

extension UIViewController {

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
    
    func showErrorAlert(message: String, completion: @escaping(() -> Void)) {
        let alertVC = UIAlertController(title: "Oops, that didn't work. 😦", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Got it", style: .cancel, handler: { _ in
            completion()
        })
        alertVC.addAction(confirmAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func showScoreAlert(_ scoreResponse: ScoreResponse, hostPair: [String], otherPair: [String]) {
        guard hostPair.count == 2 && otherPair.count == 2 else {
            return
        }
        let hostPairString = "\(hostPair[0]) and \(hostPair[1]): \(scoreResponse.hostPairLevel)"
        let otherPairString = "\(otherPair[0]) and \(otherPair[1]): \(scoreResponse.otherPairLevel)"
        let alertVC = UIAlertController(title: "Current Score", message: "\(hostPairString)\n\(otherPairString)", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Got it", style: .cancel, handler: nil)
        alertVC.addAction(confirmAction)
        present(alertVC, animated: true, completion: nil)
    }
}
