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

extension Array where Element == String {

    func sumPoints() -> Int {
        var points = 0
        
        for card in self {
            let rank = card.prefix(card.count == 3 ? 2 : 1)
            if rank == "5" {
                points += 5
            } else if rank == "10" || rank == "K" {
                points += 10
            }
        }
        
        return points
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
    func isHigherRankValueThan(_ otherRank: String) -> Bool {
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
    
    /// First, you must play a card in the turn start card's suit if hand contains cards in that suit.
    /// Second, if hand doesn't contain any cards in that suit, then you can play anything.
    /// The trump suit is treated specially since it includes level cards and jokers which don't
    /// have a suit.
    func isValidForTurn(hand: [String], levelTrump: String, turnStartCard: String) -> Bool {
        guard hand.contains(self) else {
            return false
        }
        
        let turnSuit = turnStartCard.suffix(1)
        
        if turnStartCard.isTrump(levelTrump: levelTrump) {
            if hand.contains(where: { $0.isTrump(levelTrump: levelTrump) }) {
                return self.isTrump(levelTrump: levelTrump) // self must be trump
            } else {
                return true // can play anything
            }
        } else if hand.contains(where: { $0.contains(turnSuit) }) {
            // self must be in turn suit AND cannot contain level (despite it having the same literal suit)
            return self.contains(turnSuit) && !self.isTrump(levelTrump: levelTrump)
        } else {
            return true // can play anything
        }
    }
    
    func isTrump(levelTrump: String) -> Bool {
        let trumpSuit = levelTrump.suffix(1)
        let level = String(levelTrump.prefix(levelTrump.count == 2 ? 1 : 2))
        let currentSuit = self.suffix(1)
        return currentSuit == "J" || currentSuit == trumpSuit || self.contains(level)
    }
    
    /// Removes "presence-" prefix.
    func presenceStripped() -> String {
        let presencePrefix = "presence-"
        let startingIndex = self.index(self.startIndex, offsetBy: presencePrefix.count)
        return String(self.suffix(from: startingIndex))
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
    
    func bindPlayEvent(_ completion: @escaping((PlayEvent) -> Void)) {
        bind(eventName: "play", eventCallback: { playEventData in
            guard let data = playEventData.data?.data(using: .utf8),
                let playEvent = try? JSONDecoder().decode(PlayEvent.self, from: data) else {
                    return
            }
            completion(playEvent)
        })
    }
}
