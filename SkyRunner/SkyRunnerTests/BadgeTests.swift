//
//  BadgeTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/22/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest

import SkyRunner

class BadgeTests: XCTestCase {
    
    var badge: Badge?
    let badgeJsonString = ["name":"badgeName", "imageName":"badgeImageName", "distance":"100.0", "information": "badgeInformation"]

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        badge = Badge(badgeJsonString: badgeJsonString)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCanConstructBadgeFromDictionary() {
        XCTAssertNotNil(badge)
    }
    
    func testBadgeNameSetCorrectlyAfterInit() {
        XCTAssertTrue(badge?.name == "badgeName")
    }
    
    func testBadgeImageNameSetCorrectlyAfterInit() {
        XCTAssertTrue(badge?.imageName == "badgeImageName")
    }
    
    func testBadgeInformationSetCorrectlyAfterInit() {
        XCTAssertTrue(badge?.information == "badgeInformation")
    }
    
    func testBadgeDistanceSetCorrectlyAfterInit() {
        XCTAssertTrue(badge?.distance == 100.0)
    }
    
    func testBadgeDistanceSetToZeroIfDistanceStringCannotConvertToNumber() {
        let invalidBadgeJsonString = ["distance":"invalid distance"]
        let theBadge = Badge(badgeJsonString: invalidBadgeJsonString)
        XCTAssertTrue(theBadge.distance == 0.0)
    }

}
