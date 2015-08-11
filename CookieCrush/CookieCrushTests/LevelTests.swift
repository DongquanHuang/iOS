//
//  LevelTests.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/10/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest

class LevelTests: XCTestCase {
    
    var level = Level(filename: "Level_4")

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCanGetNilCookieForDefaultLevel() {
        let cookie = level.cookieAtColumn(0, row: 0)
        XCTAssertNil(cookie)
    }
    
    func testShuffleWillFillCookieArrayCorrectly() {
        level.shuffle()
        XCTAssertNil(level.cookieAtColumn(0, row: 0))
        XCTAssertNotNil(level.cookieAtColumn(3, row: 3))
    }
    
    func testCanGetNilTileForDefaultLevel() {
        let tile = level.tileAtColumn(0, row: 0)
        XCTAssertNil(tile)
    }
    
    func testCanInitLevelWithLevelFile() {
        XCTAssertNotNil(level)
    }
    
    func testTilesArePreparedAfterInit() {
        XCTAssertNotNil(level.tileAtColumn(3, row: 3))
        XCTAssertNil(level.tileAtColumn(0, row: 0))
    }

}
