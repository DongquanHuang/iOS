//
//  GameObjectNode.swift
//  UberJump
//
//  Created by Peter Huang on 8/20/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import UIKit
import SpriteKit

struct CollisionCategoryBitmask {
    static let Player: UInt32 = 0x00
    static let Star: UInt32 = 0x01
    static let Platform: UInt32 = 0x02
}

class GameObjectNode: SKNode {
    
    var gameScoreSystem = GameScoreSystem()
    
    func collisionWithPlayer(player: SKNode) -> Bool {
        return false
    }
    
    func removeNodeIfFarAwayFromPlayer(playerY: CGFloat) {
        if farAwayEnoughFromPlayer(playerY) {
            self.removeFromParent()
        }
    }
    
    private func farAwayEnoughFromPlayer(playerY: CGFloat) -> Bool {
        return playerY > self.position.y + 300.0
    }
    
}
