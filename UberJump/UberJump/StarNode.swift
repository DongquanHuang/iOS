//
//  StarNode.swift
//  UberJump
//
//  Created by Peter Huang on 8/20/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import UIKit
import SpriteKit

enum StarType: Int {
    case Normal = 0
    case Special
}

class StarNode: GameObjectNode {
    
    struct PhysicsConstants {
        static let BoostVectorY: CGFloat = 400.0
    }
    
    var starType: StarType!
    let starSound = SKAction.playSoundFileNamed("StarPing.wav", waitForCompletion: false)
   
    override func collisionWithPlayer(player: SKNode) -> Bool {
        boostPlayer(player)
        // Below code not covered by unit test
        runAction(starSound, completion: { self.removeFromParent() })
        
        return true
    }
    
    private func boostPlayer(player: SKNode) {
        player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: PhysicsConstants.BoostVectorY)
    }
    
}
