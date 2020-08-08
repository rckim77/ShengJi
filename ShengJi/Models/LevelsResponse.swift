//
//  LevelsResponse.swift
//  ShengJi
//
//  Created by Ray Kim on 8/6/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import Foundation

struct LevelsResponse: Codable {
    let hostPairLevel: String
    let otherPairLevel: String
    let hostPair: [String]
    let otherPair: [String]
}
