//
//  BadgeDataManagerTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/24/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest

class BadgeDataManagerTests: XCTestCase {
    
    var badgeDataManager: BadgeDataManager?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        badgeDataManager = BadgeDataManager()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBadgeDataManagerCanConfigJsonFileParser() {
        XCTAssertTrue(badgeDataManager?.jsonFileParser != nil)
    }
    
    func testBadgeDataManagerCanGenerateBadgeArrayForValidFile() {
        let filePath = NSBundle.mainBundle().pathForResource("badges", ofType: "json")
        let badges = badgeDataManager?.getBadgesFromFile(filePath)
        XCTAssertTrue(badges!.count > 0)
    }
    
    func testCanSetJsonFileParserWhenInitBadgeDataManager() {
        badgeDataManager = BadgeDataManager(parser: JsonFileParser())
        XCTAssertTrue(badgeDataManager?.jsonFileParser != nil)
    }
    
    func testCannotGetBadgesArrayFromInvalidFile() {
        let badges = badgeDataManager?.getBadgesFromFile("invalid file")
        XCTAssertTrue(badges == nil)
    }
    
    func testBadgesArrayIsNilForInvalidFileAfterOneValidFetch() {
        let filePath = NSBundle.mainBundle().pathForResource("badges", ofType: "json")
        let badges = badgeDataManager?.getBadgesFromFile(filePath)
        
        let invalidFetchResult = badgeDataManager?.getBadgesFromFile("invalid file")
        XCTAssertTrue(invalidFetchResult == nil)
    }

}
