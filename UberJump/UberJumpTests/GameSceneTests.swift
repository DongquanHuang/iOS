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
    lazy var star: StarNode = {
        return self.gameScene.createStarAtPosition(CGPoint(x: 50, y: 50), OfType: .Normal)
    }()
    lazy var platform: PlatformNode = {
        return self.gameScene.createPlatformAtPosition(CGPoint(x: 60, y: 60), OfType: .Normal)
    }()

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
    
    func testPlayerIsAddedAsLastChildOfForegroundAfterInitMethod() {
        XCTAssertTrue(gameScene.player == gameScene.foregroundNode.children.last as! SKNode)
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
        XCTAssertTrue(star.isKindOfClass(StarNode) == true)
        XCTAssertTrue(star.starType == StarType.Normal)
    }
    
    func testWeHaveDifferentTypesOfStarSprites() {
        let normalSprite = star.children.first as! SKSpriteNode
        let specialStar = gameScene.createStarAtPosition(CGPoint(x: 50, y: 50), OfType: StarType.Special)
        let specialSprite = specialStar.children.first as! SKSpriteNode
        let normalStar = gameScene.createStarAtPosition(CGPoint(x: 50, y: 50), OfType: StarType.Normal)
        let normalSprite2 = normalStar.children.first as! SKSpriteNode

        XCTAssertTrue(normalSprite.texture!.description != specialSprite.texture!.description)
        XCTAssertTrue(normalSprite.texture!.description == normalSprite2.texture!.description)
    }
    
    func testCreateStarWillSetupThePositionCorrectly() {
        XCTAssertTrue(star.position.x == 50 * gameScene.scaleFactor)
        XCTAssertTrue(star.position.y == 50)
    }
    
    func testStarNodeNameIsSetCorrectly() {
        XCTAssertTrue(star.name == "NODE_STAR")
    }
    
    func testStarNodeHasASprite() {
        XCTAssertTrue(star.children.first?.isKindOfClass(SKSpriteNode) == true)
    }
    
    func testStarNodeIsStaticBody() {
        XCTAssertTrue(star.physicsBody?.dynamic == false)
    }
    
    func testStarNodeWillHaveCollisionCategoryBitMaskSetCorrectly() {
        XCTAssertTrue(star.physicsBody?.categoryBitMask == CollisionCategoryBitmask.Star)
    }
    
    func testWeCanHandleStarCollisionByOurselvesInsteadOfBySpriteKit() {
        XCTAssertTrue(star.physicsBody?.collisionBitMask == 0)
    }
    
    // MARK: - Test add platform
    func testCreatePlatformWillGiveBackThePlatformNode() {
        XCTAssertTrue(platform.isKindOfClass(PlatformNode) == true)
        XCTAssertTrue(platform.platformType == PlatformType.Normal)
    }
    
    func testWeHaveDifferentTypesOfPlatformSprites() {
        let normalSprite = platform.children.first as! SKSpriteNode
        let breakablePlatform = gameScene.createPlatformAtPosition(CGPoint(x: 50, y: 50), OfType: PlatformType.Break)
        let breakableSprite = breakablePlatform.children.first as! SKSpriteNode
        
        XCTAssertTrue(normalSprite.texture!.description != breakableSprite.texture!.description)
    }
    
    func testCreatePlatformWillSetupThePositionCorrectly() {
        XCTAssertTrue(platform.position.x == 60 * gameScene.scaleFactor)
        XCTAssertTrue(platform.position.y == 60)
    }
    
    func testPlatformNodeNameIsSetCorrectly() {
        XCTAssertTrue(platform.name == "NODE_PLATFORM")
    }
    
    func testPlatformNodeHasASprite() {
        XCTAssertTrue(platform.children.first?.isKindOfClass(SKSpriteNode) == true)
    }
    
    func testPlatformNodeIsStaticBody() {
        XCTAssertTrue(platform.physicsBody?.dynamic == false)
    }
    
    func testPlatformNodeWillHaveCollisionCategoryBitMaskSetCorrectly() {
        XCTAssertTrue(platform.physicsBody?.categoryBitMask == CollisionCategoryBitmask.Platform)
    }
    
    func testWeCanHandlePlatformCollisionByOurselvesInsteadOfBySpriteKit() {
        XCTAssertTrue(platform.physicsBody?.collisionBitMask == 0)
    }
    
    // MARK: - Test contact delegate
    func testGameSceneIsTheContactDelegate() {
        XCTAssertTrue(gameScene.physicsWorld.contactDelegate.isKindOfClass(GameScene) == true)
    }

}
