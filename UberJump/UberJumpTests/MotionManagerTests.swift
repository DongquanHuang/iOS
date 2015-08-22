//
//  MotionManagerTests.swift
//  UberJump
//
//  Created by Peter Huang on 15/8/22.
//  Copyright (c) 2015年 HDQ. All rights reserved.
//

import UIKit
import XCTest

class MotionManagerTests: XCTestCase {
    
    var motionMgr = MotionManager()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testMotionMgrHasDefaultXAccelerationWithValueZero() {
        XCTAssertTrue(motionMgr.xAcceleration == 0)
    }
    
    func testStartMotionMgrWillSetUpdateIntervalCorrectly() {
        motionMgr.start()
        XCTAssertTrue(motionMgr.motionManager.accelerometerUpdateInterval == 0.2)
    }
    
}
