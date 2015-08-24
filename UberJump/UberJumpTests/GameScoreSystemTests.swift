//
//  GameScoreSystemTests.swift
//  UberJump
//
//  Created by Peter Huang on 8/24/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import UIKit
import XCTest

class GameScoreSystemTests: XCTestCase {
    
    var gameScoreSystem = GameScoreSystem()
    var mockGameState = MockGameState()
    
    class MockGameState: GameState {
        
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        gameScoreSystem.gameState = mockGameState
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAwardScoreWillUpdateGameStateScore() {
        let originalScore = mockGameState.score
        gameScoreSystem.awardScore(100)
        XCTAssertTrue(mockGameState.score == 100 + originalScore)
    }
    
    func testAwardStarWillUpdateGameStateStars() {
        let originalStars = mockGameState.stars
        gameScoreSystem.awardStar(50)
        XCTAssertTrue(mockGameState.stars == 50 + originalStars)
    }

}
