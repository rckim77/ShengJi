//
//  Events.swift
//  ShengJi
//
//  Created by Ray Kim on 7/26/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import Foundation

struct PairEvent: Codable {
    /// Always returns exactly two usernames
    let pair: [String]
}

struct DrawEvent: Codable {
    /// Returns the username of the next player to draw
    let nextPlayerToDraw: String
    /// Returns index of the player that just drew. Nil on initial draw event.
    let drawnPlayerIndex: Int?
    let playerHands: [[String]]
    let cardsRemaining: [String]
    /// The initial draw event will return a nil value. All subsequent draws must return a value.
    let drawnCard: String?
}
