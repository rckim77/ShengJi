//
//  Extensions.swift
//  ShengJi
//
//  Created by Ray Kim on 7/20/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import PusherSwift

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

extension UIView {
    func addRoundedCorners(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
}

extension UIButton {
    func addRoundedBorder(radius: CGFloat = 8, width: CGFloat = 1, color: UIColor) {
        addRoundedCorners(radius: radius)
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
}

extension Array {
    /// Cannot be shifted backwards more than the length of the array.
    /// If the array was, say, [1, 2, 3] and you shifted backwards by
    /// 1, the output would be [2, 3, 1].
    func shiftedBackwards(_ places: Int) -> [Element] {
        guard places < self.count else {
            return []
        }
        let shiftedArray = places == 0 ? self : Array(self[places..<count] + self[0..<places])
        return shiftedArray
    }
}

extension String {
    /// Given an input such as "2C", this function will output "2♣".
    func convertedCardAbbreviationToUnicode() -> String {
        guard self.count == 2 else {
            return ""
        }
        
        let suitIndex = self.index(after: self.startIndex)
        let suit = self[suitIndex]
        let digit = self[self.startIndex]
        
        let unicodeSuit: String?
        switch suit {
        case "S":
            unicodeSuit = "♠"
        case "H":
            unicodeSuit = "♥"
        case "D":
            unicodeSuit = "♦"
        case "C":
            unicodeSuit = "♣"
        default:
            unicodeSuit = nil
        }

        if let unicodeSuit = unicodeSuit {
            return "\(digit)\(unicodeSuit)"
        } else {
            return ""
        }
    }
    
    /// Returns true if self is higher rank than input otherRank following
    /// standard playing card rules (Ace down to 2). Note this is an extension
    /// on String because of "10".
    func isHigherValueThan(_ otherRank: String) -> Bool {
        switch (self, otherRank) {
        case ("A", _):
            return true
        case ("K", let val):
            return val != "A"
        case ("Q", let val):
            return val != "A" && val != "K"
        case ("J", let val):
            return val != "A" && val != "K" && val != "Q"
        case (_, "A"), (_, "K"), (_, "Q"), (_, "J"):
            return false
        default: // self is a number char (e.g., "10")
            return Int(self) ?? 0 > Int(otherRank) ?? 1
        }
    }
    
    /// Returns true if self is of a higher suit than input otherSuit
    /// following standard playing card rules (Spades > Hearts > Clubs > Diamonds).
    func isHigherSuitThan(_ otherSuit: String) -> Bool {
        switch (self, otherSuit) {
        case ("S", _):
            return true
        case ("H", let suit):
            return suit != "S"
        case ("C", let suit):
            return suit != "S" && suit != "H"
        case ("D", let suit):
            return suit != "S" && suit != "H" && suit != "C"
        default:
            return false
        }
    }
}

extension CharacterSet {
    func containsUnicodeScalars(of character: Character) -> Bool {
        character.unicodeScalars.allSatisfy(contains(_:))
    }
}

extension PusherPresenceChannel {
    func bindPairEvent(_ completion: @escaping((PairEvent) -> Void)) {
        bind(eventName: "pair", eventCallback: { pairEventData in
            guard let data = pairEventData.data?.data(using: .utf8),
                let pairEvent = try? JSONDecoder().decode(PairEvent.self, from: data) else {
                    return
            }
            completion(pairEvent)
        })
    }
    
    func bindDrawEvent(_ completion: @escaping((DrawEvent) -> Void)) {
        bind(eventName: "draw", eventCallback: { drawEventData in
            guard let data = drawEventData.data?.data(using: .utf8),
                let drawEvent = try? JSONDecoder().decode(DrawEvent.self, from: data) else {
                    return
            }
            completion(drawEvent)
        })
    }
    
    func bindDealerExchangedEvent(_ completion: @escaping(() -> Void)) {
        bind(eventName: "dealerExchanged", eventCallback: { _ in
            completion()
        })
    }
}
