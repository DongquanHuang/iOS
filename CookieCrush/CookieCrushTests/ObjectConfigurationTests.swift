//
//  ObjectConfigurationTests.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/11/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest

class ObjectConfigurationTests: XCTestCase {
    
    var objConfiguration = ObjectConfiguration()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCanGetLevelObject() {
        XCTAssertNotNil(objConfiguration.level)
    }
    
    func testCanGetGameSceneObject() {
        XCTAssertNotNil(objConfiguration.gameScene(CGSize(width: 100, height: 100)))
    }

}
