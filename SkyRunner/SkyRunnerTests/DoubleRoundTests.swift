//
//  DoubleRoundTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 8/4/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest

class DoubleRoundTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTwoDoublesAreEqual() {
        let doubleOne: Double = 3.1415926
        let doubleTwo: Double = 3.1425934
        XCTAssertTrue(doubleOne.round(2) == doubleTwo.round(2))
    }

}
