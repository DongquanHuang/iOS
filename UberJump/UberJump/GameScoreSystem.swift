//
//  GameScoreSystem.swift
//  UberJump
//
//  Created by Peter Huang on 8/24/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import UIKit

class GameScoreSystem: NSObject {
    var gameState = GameState.sharedInstance
    
    func awardScore(score: Int) {
        gameState.score += score
    }
    
    func awardStar(stars: Int) {
        gameState.stars += stars
    }
}
