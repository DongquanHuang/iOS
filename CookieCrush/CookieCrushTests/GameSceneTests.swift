//
//  GameSceneTests.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/10/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest
import SpriteKit

class GameSceneTests: XCTestCase {
    
    var gameScene = GameScene(size: CGSize(width: 640, height: 1136))

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAnchorPointIsSetCorrectly() {
        XCTAssertTrue(gameScene.anchorPoint == CGPoint(x: 0.5, y: 0.5))
    }
    
    func testBackgroundAddedAsFirstNode() {
        let nodes = gameScene.children as! [SKNode]
        let background = nodes.first
        XCTAssertTrue(background != nil)
    }

}
