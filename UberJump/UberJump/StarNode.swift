//
//  StarNode.swift
//  UberJump
//
//  Created by Peter Huang on 8/20/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import UIKit
import SpriteKit

class StarNode: GameObjectNode {
    
    struct PhysicsConstants {
        static let BoostVectorY: CGFloat = 400.0
    }
   
    override func collisionWithPlayer(player: SKNode) -> Bool {
        boostPlayer(player)
        self.removeFromParent()
        
        return true
    }
    
    private func boostPlayer(player: SKNode) {
        player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: PhysicsConstants.BoostVectorY)
    }
    
}
