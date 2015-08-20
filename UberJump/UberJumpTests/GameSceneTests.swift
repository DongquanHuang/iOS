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
    
    class MockGameObjectNode: GameObjectNode {
        var collisionHandlerCalled = false
        
        override func collisionWithPlayer(player: SKNode) -> Bool {
            collisionHandlerCalled = true
            
            return false
        }
    }
    
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
    func testForegroundNodeIsAddedAsSecondLastChildAfterInitMethod() {
        let fgNode = gameScene.children[gameScene.children.count - 2] as! SKNode
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
    
    func testPlayerHasPhysicsBody() {
        XCTAssertNotNil(gameScene.player.physicsBody)
    }
    
    func testPlayerDynamicPropertyIsSetToFalseBeforeGameBegin() {
        XCTAssertTrue(gameScene.player.physicsBody?.dynamic == false)
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
    
    func testPlayerUsesPreciseCollisionDetection() {
        XCTAssertTrue(gameScene.player.physicsBody?.usesPreciseCollisionDetection == true)
    }
    
    func testPlayerCollisionCategoryBitMaskIsSetCorrectly() {
        XCTAssertTrue(gameScene.player.physicsBody?.categoryBitMask == CollisionCategoryBitmask.Player)
    }
    
    func testWillHandlePlayerCollisionByMyselfInsteadOfSpriteKit() {
        XCTAssertTrue(gameScene.player.physicsBody?.collisionBitMask == 0)
    }
    
    func testSpriteKitWillReportCollisionEventIfPlayerContactWithStarOrPlatform() {
        XCTAssertTrue(gameScene.player.physicsBody?.contactTestBitMask == CollisionCategoryBitmask.Star | CollisionCategoryBitmask.Platform)
    }
    
    // MARK: - Test HUD layer
    func testHUDNodeIsAddedAsLastChildAfterInitMethod() {
        let hudNode = gameScene.children.last as! SKNode
        XCTAssertTrue(hudNode == gameScene.hudNode)
    }
    
    func testHudNodeHasTapToStartNodeAsItsFirstChildAndSetAllPropertiesCorrectly() {
        let tapToStart = gameScene.hudNode.children.first as! SKSpriteNode
        XCTAssertTrue(tapToStart == gameScene.tapToStartNode)
        XCTAssertTrue(tapToStart.position.x == gameScene.frame.size.width / 2)
        XCTAssertTrue(tapToStart.position.y == 180.0)
    }
    
    // MARK: - Test gravity
    func testGravityIsSetupAfterInitMethod() {
        XCTAssertTrue(gameScene.physicsWorld.gravity == CGVector(dx: 0.0, dy: -2.0))
    }
    
    // MARK: - Test touch to start game
    func testWillNotStartGameIfGameAlreadyStarted() {
        gameScene.player.physicsBody?.dynamic = true    // Simulate game already started
        gameScene.touchesBegan(Set<NSObject>(), withEvent: UIEvent())
        XCTAssertNotNil(gameScene.tapToStartNode)
    }
    
    func testStartGameWillSetPlayerToDynamicBody() {
        gameScene.touchesBegan(Set<NSObject>(), withEvent: UIEvent())
        XCTAssertTrue(gameScene.player.physicsBody?.dynamic == true)
    }
    
    func testStartGameWillRemoveTapToStartNode() {
        gameScene.touchesBegan(Set<NSObject>(), withEvent: UIEvent())
        XCTAssertTrue(gameScene.tapToStartNode.parent == nil)
    }
    
    func testStartGameWillApplyImpluseToPlayer() {
        gameScene.touchesBegan(Set<NSObject>(), withEvent: UIEvent())
        XCTAssertTrue(gameScene.player.physicsBody?.velocity.dy >= 282.0)
    }
    
    // MARK: - Test add star
    func testCreateStarWillGiveBackTheStarNode() {
        XCTAssertTrue(gameScene.createStarAtPosition(CGPoint(x: 0, y: 0)).isKindOfClass(StarNode) == true)
    }
    
    func testCreateStarWillSetupThePositionCorrectly() {
        let star = gameScene.createStarAtPosition(CGPoint(x: 50, y: 50))
        XCTAssertTrue(star.position.x == 50 * gameScene.scaleFactor)
        XCTAssertTrue(star.position.y == 50)
    }
    
    func testNodeNameIsSetCorrectly() {
        let star = gameScene.createStarAtPosition(CGPoint(x: 50, y: 50))
        XCTAssertTrue(star.name == "NODE_STAR")
    }
    
    func testStarNodeHasASprite() {
        let star = gameScene.createStarAtPosition(CGPoint(x: 50, y: 50))
        XCTAssertTrue(star.children.first?.isKindOfClass(SKSpriteNode) == true)
    }
    
    func testStarNodeIsStaticBody() {
        let star = gameScene.createStarAtPosition(CGPoint(x: 50, y: 50))
        XCTAssertTrue(star.physicsBody?.dynamic == false)
    }
    
    func testStarNodeWillHaveCollisionCategoryBitMaskSetCorrectly() {
        let star = gameScene.createStarAtPosition(CGPoint(x: 50, y: 50))
        XCTAssertTrue(star.physicsBody?.categoryBitMask == CollisionCategoryBitmask.Star)
    }
    
    func testWeCanHandleStarCollisionByOurselvesInsteadOfBySpriteKit() {
        let star = gameScene.createStarAtPosition(CGPoint(x: 50, y: 50))
        XCTAssertTrue(star.physicsBody?.collisionBitMask == 0)
    }
    
    // MARK: - Test contact delegate
    func testGameSceneIsTheContactDelegate() {
        XCTAssertTrue(gameScene.physicsWorld.contactDelegate.isKindOfClass(GameScene) == true)
    }

}
