//
//  CardArrayExtension.swift
//  ShengJi
//
//  Created by Ray Kim on 8/5/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import Foundation

extension Array where Element == String {
    /// Sorts an array of card abbreviations following sheng ji rules for one deck, four players.
    /// Broadly, there are two tiers of cards–trump and non-trump. Trump cards are ranked in the
    /// following descending order: jokers (red then black), dominant rank cards (trump suit then
    /// the non-trump cards), then normal trump suit cards (Ace to 2 excluding dominant rank).
    /// Each non-trump suit is treated equally. Within each suit, order is simply Ace down to
    /// 2, excluding the dominant rank.
    mutating func sortBy(levelTrump: String) {
        let level = String(levelTrump.prefix(levelTrump.count == 2 ? 1 : 2))
        let trumpSuit = String(levelTrump.suffix(1))

        self.sort { card, otherCard -> Bool in // return true if card should come before otherCard (ascending)
            let cardRank = String(card.prefix(card.count == 2 ? 1 : 2))
            let cardSuit = String(card.suffix(1))
            let otherCardRank = String(otherCard.prefix(otherCard.count == 2 ? 1 : 2))
            let otherCardSuit = String(otherCard.suffix(1))
            
            // trump-specific
            let cardIsJoker = cardSuit == "J"
            let otherCardIsJoker = otherCardSuit == "J"
            let cardIsTrump = card.contains(trumpSuit) || card.contains(level) || cardIsJoker
            let otherCardIsTrump = otherCard.contains(trumpSuit) || otherCard.contains(level) || otherCardIsJoker
            
            if cardIsTrump && !otherCardIsTrump {
                return true
            } else if !cardIsTrump && otherCardIsTrump {
                return false
            } else if cardIsTrump && otherCardIsTrump {
                let cardIsLevel = card.contains(level)
                let otherCardIsLevel = otherCard.contains(level)
                
                if cardIsJoker && !otherCardIsJoker {
                    return true
                } else if !cardIsJoker && otherCardIsJoker {
                    return false
                } else if cardIsJoker && otherCardIsJoker {
                    return cardRank == "R" // red > black
                }  else if cardIsLevel && !otherCardIsLevel {
                    return true
                } else if !cardIsLevel && otherCardIsLevel {
                    return false
                } else if cardIsLevel && otherCardIsLevel { // trump level card > non-trump level cards
                    return (cardRank == level && otherCardRank != level) || (cardIsLevel && !otherCardIsLevel)
                }
                
                return cardRank.isHigherRankValueThan(otherCardRank)
            } else if cardSuit == otherCardSuit {
                return cardRank.isHigherRankValueThan(otherCardRank)
            } else { // two different suits, both non-trump
                return cardSuit.isHigherSuitThan(otherCardSuit)
            }
        }
    }
    
    /// The winning card is normally the highest value card within the turn start card's
    /// suit. However, if that player did not have any cards within that suit, then they
    /// can play any card. If they play a trump card, then they'll be compared to any other
    /// trump cards played. In that case, the highest value trump card wins.
    func findHighestValue(levelTrump: String, turnStartCard: String) -> String {
        if self.contains(where: { $0.isTrump(levelTrump: levelTrump )}) { // highest trump wins
            var sortedCards = self
            sortedCards.sortBy(levelTrump: levelTrump)
            return sortedCards[0]
        } else { // highest card in turn start card suit wins
            let turnStartSuit = String(turnStartCard.suffix(1))
            let turnStartSuitCards = self.filter({ $0.contains(turnStartSuit) })
            let sortedSuitCards = turnStartSuitCards.sorted(by: { (first, second) in
                let firstRank = String(first.prefix(first.count == 3 ? 2 : 1))
                let secondRank = String(second.prefix(first.count == 3 ? 2 : 1))
                return firstRank.isHigherRankValueThan(secondRank)
            })
            print("sorted suit cards: \(sortedSuitCards)")
            return sortedSuitCards[0]
        }
    }
}
