//
//  Level.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/10/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import Foundation

struct LevelConstants {
    static let NumColumns = 9
    static let NumRows = 9
}

class Level {
    private var cookies = Array2D<Cookie>(columns: LevelConstants.NumColumns, rows: LevelConstants.NumRows)
    private var tiles = Array2D<Tile>(columns: LevelConstants.NumColumns, rows: LevelConstants.NumRows)
    
    var possibleSwaps = Set<Swap>()
    
    // MARK: - Init
    init(filename: String) {
        fillTilesFromLevelFile(filename)
    }
    
    // MARK: - Get Cookie & Tile from 2D Array
    func cookieAtColumn(column: Int, row: Int) -> Cookie? {
        // Note: currently Swift cannot catch exception for unit test
        // Thus following two asserts will not be covered by unit test
        assert(column >= 0 && column < LevelConstants.NumColumns)
        assert(row >= 0 && row < LevelConstants.NumRows)
        
        return cookies[column, row]
    }
    
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        // Note: currently Swift cannot catch exception for unit test
        // Thus following two asserts will not be covered by unit test
        assert(column >= 0 && column < LevelConstants.NumColumns)
        assert(row >= 0 && row < LevelConstants.NumRows)
        
        return tiles[column, row]
    }
    
    // MARK: - Prepare cookies
    func shuffle() -> Set<Cookie> {
        var cookieSet: Set<Cookie>
        
        do {
            cookieSet = createInitialCookies()
            detectPossibleSwaps()
        } while !hasPossbileSwaps()
        
        return cookieSet
    }
    
    // MARK: - Private methods - Fill tiles based on level file
    private func fillTilesFromLevelFile(filename: String) {
        if let dictionary = LevelFileParser.loadJSONFromBundle(filename) {
            fillTiles(dictionary)
        }
    }
    
    private func fillTiles(dictionary: Dictionary<String, AnyObject>) {
        if let tilesArray: AnyObject = dictionary["tiles"] {
            for (row, rowArray) in enumerate(tilesArray as! [[Int]]) {
                let tileRow = LevelConstants.NumRows - row - 1
                for (column, value) in enumerate(rowArray) {
                    if value == 1 {
                        tiles[column, tileRow] = Tile()
                    }
                }
            }
        }
    }
    
    // MARK: - Private methods - Create cookie based on level file
    private func createInitialCookies() -> Set<Cookie> {
        var cookieSet = Set<Cookie>()
        
        for row in 0 ..< LevelConstants.NumRows {
            for column in 0 ..< LevelConstants.NumColumns {
                
                if tiles[column, row] != nil {
                    var cookieType = getRandomCookieTypeWithoutMakingChainsForColumn(column, row: row)
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                    
                    cookieSet.insert(cookie)
                }
            }
        }
        
        return cookieSet
    }
    
    private func getRandomCookieTypeWithoutMakingChainsForColumn(column: Int, row: Int) -> CookieType {
        var cookieType: CookieType
        
        do {
            cookieType = CookieType.random()
        } while findChainIfAddCookieType(cookieType, AtColumn: column, row: row)
        
        return cookieType
    }
    
    private func findChainIfAddCookieType(cookieType: CookieType, AtColumn column: Int, row: Int) -> Bool {
        return findHorzonalChainIfAddCookieType(cookieType, AtColumn: column, row: row) || findVerticalChainIfAddCookieType(cookieType, AtColumn: column, row: row)
    }
    
    private func findHorzonalChainIfAddCookieType(cookieType: CookieType, AtColumn column: Int, row: Int) -> Bool {
        return column >= 2 && cookies[column - 1, row]?.cookieType == cookieType && cookies[column - 2, row]?.cookieType == cookieType
    }
    
    private func findVerticalChainIfAddCookieType(cookieType: CookieType, AtColumn column: Int, row: Int) -> Bool {
        return row >= 2 && cookies[column, row - 1]?.cookieType == cookieType && cookies[column, row - 2]?.cookieType == cookieType
    }
    
    // MARK: - Detect swaps
    private func detectPossibleSwaps() {
        cleanupPossibleSwaps()
        detectPossibleSwapsForEachCookie()
    }
    
    private func detectPossibleSwapsForEachCookie() {
        for column in 0 ..< LevelConstants.NumColumns {
            for row in 0 ..< LevelConstants.NumRows {
                
                if let cookie = cookies[column, row] {
                    for neighbour in getRightAndAboveNeighboursForCookie(cookie) {
                        findPossibleSwapForCookie(cookie, AndNeighbour: neighbour)
                    }
                }
                
            }
        }
    }
    
    private func getRightAndAboveNeighboursForCookie(cookie: Cookie) -> [Cookie] {
        var cookiesArray = [Cookie]()
        
        if let right = getRightNeighbourForCookie(cookie) {
            cookiesArray.append(right)
        }
        if let above = getAboveNeighbourForCookie(cookie) {
            cookiesArray.append(above)
        }
        
        return cookiesArray
    }
    
    private func getRightNeighbourForCookie(cookie: Cookie) -> Cookie? {
        if cookie.column < LevelConstants.NumColumns - 1 {
            if let other = cookies[cookie.column + 1, cookie.row] {
                return other
            }
        }
        return nil
    }
    
    private func getAboveNeighbourForCookie(cookie: Cookie) -> Cookie? {
        if cookie.row < LevelConstants.NumRows - 1 {
            if let other = cookies[cookie.column, cookie.row + 1] {
                return other
            }
        }
        return nil
    }
    
    private func findPossibleSwapForCookie(cookie: Cookie, AndNeighbour neighbour: Cookie) {
        swapCookie(cookie, withCookie: neighbour)
        addPossibleSwap(Swap(cookieA: cookie, cookieB: neighbour))
        swapCookie(cookie, withCookie: neighbour)
    }
    
    private func addPossibleSwap(swap: Swap) {
        if detectChainForSwap(swap) {
            possibleSwaps.insert(swap)
        }
    }
    
    private func detectChainForSwap(swap: Swap) -> Bool {
        return detectChainForCookie(swap.cookieA) || detectChainForCookie(swap.cookieB)
    }
    
    private func detectChainForCookie(cookie: Cookie) -> Bool {
        return detectHorzontalChainForCookie(cookie) || detectVerticalChainForCookie(cookie)
    }
    
    private func detectHorzontalChainForCookie(cookie: Cookie) -> Bool {
        var cookieType = cookie.cookieType
        
        var horzLength = 1
        for var i = cookie.column - 1; i >= 0 && cookies[i, cookie.row]?.cookieType == cookieType; i--, horzLength++ {}
        for var i = cookie.column + 1; i < LevelConstants.NumColumns && cookies[i, cookie.row]?.cookieType == cookieType; i++, horzLength++ {}
        
        return horzLength >= 3
    }
    
    private func detectVerticalChainForCookie(cookie: Cookie) -> Bool {
        var cookieType = cookie.cookieType
        
        var vertLength = 1
        for var i = cookie.row - 1; i >= 0 && cookies[cookie.column, i]?.cookieType == cookieType; i--, vertLength++ {}
        for var i = cookie.row + 1; i < LevelConstants.NumRows && cookies[cookie.column, i]?.cookieType == cookieType; i++, vertLength++ {}
        
        return vertLength >= 3
    }
    
    private func hasPossbileSwaps() -> Bool {
        return possibleSwaps.count > 0
    }
    
    private func cleanupPossibleSwaps() {
        possibleSwaps.removeAll(keepCapacity: false)
    }
    
    // MARK: - Remove chains
    func removeMatches() -> Set<Chain> {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        
        removeCookiesInChains(horizontalChains)
        removeCookiesInChains(verticalChains)
        
        return horizontalChains.union(verticalChains)
    }
    
    func detectHorizontalMatches() -> Set<Chain> {
        var horizontalMatches = Set<Chain>()
        
        for row in 0 ..< LevelConstants.NumRows {
            for var column = 0; column < LevelConstants.NumColumns - 2; {
                
                let chain = fillHorizontalChainForColumn(column, row: row)
                
                if chainIsValid(chain) {
                    horizontalMatches.insert(chain)
                    column += chain.length()
                }
                else {
                    column++
                }
                
            }
        }
        
        return horizontalMatches
    }
    
    func detectVerticalMatches() -> Set<Chain> {
        var verticalMatches = Set<Chain>()
        
        for column in 0 ..< LevelConstants.NumColumns {
            for var row = 0; row < LevelConstants.NumRows - 2; {
                
                let chain = fillVerticalChainForColumn(column, row: row)
                
                if chainIsValid(chain) {
                    verticalMatches.insert(chain)
                    row += chain.length()
                }
                else {
                    row++
                }
            }
        }
        
        return verticalMatches
    }
    
    private func fillHorizontalChainForColumn(column: Int, row: Int) -> Chain {
        let chain = Chain(chainType: .Horizontal)
        
        if let cookie = cookies[column, row] {
            var col = column
            if detectHorzontalChainForCookie(cookie) {
                let matchType = cookie.cookieType
                while cookies[col, row]?.cookieType == matchType {
                    chain.addCookie(cookies[col, row]!)
                    col++
                    
                    if col >= LevelConstants.NumColumns {
                        return chain
                    }
                }
            }
        }
        
        return chain
    }
    
    private func fillVerticalChainForColumn(column: Int, row: Int) -> Chain {
        let chain = Chain(chainType: .Vertical)
        
        if let cookie = cookies[column, row] {
            var r = row
            if detectVerticalChainForCookie(cookie) {
                let matchType = cookie.cookieType
                while cookies[column, r]?.cookieType == matchType {
                    chain.addCookie(cookies[column, r]!)
                    r++
                    
                    if r >= LevelConstants.NumRows {
                        return chain
                    }
                }
            }
        }
        
        return chain
    }
    
    private func chainIsValid(chain: Chain) -> Bool {
        return chain.length() >= 3
    }
    
    private func removeCookiesInChains(chains: Set<Chain>) {
        for chain in chains {
            removeCookiesInChain(chain)
        }
    }
    
    private func removeCookiesInChain(chain: Chain) {
        for cookie in chain.cookies {
            cookies[cookie.column, cookie.row] = nil
        }
    }
    
    // MARK: - Swipe cookies
    func performSwap(swap: Swap) {
        swapCookie(swap.cookieA, withCookie: swap.cookieB)
    }
    
    func isPossibleSwap(swap: Swap) -> Bool {
        return possibleSwaps.contains(swap)
    }
    
    private func swapCookie(cookieA: Cookie, withCookie cookieB: Cookie) {
        let columnA = cookieA.column
        let rowA = cookieA.row
        let columnB = cookieB.column
        let rowB = cookieB.row
        
        cookies[columnA, rowA] = cookieB
        cookieB.column = columnA
        cookieB.row = rowA
        
        cookies[columnB, rowB] = cookieA
        cookieA.column = columnB
        cookieA.row = rowB
    }
}
