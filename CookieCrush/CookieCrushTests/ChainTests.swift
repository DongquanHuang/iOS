//
//  ChainTests.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/13/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest

class ChainTests: XCTestCase {
    
    var horizontalChain: Chain?
    
    var cookie1 = Cookie(column: 0, row: 0, cookieType: .Croissant)
    var cookie2 = Cookie(column: 0, row: 1, cookieType: .Croissant)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        horizontalChain = Chain(chainType: .Horizontal)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testShouldInitChainWithChainType() {
        XCTAssert(horizontalChain?.chainType == .Horizontal)
    }
    
    func testCanAddCookieIntoChain() {
        horizontalChain?.addCookie(cookie1)
        XCTAssert(horizontalChain?.cookies.count == 1)
    }
    
    func testCanGetFirstCookieFromChain() {
        horizontalChain?.addCookie(cookie1)
        XCTAssert(horizontalChain?.firstCookie() == cookie1)
    }
    
    func testCanGetLastCookieFromChain() {
        horizontalChain?.addCookie(cookie1)
        horizontalChain?.addCookie(cookie2)
        XCTAssert(horizontalChain?.lastCookie() == cookie2)
    }
    
    func testCanGetChainLength() {
        horizontalChain?.addCookie(cookie1)
        horizontalChain?.addCookie(cookie2)
        XCTAssert(horizontalChain?.length() == 2)
    }
    
    func testChainConformsToHashableProtocol() {
        horizontalChain?.addCookie(cookie1)
        horizontalChain?.addCookie(cookie2)
        
        let chain2 = Chain(chainType: .Horizontal)
        chain2.addCookie(cookie1)
        chain2.addCookie(cookie2)
        
        XCTAssert(horizontalChain?.hashValue == cookie1.hashValue ^ cookie2.hashValue)
        XCTAssert(horizontalChain == chain2)
    }
    
    func testChainConformsToPrintableProtocol() {
        horizontalChain?.addCookie(cookie1)
        horizontalChain?.addCookie(cookie2)
        
        print("\(horizontalChain?.description)")
        XCTAssert(horizontalChain?.description == "Chain type:Horizontal with cookies:[Type:Croissant Square:(0,0), Type:Croissant Square:(0,1)]")
    }
}
