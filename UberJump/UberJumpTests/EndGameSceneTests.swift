//
//  EndGameSceneTests.swift
//  UberJump
//
//  Created by Peter Huang on 8/24/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import UIKit
import XCTest
import SpriteKit

class EndGameSceneTests: XCTestCase {
    
    var endScene = EndGameScene(size: CGSize(width: 1980, height: 1080))
    var mockGameState = MockGameState()
    
    class MockGameState: GameState {
        
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockGameState.score = 1000
        mockGameState.stars = 30
        mockGameState.highScore = 2000
        endScene.gameState = mockGameState
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testStarIconIsAddedAndThePositionIsSetCorrectly() {
        let starIcon = endScene.children.first as! SKSpriteNode
        XCTAssertTrue(starIcon.position == CGPoint(x: 25, y: endScene.size.height-30))
    }
    
    func testStarLabelIsAddedAndAllPropertiesAreSetCorrectly() {
        endScene.displayGameStatistic()
        let lblStars = endScene.children[1] as! SKLabelNode
        
        XCTAssertTrue(lblStars.fontName == "ChalkboardSE-Bold")
        XCTAssertTrue(lblStars.fontSize == 30)
        XCTAssertTrue(lblStars.fontColor!.description == "UIDeviceRGBColorSpace 1 1 1 1")
        XCTAssertTrue(lblStars.position == CGPoint(x: 50, y: endScene.size.height - 40))
        XCTAssertTrue(lblStars.text == String(format: "X %d", mockGameState.stars))
    }
    
    func testScoreLabelIsAddedAndAllPropertiesAreSetCorrectly() {
        endScene.displayGameStatistic()
        let lblScore = endScene.children[2] as! SKLabelNode
        
        XCTAssertTrue(lblScore.fontName == "ChalkboardSE-Bold")
        XCTAssertTrue(lblScore.fontSize == 60)
        XCTAssertTrue(lblScore.fontColor!.description == "UIDeviceRGBColorSpace 1 1 1 1")
        XCTAssertTrue(lblScore.position == CGPoint(x: endScene.size.width / 2, y: 300))
        XCTAssertTrue(lblScore.text == String(format: "%d", mockGameState.score))
    }
    
    func testHighScoreLabelIsAddedAndAllPropertiesAreSetCorrectly() {
        endScene.displayGameStatistic()
        let lblHighScore = endScene.children[3] as! SKLabelNode
        
        XCTAssertTrue(lblHighScore.fontName == "ChalkboardSE-Bold")
        XCTAssertTrue(lblHighScore.fontSize == 30)
        XCTAssertTrue(lblHighScore.fontColor!.description == "UIDeviceRGBColorSpace 1 1 1 1")
        XCTAssertTrue(lblHighScore.position == CGPoint(x: endScene.size.width / 2, y: 150))
        XCTAssertTrue(lblHighScore.text == String(format: "High Score: %d", mockGameState.highScore))
    }
    
    func testTryAgainLabelIsAddedAndAllPropertiesAreSetCorrectly() {
        endScene.displayGameStatistic()
        let lblTryAgain = endScene.children[4] as! SKLabelNode
        
        XCTAssertTrue(lblTryAgain.fontName == "ChalkboardSE-Bold")
        XCTAssertTrue(lblTryAgain.fontSize == 30)
        XCTAssertTrue(lblTryAgain.fontColor!.description == "UIDeviceRGBColorSpace 1 1 1 1")
        XCTAssertTrue(lblTryAgain.position == CGPoint(x: endScene.size.width / 2, y: 50))
        XCTAssertTrue(lblTryAgain.text == "Tap To Try Again")
    }

}
