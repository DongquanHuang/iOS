//
//  NextBadgeProviderTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 8/5/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest

class NextBadgeProviderTests: XCTestCase {
    
    var badge: Badge?
    let badgeJsonString = ["name":"badgeName", "imageName":"badgeImageName", "distance":"100.0", "information": "badgeInformation"]
    var badgeDataProvider = NextBadgeProvider()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNextBadgeIsReturnedCorrectly() {
        let currentDistance = 0.0
        let nextBadge = badgeDataProvider.nextBadge(currentDistance)
        XCTAssertTrue(nextBadge?.name == "Earth's Atmosphere")
    }
    
    func testWillReturnLastBadgeIfAllTagetsReached() {
        let currentDistance = 42195.0
        let nextBadge = badgeDataProvider.nextBadge(currentDistance)
        XCTAssertTrue(nextBadge?.name == "Interstellar Space")
    }

}
