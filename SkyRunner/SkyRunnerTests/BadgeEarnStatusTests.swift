//
//  BadgeEarnStatusTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 8/3/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest

class BadgeEarnStatusTests: XCTestCase {
    
    var badgeEarnStatus: BadgeEarnStatus?
    var badge: Badge?
    let badgeJsonString = ["name":"badgeName", "imageName":"badgeImageName", "distance":"100.0", "information": "badgeInformation"]
    var badgeEarnStatusMgr = BadgeEarnStatusMgr()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        badge = Badge(badgeJsonString: badgeJsonString)
        badgeEarnStatus = BadgeEarnStatus(badge: badge!)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCanInitBadgeEarnStatusWithBadge() {
        XCTAssertTrue(badgeEarnStatus?.badge != nil)
    }
    
    func testNextBadgeIsReturnedCorrectly() {
        let currentDistance = 0.0
        let nextBadge = badgeEarnStatusMgr.nextBadge(currentDistance)
        XCTAssertTrue(nextBadge?.name == "Earth's Atmosphere")
    }
    
    func testWillReturnLastBadgeIfAllTagetsReached() {
        let currentDistance = 42195.0
        let nextBadge = badgeEarnStatusMgr.nextBadge(currentDistance)
        XCTAssertTrue(nextBadge?.name == "Interstellar Space")
    }

}
