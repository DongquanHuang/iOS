//
//  Array2DTests.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/10/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest

class Array2DTests: XCTestCase {
    
    var cookies = Array2D<Cookie>(columns: 9, rows: 9)
    let cookie = Cookie(column: 3, row: 3, cookieType: .Croissant)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCanSetAndGetCookieInCookieArray() {
        cookies[cookie.column, cookie.row] = cookie
        XCTAssertTrue(cookies[cookie.column, cookie.row]!.description == "Type:Croissant Square:(3,3)")
    }

}
