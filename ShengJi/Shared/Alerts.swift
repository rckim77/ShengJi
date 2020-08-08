//
//  Alerts.swift
//  ShengJi
//
//  Created by Ray Kim on 8/6/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

extension UIViewController {
    
    func showHostLeftAlert(completion: @escaping(() -> Void)) {
        let hostLeftAlert = UIAlertController(title: "The host has left the room.", message: "Please try a new room.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Got it", style: .default) { _ in
            completion()
        }
        hostLeftAlert.addAction(confirmAction)
        present(hostLeftAlert, animated: true, completion: nil)
    }
    
    func showDisconnectedAlert(completion: @escaping(() -> Void)) {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredView = UIVisualEffectView(effect: blurEffect)
        blurredView.frame = view.bounds
        view.addSubview(blurredView)
        
        let disconnectedAlert = UIAlertController(title: "Uh oh, you've been disconnected. 😦", message: "Please try a new room.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Got it", style: .default) { _ in
            blurredView.removeFromSuperview()
            completion()
        }
        disconnectedAlert.addAction(confirmAction)
        present(disconnectedAlert, animated: true, completion: nil)
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
    
    func showErrorAlert(message: String, completion: @escaping(() -> Void)) {
        let alertVC = UIAlertController(title: "Oops, that didn't work. 😦", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Got it", style: .cancel, handler: { _ in
            completion()
        })
        alertVC.addAction(confirmAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func showScoreAlert(_ scoreResponse: ScoreResponse, currentPlayer: String) {
        guard scoreResponse.hostPair.count == 2 && scoreResponse.otherPair.count == 2 else {
            return
        }
        
        let hostPairUsernameFirst = currentPlayer == scoreResponse.hostPair[0] ? "You" : scoreResponse.hostPair[0]
        let hostPairUsernameSecond = currentPlayer == scoreResponse.hostPair[1] ? "you" : scoreResponse.hostPair[1]
        let hostPairString = "\(hostPairUsernameFirst) and \(hostPairUsernameSecond): \(scoreResponse.hostPairLevel)"
        
        let otherPairUsernameFirst = currentPlayer == scoreResponse.otherPair[0] ? "You" : scoreResponse.otherPair[0]
        let otherPairUsernameSecond = currentPlayer == scoreResponse.otherPair[1] ? "you" : scoreResponse.otherPair[1]
        let otherPairString = "\(otherPairUsernameFirst) and \(otherPairUsernameSecond): \(scoreResponse.otherPairLevel)"
        
        let alertVC = UIAlertController(title: "Current Score", message: "\(hostPairString)\n\(otherPairString)", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Got it", style: .cancel, handler: nil)
        alertVC.addAction(confirmAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func showInvalidTurnAlert() {
        let alertVC = UIAlertController(title: "You can't play that card right now. 😦",
                                        message: "if you have any cards left in the suit that was first played, you must play a card in that suit.",
                                        preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Got it", style: .cancel, handler: nil)
        alertVC.addAction(confirmAction)
        present(alertVC, animated: true, completion: nil)
    }
}
