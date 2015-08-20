//
//  GameObjectNodeTests.swift
//  UberJump
//
//  Created by Peter Huang on 8/20/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import UIKit
import XCTest
import SpriteKit

class GameObjectNodeTests: XCTestCase {
    
    var parentNode = SKNode()
    var gameObjectNode = GameObjectNode()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        gameObjectNode.position = CGPoint(x: 100, y: 100)
        parentNode.addChild(gameObjectNode)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGameObjectNodeWillBeRemovedFromParentIfItsFarAwayFromPlayer() {
        let playerY: CGFloat = 500.0
        gameObjectNode.removeNodeIfFarAwayFromPlayer(playerY)
        XCTAssertTrue(gameObjectNode.parent == nil)
    }
    
    func testGameObjectNodeWillNotBeRemovedFromParentIfItsNotFarAwayFromPlayer() {
        let playerY: CGFloat = 200.0
        gameObjectNode.removeNodeIfFarAwayFromPlayer(playerY)
        XCTAssertTrue(gameObjectNode.parent == parentNode)
    }
    
    func testGameObjectNodeClassHasOneCollisionWithPlayerMethodAndItReturnsFalse() {
        XCTAssertTrue(gameObjectNode.collisionWithPlayer(SKNode()) == false)
    }

}
