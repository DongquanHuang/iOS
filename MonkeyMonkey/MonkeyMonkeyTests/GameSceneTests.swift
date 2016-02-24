//
//  GameSceneTests.swift
//  MonkeyMonkey
//
//  Created by Peter Huang on 2/24/16.
//  Copyright © 2016 Peter Huang. All rights reserved.
//

import XCTest

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
	
	func testScaleFactorIsSetCorrectly() {
		XCTAssertTrue(gameScene.scaleFactor == gameScene.size.width / 320.0)
	}
	
	func testBackgroundAddedAsFirstNode() {
		let nodes = gameScene.children
		let background = nodes.first
		XCTAssertTrue(background != nil)
	}
	
	func testAddedNodeIsUsingCorrectScale() {
		let nodes = gameScene.children
		let background = nodes.first
		XCTAssertTrue(background?.xScale == gameScene.scaleFactor)
		XCTAssertTrue(background?.yScale == gameScene.scaleFactor)
	}

}
