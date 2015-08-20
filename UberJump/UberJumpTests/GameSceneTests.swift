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

    func testBackgroundColorIsSetToWhite() {
        XCTAssertTrue(gameScene.backgroundColor.description == "UIDeviceRGBColorSpace 1 1 1 1")
    }
    
    func testScaleFactorIsSetProperly() {
        XCTAssertTrue(gameScene.scaleFactor == gameScene.size.width / 320.0)
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

}
