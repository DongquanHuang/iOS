//
//  GameSceneTests.swift
//  UberJump
//
//  Created by Peter Huang on 8/20/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import UIKit
import XCTest
import SpriteKit

class GameSceneTests: XCTestCase {
    
    var gameScene = GameScene(size: CGSize(width: 100, height: 100))

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Test device compatibility
    func testScaleFactorIsSetProperly() {
        XCTAssertTrue(gameScene.scaleFactor == gameScene.size.width / 320.0)
    }

    // MARK: - Test background added properly
    func testBackgroundColorIsSetToWhite() {
        XCTAssertTrue(gameScene.backgroundColor.description == "UIDeviceRGBColorSpace 1 1 1 1")
    }
    
    func testBackgroundNodeShouldHave20ChildrenNodes() {
        XCTAssertTrue(gameScene.backgroundNode.children.count == 20)
    }
    
    func testChildNodeOfBackgroundShouldHaveProperScaleFactor() {
        for node in gameScene.backgroundNode.children as! [SKSpriteNode] {
            XCTAssertTrue(node.xScale == gameScene.scaleFactor)
            XCTAssertTrue(node.yScale == gameScene.scaleFactor)
        }
    }
    
    func testChildNodeOfBackgroundShouldSetAnchorPointCorrectly() {
        for node in gameScene.backgroundNode.children as! [SKSpriteNode] {
            XCTAssertTrue(node.anchorPoint == CGPoint(x: 0.5, y: 0.0))
        }
    }
    
    func testEachChildNodeOfBackgroundShouldHavePositionSetProperly() {
        for i in 0 ..< gameScene.backgroundNode.children.count {
            if let node = gameScene.backgroundNode.children[i] as? SKSpriteNode {
                XCTAssertTrue(node.position.x == node.frame.size.width / 2)
                XCTAssertTrue(node.position.y == 64.0 * gameScene.scaleFactor * CGFloat(i))
            }
        }
    }
    
    func testGameSceneHasBackgroundNodeAddedAferInitMethod() {
        let bgNode = gameScene.children[0] as! SKNode
        XCTAssertTrue(bgNode == gameScene.backgroundNode)
    }
    
    // MARK: - Test foreground & Player
    func testForegroundNodeIsAddedAsLastChildAfterInitMethod() {
        let fgNode = gameScene.children.last as! SKNode
        XCTAssertTrue(fgNode == gameScene.foregroundNode)
    }
    
    func testPlayerIsAddedAsFirstChildOfForegroundAfterInitMethod() {
        XCTAssertTrue(gameScene.player == gameScene.foregroundNode.children.first as! SKNode)
    }
    
    func testPlayerNodePositionIsSetCorrectly() {
        XCTAssertTrue(gameScene.player.position.x == gameScene.frame.size.width / 2)
        XCTAssertTrue(gameScene.player.position.y == 80.0)
    }
    
    func testPlayerNodeHasSpriteSetCorrectly() {
        let sprite = gameScene.player.children.first as! SKSpriteNode
        XCTAssertNotNil(sprite)
    }
    
    // MARK: - Test gravity
    func testGravityIsSetupAfterInitMethod() {
        XCTAssertTrue(gameScene.physicsWorld.gravity == CGVector(dx: 0.0, dy: -2.0))
    }
    
    func testPlayerHasPhysicsBody() {
        XCTAssertNotNil(gameScene.player.physicsBody)
    }
    
    func testPlayerIsDynamicBody() {
        XCTAssertTrue(gameScene.player.physicsBody?.dynamic == true)
    }
    
    func testPlayerAllowRotationIsSetToFalse() {
        XCTAssertTrue(gameScene.player.physicsBody?.allowsRotation == false)
    }
    
    func testPlayerRestitutionIsSetToOne() {
        XCTAssertTrue(gameScene.player.physicsBody?.restitution == 1.0)
    }
    
    func testPlayerFrictionIsSetToZero() {
        XCTAssertTrue(gameScene.player.physicsBody?.friction == 0.0)
    }
    
    func testPlayerAngularDampingIsSetToZero() {
        XCTAssertTrue(gameScene.player.physicsBody?.angularDamping == 0.0)
    }
    
    func testPlayerLinearDampingIsSetToZero() {
        XCTAssertTrue(gameScene.player.physicsBody?.linearDamping == 0.0)
    }

}
