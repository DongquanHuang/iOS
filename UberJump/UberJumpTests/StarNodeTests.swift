//
//  StarNodeTests.swift
//  UberJump
//
//  Created by Peter Huang on 8/20/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import UIKit
import XCTest
import SpriteKit

class StarNodeTests: XCTestCase {
    
    var parentNode = SKNode()
    var star = StarNode()
    var player = SKNode()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        player.physicsBody = SKPhysicsBody(circleOfRadius: 10.0)
        player.physicsBody?.dynamic = true
        star.position = CGPoint(x: 100, y: 100)
        parentNode.addChild(star)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCollisionWithPlayerReturnsTrueForStarNode() {
        XCTAssertTrue(star.collisionWithPlayer(player) == true)
    }

    func testStarNodeWillBeRemovedFromParentIfCollideWithPlayer() {
        star.collisionWithPlayer(player)
        XCTAssertTrue(star.parent == nil)
    }
    
    func testCollideWithStarNodeWillBoostPlayer() {
        star.collisionWithPlayer(player)
        XCTAssertTrue(player.physicsBody?.velocity == CGVector(dx: player.physicsBody!.velocity.dx, dy: 400.0))
    }

}
