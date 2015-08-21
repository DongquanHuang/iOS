//
//  GameLevelLoaderTests.swift
//  UberJump
//
//  Created by Peter Huang on 8/21/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import UIKit
import XCTest

class GameLevelLoaderTests: XCTestCase {
    
    var loader = GameLevelLoader()
    lazy var level: GameLevel? = {
        return self.loader.loadLevel(1)
    }()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCanLoadValidLevelSuccessful() {
        XCTAssertNotNil(level)
    }
    
    func testCannotLoadLevelIfItsInvalid() {
        let invalidLevel = loader.loadLevel(-1)
        XCTAssertNil(invalidLevel)
    }
    
    func testEndYShouldBeSetToGameLevel() {
        XCTAssertTrue(level?.endLevelY == 7200)
    }
    
    func testPlatformsShouldBeFilledIntoGameLevel() {
        XCTAssertTrue(level?.platforms.count == 38)
    }
    
    func testStarsShouldBeFilledIntoGameLevel() {
        XCTAssertTrue(level?.stars.count == 162)
    }

}
