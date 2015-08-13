//
//  LevelTests.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/10/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest

class LevelTests: XCTestCase {
    
    var level = Level(filename: "Level_4")
    
    private var cookies: Array2D<Cookie>?
    private var swapSet = Set<Swap>()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cookies = Array2D<Cookie>(columns: LevelConstants.NumColumns, rows: LevelConstants.NumRows)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCanGetNilCookieForDefaultLevel() {
        let cookie = level.cookieAtColumn(0, row: 0)
        XCTAssertNil(cookie)
    }
    
    func testShuffleWillFillCookieArrayCorrectly() {
        level.shuffle()
        XCTAssertNil(level.cookieAtColumn(0, row: 0))
        XCTAssertNotNil(level.cookieAtColumn(3, row: 3))
    }
    
    func testCanGetNilTileForDefaultLevel() {
        let tile = level.tileAtColumn(0, row: 0)
        XCTAssertNil(tile)
    }
    
    func testCanInitLevelWithLevelFile() {
        XCTAssertNotNil(level)
    }
    
    func testTilesArePreparedAfterInit() {
        XCTAssertNotNil(level.tileAtColumn(3, row: 3))
        XCTAssertNil(level.tileAtColumn(0, row: 0))
    }
    
    func testSwapCookies() {
        level.shuffle()
        let cookie1 = level.cookieAtColumn(3, row: 3)
        let cookie2 = level.cookieAtColumn(3, row: 4)
        let swap = Swap(cookieA: cookie1!, cookieB: cookie2!)
        level.performSwap(swap)
        XCTAssertEqual(cookie1!, level.cookieAtColumn(3, row: 4)!)
        XCTAssertEqual(cookie2!, level.cookieAtColumn(3, row: 3)!)
        XCTAssertEqual(cookie1!.row, 4)
        XCTAssertEqual(cookie2!.row, 3)
    }
    
    func testShuffleWillGenerateCookiesWithoutExistingChains() {
        var theLevel = Level(filename: "Level_0")
        theLevel.shuffle()
        
        XCTAssertTrue(chainExistingInLevel(theLevel) == false)
    }
    
    func testShuffleWillGenerateCookiesWithPossibleSwaps() {
        var theLevel = Level(filename: "Level_0")
        theLevel.shuffle()
        detectPossibleSwapsForLevel(theLevel)
        
        XCTAssertTrue(theLevel.possibleSwaps.count == swapSet.count)
    }
    
    func testIsPossbileSwapWorksCorrectly() {
        let cookie1 = Cookie(column: 0, row: 0, cookieType: .Croissant)
        let cookie2 = Cookie(column: 0, row: 1, cookieType: .Cupcake)
        let cookie3 = Cookie(column: 0, row: 2, cookieType: .Danish)
        
        let swap = Swap(cookieA: cookie1, cookieB: cookie2)
        level.possibleSwaps.insert(swap)
        
        let validSwap = Swap(cookieA: cookie1, cookieB: cookie2)
        let invalidSwap = Swap(cookieA: cookie1, cookieB: cookie3)
        
        XCTAssertTrue(level.isPossibleSwap(validSwap) == true)
        XCTAssertTrue(level.isPossibleSwap(invalidSwap) == false)
    }
    
    func testDetectChain() {
        level.shuffle()
        let swaps = level.possibleSwaps
        level.performSwap(swaps[advance(swaps.startIndex, swaps.count - 1)])
        copyCookiesFromLevel(level)
        
        XCTAssert(level.detectHorizontalMatches().count == detectHorizontalMatches().count)
        XCTAssert(level.detectVerticalMatches().count == detectVerticalMatches().count)
    }
    
    func testRemoveMatchesWillReturnUnionedMatchesSet() {
        level.shuffle()
        let swaps = level.possibleSwaps
        level.performSwap(swaps[advance(swaps.startIndex, swaps.count - 1)])
        copyCookiesFromLevel(level)
        
        let expectedMatchesToBeRemoved = detectHorizontalMatches().union(detectVerticalMatches())
        XCTAssert(level.removeMatches() == expectedMatchesToBeRemoved)
    }
    
    func testRemoveMatchesWillRemoveMatchedCookiesInDataModel() {
        level.shuffle()
        let swaps = level.possibleSwaps
        level.performSwap(swaps[advance(swaps.startIndex, swaps.count - 1)])
        
        copyCookiesFromLevel(level)
        let originalCookies = copyCookies(cookies)
        
        let expectedMatchesToBeRemovedChains = detectHorizontalMatches().union(detectVerticalMatches())
        var expectedRemoveCookieNumbers = 0
        for chain in expectedMatchesToBeRemovedChains {
            expectedRemoveCookieNumbers += chain.length()
        }
        
        level.removeMatches()
        clearCookies()
        copyCookiesFromLevel(level)
        
        XCTAssertTrue(cookieNumberInCookies(originalCookies) == cookieNumberInCookies(cookies) + expectedRemoveCookieNumbers)
    }
    
    func testHolesShouldBeFilledAfterRemoveMatchedCookies() {
        var theLevel = Level(filename: "Level_0")
        theLevel.shuffle()
        let swaps = theLevel.possibleSwaps
        theLevel.performSwap(swaps[advance(swaps.startIndex, swaps.count - 1)])
        
        theLevel.removeMatches()
        copyCookiesFromLevel(theLevel)
        
        let columns = theLevel.fillHoles()
        let expectedColumns = fillHoles(theLevel)
        let expectedCookiesArray = copyCookies(cookies)
        clearCookies()
        copyCookiesFromLevel(theLevel)
        
        XCTAssert(columns.count == expectedColumns.count)
        for i in 0 ..< columns.count {
            XCTAssert(columns[i].count == expectedColumns[i].count)
        }
        XCTAssertTrue(equalCookieArrays(cookies!, cookies2: expectedCookiesArray) == true)
    }
    
    // MARK: - private methods
    private func chainExistingInLevel(level: Level) -> Bool {
        copyCookiesFromLevel(level)
        
        for column in 0 ..< LevelConstants.NumColumns {
            for row in 0 ..< LevelConstants.NumRows {
                if let cookie = cookies![column, row] {
                    if detectChainForCookie(cookie) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    private func detectChainForCookie(cookie: Cookie) -> Bool {
        if detectHorzontalChainForCookie(cookie) {
            return true
        }
        
        if detectVerticalChainForCookie(cookie) {
            return true
        }
        
        return false
    }
    
    private func detectHorzontalChainForCookie(cookie: Cookie) -> Bool {
        var cookieType = cookie.cookieType
        
        var horzLength = 1
        for var i = cookie.column - 1; i >= 0 && cookies![i, cookie.row]?.cookieType == cookieType; i--, horzLength++ {}
        for var i = cookie.column + 1; i < LevelConstants.NumColumns && cookies![i, cookie.row]?.cookieType == cookieType; i++, horzLength++ {}
        
        return horzLength >= 3
    }
    
    private func detectVerticalChainForCookie(cookie: Cookie) -> Bool {
        var cookieType = cookie.cookieType
        
        var vertLength = 1
        for var i = cookie.row - 1; i >= 0 && cookies![cookie.column, i]?.cookieType == cookieType; i--, vertLength++ {}
        for var i = cookie.row + 1; i < LevelConstants.NumRows && cookies![cookie.column, i]?.cookieType == cookieType; i++, vertLength++ {}
        
        return vertLength >= 3
    }
    
    private func detectPossibleSwapsForLevel(level: Level) {
        swapSet.removeAll(keepCapacity: false)
        
        // Copy cookies
        copyCookiesFromLevel(level)
        
        for column in 0 ..< LevelConstants.NumColumns {
            for row in 0 ..< LevelConstants.NumRows {
                if let cookie = cookies![column, row] {
                    trySwapCookieWithRightOne(cookie)
                    trySwapCookieWithAboveOne(cookie)
                }
            }
        }
    }
    
    private func copyCookiesFromLevel(level: Level) {
        for column in 0 ..< LevelConstants.NumColumns {
            for row in 0 ..< LevelConstants.NumRows {
                if let cookie = level.cookieAtColumn(column, row: row) {
                    cookies![column, row] = cookie
                }
            }
        }
    }
    
    private func copyCookies(cookies: Array2D<Cookie>?) -> Array2D<Cookie> {
        var copiedCookies = Array2D<Cookie>(columns: LevelConstants.NumColumns, rows: LevelConstants.NumRows)
        
        for column in 0 ..< LevelConstants.NumColumns {
            for row in 0 ..< LevelConstants.NumRows {
                if let cookie = cookies?[column, row] {
                    copiedCookies[column, row] = cookie
                }
            }
        }
        
        return copiedCookies
    }
    
    private func equalCookieArrays(cookies1: Array2D<Cookie>, cookies2: Array2D<Cookie>) -> Bool {
        for column in 0 ..< LevelConstants.NumColumns {
            for row in 0 ..< LevelConstants.NumRows {
                if cookies1[column, row] != cookies2[column, row] {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func clearCookies() {
        for column in 0 ..< LevelConstants.NumColumns {
            for row in 0 ..< LevelConstants.NumRows {
                cookies![column, row] = nil
            }
        }
    }
    
    private func cookieNumberInCookies(cookies: Array2D<Cookie>?) -> Int {
        var number = 0
        
        for column in 0 ..< LevelConstants.NumColumns {
            for row in 0 ..< LevelConstants.NumRows {
                if let cookie = cookies?[column, row] {
                    number++
                }
            }
        }
        
        return number
    }
    
    private func trySwapCookieWithRightOne(cookie: Cookie) {
        let column = cookie.column
        let row = cookie.row
        
        if column < LevelConstants.NumColumns - 1 {
            if let other = cookies![column + 1, row] {
                swapCookie(cookie, withCookie: other)
                
                if detectChainForCookie(cookie) || detectChainForCookie(other) {
                    swapSet.insert(Swap(cookieA: cookie, cookieB: other))
                }
                
                swapCookie(cookie, withCookie: other)
            }
        }
    }
    
    private func trySwapCookieWithAboveOne(cookie: Cookie) {
        let column = cookie.column
        let row = cookie.row
        
        if row < LevelConstants.NumRows - 1 {
            if let other = cookies![column, row + 1] {
                swapCookie(cookie, withCookie: other)
                
                if detectChainForCookie(cookie) || detectChainForCookie(other) {
                    swapSet.insert(Swap(cookieA: cookie, cookieB: other))
                }
                
                swapCookie(cookie, withCookie: other)
            }
        }
    }
    
    private func swapCookie(cookieA: Cookie, withCookie cookieB: Cookie) {
        let columnA = cookieA.column
        let rowA = cookieA.row
        let columnB = cookieB.column
        let rowB = cookieB.row
        
        cookies![columnA, rowA] = cookieB
        cookieB.column = columnA
        cookieB.row = rowA
        
        cookies![columnB, rowB] = cookieA
        cookieA.column = columnB
        cookieA.row = rowB
    }
    
    private func detectHorizontalMatches() -> Set<Chain> {
        var horizontalMatches = Set<Chain>()
        
        for row in 0 ..< LevelConstants.NumRows {
            for var column = 0; column < LevelConstants.NumColumns - 2; {
                
                if let cookie = cookies![column, row] {
                    if detectHorzontalChainForCookie(cookie) {
                        let chain = Chain(chainType: .Horizontal)
                        while (cookies![column, row]?.cookieType == cookie.cookieType) {
                            chain.addCookie(cookies![column, row]!)
                            column++
                            
                            if column >= LevelConstants.NumColumns {
                                break
                            }
                        }
                        
                        horizontalMatches.insert(chain)
                    }
                    else {
                        column++
                    }
                }
                else {
                    column++
                }
            }
        }
        
        return horizontalMatches
    }
    
    private func detectVerticalMatches() -> Set<Chain> {
        var verticalMatches = Set<Chain>()
        
        for column in 0 ..< LevelConstants.NumColumns {
            for var row = 0; row < LevelConstants.NumRows - 2; {
                
                if let cookie = cookies![column, row] {
                    if detectVerticalChainForCookie(cookie) {
                        let chain = Chain(chainType: .Vertical)
                        while (cookies![column, row]?.cookieType == cookie.cookieType) {
                            chain.addCookie(cookies![column, row]!)
                            row++
                            
                            if row >= LevelConstants.NumRows {
                                break
                            }
                        }
                        
                        verticalMatches.insert(chain)
                    }
                    else {
                        row++
                    }
                }
                else {
                    row++
                }
            }
        }
        
        return verticalMatches
    }
    
    private func fillHoles(level: Level) -> [[Cookie]] {
        var columns = [[Cookie]]()

        for column in 0 ..< LevelConstants.NumColumns {
            var array = [Cookie]()
            for row in 0 ..< LevelConstants.NumRows {

                if level.tileAtColumn(column, row: row) != nil && cookies![column, row] == nil {

                    for lookup in (row + 1) ..< LevelConstants.NumRows {
                        if let cookie = cookies![column, lookup] {

                            cookies![column, lookup] = nil
                            cookies![column, row] = cookie
                            cookie.row = row
                            
                            array.append(cookie)
                            
                            break
                        }
                    }
                }
            }
            
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }

}
