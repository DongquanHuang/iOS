//
//  PlatformNode.swift
//  UberJump
//
//  Created by Peter Huang on 8/21/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import UIKit
import SpriteKit

enum PlatformType: Int {
    case Normal = 0
    case Break
}

class PlatformNode: GameObjectNode {
    
    struct PhysicsConstants {
        static let BoostVectorY: CGFloat = 250.0
    }
    
    var platformType: PlatformType!
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        if playerIsFalling(player) {
            boostPlayer(player)
            
            if breakablePlatform() {
                self.removeFromParent()
            }
        }
        
        return false
    }
    
    private func playerIsFalling(player: SKNode) -> Bool {
        return player.physicsBody?.velocity.dy < 0
    }
    
    private func breakablePlatform() -> Bool {
        return platformType == .Break
    }
    
    private func boostPlayer(player: SKNode) {
        player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: PhysicsConstants.BoostVectorY)
    }
}
