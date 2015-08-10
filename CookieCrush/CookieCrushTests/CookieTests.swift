//
//  CookieTests.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/10/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest

class CookieTests: XCTestCase {
    
    var cookie: Cookie?
    var cookieType = CookieType.Croissant

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cookie = Cookie(column: 0, row: 0, cookieType: cookieType)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCookieHasRowAndColumnInfo() {
        XCTAssertTrue(cookie!.row == 0)
        XCTAssertTrue(cookie!.column == 0)
    }
    
    func testCookieTypeIsSetCorrectly() {
        XCTAssertTrue(cookie!.cookieType == .Croissant)
    }
    
    func testCookieHasNilSpriteNodeByDefault() {
        XCTAssertTrue(cookie!.sprite == nil)
    }
    
    func testCanGetCorrectCookieSpriteName() {
        XCTAssertTrue(cookieType.spriteName == "Croissant")
    }
    
    func testCanGetCorrectHighlightedCookieSpriteName() {
        XCTAssertTrue(cookieType.highlightedSpriteName == "Croissant-Highlighted")
    }
    
    func testCanGetRandomCookieType() {
        let randomType = CookieType.random()
        XCTAssertTrue(randomType.rawValue >= CookieType.Croissant.rawValue && randomType.rawValue <= CookieType.SugarCookie.rawValue)
    }
    
    func testCanPrintCookie() {
        XCTAssertTrue(cookie!.description == "Type:Croissant Square:(0,0)")
    }

}
