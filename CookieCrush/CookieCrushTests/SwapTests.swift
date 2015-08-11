//
//  SwapTests.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/11/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest

class SwapTests: XCTestCase {
    
    var cookie1: Cookie?
    var cookie1Type = CookieType.Croissant
    var cookie2: Cookie?
    var cookie2Type = CookieType.Cupcake
    
    var swap: Swap?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cookie1 = Cookie(column: 0, row: 0, cookieType: cookie1Type)
        cookie2 = Cookie(column: 1, row: 1, cookieType: cookie2Type)
        
        swap = Swap(cookieA: cookie1!, cookieB: cookie2!)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSwapConformsToPrintableProtocol() {
        XCTAssertTrue(swap?.description == "swap Type:Croissant Square:(0,0) with Type:Cupcake Square:(1,1)")
    }

}
