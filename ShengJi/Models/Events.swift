//
//  Events.swift
//  ShengJi
//
//  Created by Ray Kim on 7/26/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import Foundation

struct PairEvent: Codable {
    let pair: [String] // contains two usernames
}

struct DrawEvent: Codable {
    let nextPlayerToDraw: String // username
}
