//
//  GameStateTests.swift
//  UberJump
//
//  Created by Peter Huang on 8/24/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import UIKit
import XCTest

class GameStateTests: XCTestCase {
    
    var gameState = GameState.sharedInstance
    var mockDefaults = MockUserDefaults()
    
    class MockUserDefaults: NSUserDefaults {
        var dictionary: [String : Int] = ["highScore" : 5, "stars" : 5]
        var syncMethodCalled = false
        
        override func integerForKey(defaultName: String) -> Int {
            return dictionary[defaultName]!
        }
        
        override func setInteger(value: Int, forKey defaultName: String) {
            dictionary[defaultName] = value
        }
        
        override func synchronize() -> Bool {
            syncMethodCalled = true
            return true
        }
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        gameState.stateStore = mockDefaults
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSingleton() {
        let gameState1 = GameState.sharedInstance
        let gameState2 = GameState.sharedInstance
        XCTAssertTrue(gameState1 == gameState2)
    }
    
    func testReadStateWillSetHighScoreCorrectly() {
        gameState.readState()
        XCTAssertTrue(gameState.highScore == 5)
    }
    
    func testReadStateWillSetStarNumberCorrectly() {
        gameState.readState()
        XCTAssertTrue(gameState.stars == 5)
    }
    
    func testSaveStateWillNotSaveTheScoreIfItsLessThanHighScore() {
        gameState.score = 10
        gameState.highScore = 20
        gameState.saveState()
        XCTAssertTrue(mockDefaults.dictionary["highScore"] == 20)
    }
    
    func testSaveStateWillSaveScoreIfItsHigherThanHighScore() {
        gameState.score = 20
        gameState.highScore = 10
        gameState.saveState()
        XCTAssertTrue(mockDefaults.dictionary["highScore"] == 20)
    }
    
    func testStarNumbersWillBeSaved() {
        gameState.stars = 10
        gameState.saveState()
        XCTAssertTrue(mockDefaults.dictionary["stars"] == 10)
    }
    
    func testSaveStateWillCallSyncMethod() {
        gameState.saveState()
        XCTAssertTrue(mockDefaults.syncMethodCalled == true)
    }

}
