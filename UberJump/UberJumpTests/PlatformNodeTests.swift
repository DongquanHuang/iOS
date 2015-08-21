//
//  PlatformNodeTests.swift
//  UberJump
//
//  Created by Peter Huang on 8/21/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import UIKit
import XCTest
import SpriteKit

class PlatformNodeTests: XCTestCase {
    
    var parentNode = SKNode()
    var platform = PlatformNode()
    var player = SKNode()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        player.physicsBody = SKPhysicsBody(circleOfRadius: 10.0)
        player.physicsBody?.dynamic = true
        platform.position = CGPoint(x: 100, y: 100)
        platform.platformType = PlatformType.Normal
        parentNode.addChild(platform)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCollisionWithPlayerReturnsFalseForPlatformNode() {
        XCTAssertTrue(platform.collisionWithPlayer(player) == false)
    }
    
    func testCollideWithPlatformNodeWillBoostPlayer() {
        let originVelocityX = player.physicsBody?.velocity.dx
        player.physicsBody?.velocity.dy = -10.0
        platform.collisionWithPlayer(player)
        XCTAssertTrue(player.physicsBody?.velocity.dy >= 250.0)
        XCTAssertTrue(player.physicsBody?.velocity.dx == originVelocityX)
    }
    
    func testCollideOnlyHappensWhenPlayerFallsDown() {
        player.physicsBody?.velocity.dy = 10.0
        platform.collisionWithPlayer(player)
        XCTAssertTrue(player.physicsBody?.velocity.dy <= 11.0)
    }
    
    func testCollideWithBreakablePlatformWillMakeThePlatformDisappear() {
        let breakablePlatform = PlatformNode()
        breakablePlatform.platformType = PlatformType.Break
        parentNode.addChild(breakablePlatform)
        
        player.physicsBody?.velocity.dy = -10.0
        breakablePlatform.collisionWithPlayer(player)
        
        XCTAssertTrue(breakablePlatform.parent == nil)
    }
    
    func testCollideWithNormalPlatformWillNotMakeThePlatformDisappear() {
        player.physicsBody?.velocity.dy = -10.0
        platform.collisionWithPlayer(player)
        
        XCTAssertTrue(platform.parent != nil)
    }

}
