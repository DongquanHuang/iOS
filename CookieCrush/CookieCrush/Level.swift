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
    
    var targetScore = 0
    var maximumMoves = 0
    var comboMultiplier = 1
    
    var possibleSwaps = Set<Swap>()
    
    private var cookies = Array2D<Cookie>(columns: LevelConstants.NumColumns, rows: LevelConstants.NumRows)
    private var tiles = Array2D<Tile>(columns: LevelConstants.NumColumns, rows: LevelConstants.NumRows)
    
    // MARK: - Init
    init(filename: String) {
        if let dictionary = LevelFileParser.loadJSONFromBundle(filename) {
            fillTiles(dictionary)
            setTargetScore(dictionary)
            setMaximunMoves(dictionary)
        }
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
        
        repeat {
            cookieSet = createInitialCookies()
            detectPossibleSwaps()
        } while !hasPossbileSwaps()
        
        return cookieSet
    }
    
    // MARK: - Private methods - Fill tiles based on level file
    private func fillTiles(dictionary: Dictionary<String, AnyObject>) {
        if let tilesArray: AnyObject = dictionary["tiles"] {
            for (row, rowArray) in (tilesArray as! [[Int]]).enumerate() {
                let tileRow = LevelConstants.NumRows - row - 1
                for (column, value) in rowArray.enumerate() {
                    if value == 1 {
                        tiles[column, tileRow] = Tile()
                    }
                }
            }
        }
    }
    
    // MARK: - Private methods - Setup target score & max moves
    private func setTargetScore(dictionary: Dictionary<String, AnyObject>) {
        targetScore = dictionary["targetScore"] as! Int
    }
    
    private func setMaximunMoves(dictionary: Dictionary<String, AnyObject>) {
        maximumMoves = dictionary["moves"] as! Int
    }
    
    // MARK: - Private methods - Create cookie based on level file
    private func createInitialCookies() -> Set<Cookie> {
        var cookieSet = Set<Cookie>()
        
        for row in 0 ..< LevelConstants.NumRows {
            for column in 0 ..< LevelConstants.NumColumns {
                
                if tiles[column, row] != nil {
                    let cookieType = getRandomCookieTypeWithoutMakingChainsForColumn(column, row: row)
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
        
        repeat {
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
    func detectPossibleSwaps() {
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
        let swap = Swap(cookieA: cookie, cookieB: neighbour)
        if detectChainIfPerformSwap(swap) {
            possibleSwaps.insert(swap)
        }
    }
    
    private func detectChainIfPerformSwap(swap: Swap) -> Bool {
        var chainDetected = false
        
        performSwap(swap)
        if detectChainForCookie(swap.cookieA) || detectChainForCookie(swap.cookieB) {
            chainDetected = true
        }
        performSwap(swap)
        
        return chainDetected
    }
    
    private func detectChainForCookie(cookie: Cookie) -> Bool {
        return detectHorzontalChainForCookie(cookie) || detectVerticalChainForCookie(cookie)
    }
    
    private func detectHorzontalChainForCookie(cookie: Cookie) -> Bool {
        var horzLength = 1
        horzLength += sameCookieAmountInLeftSideOfCookie(cookie)
        horzLength += sameCookieAmountInRightSideOfCookie(cookie)
        return horzLength >= 3
    }
    
    private func detectVerticalChainForCookie(cookie: Cookie) -> Bool {
        var vertLength = 1
        vertLength += sameCookieAmountInBelowSideOfCookie(cookie)
        vertLength += sameCookieAmountInAboveSideOfCookie(cookie)
        return vertLength >= 3
    }
    
    private func sameCookieAmountInLeftSideOfCookie(cookie: Cookie) -> Int {
        var amount = 0
        
        let cookieType = cookie.cookieType
        for var i = cookie.column - 1; i >= 0 && cookies[i, cookie.row]?.cookieType == cookieType; i--, amount++ {}
        
        return amount
    }
    
    private func sameCookieAmountInRightSideOfCookie(cookie: Cookie) -> Int {
        var amount = 0
        
        let cookieType = cookie.cookieType
        for var i = cookie.column + 1; i < LevelConstants.NumColumns && cookies[i, cookie.row]?.cookieType == cookieType; i++, amount++ {}
        
        return amount
    }
    
    private func sameCookieAmountInBelowSideOfCookie(cookie: Cookie) -> Int {
        var amount = 0
        
        let cookieType = cookie.cookieType
        for var i = cookie.row - 1; i >= 0 && cookies[cookie.column, i]?.cookieType == cookieType; i--, amount++ {}
        
        return amount
    }
    
    private func sameCookieAmountInAboveSideOfCookie(cookie: Cookie) -> Int {
        var amount = 0
        
        let cookieType = cookie.cookieType
        for var i = cookie.row + 1; i < LevelConstants.NumRows && cookies[cookie.column, i]?.cookieType == cookieType; i++, amount++ {}
        
        return amount
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
        
        calculateScores(horizontalChains)
        calculateScores(verticalChains)
        
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
    
    // MARK: - Calculate score
    func calculateScores(chains: Set<Chain>) {
        // 3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on
        for chain in chains {
            chain.score = 60 * (chain.length() - 2) * comboMultiplier
            comboMultiplier++
        }
    }
    
    func resetComboMultiplier() {
        comboMultiplier = 1
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
    
    // MARK: - Fill holes after remove matched cookies
    func fillHoles() -> [[Cookie]] {
        let cookieArrays = cookiesShouldDropDown()
        
        fallDownAllCookies(cookieArrays)
        
        return cookieArrays
    }
    
    private func cookiesShouldDropDown() -> [[Cookie]] {
        var cookieArrays = [[Cookie]]()
        
        for column in 0 ..< LevelConstants.NumColumns {
            if let cookieArray = cookiesAboveTheHoleForColumn(column) {
                cookieArrays.append(cookieArray)
            }
        }
        
        return cookieArrays
    }
    
    private func cookiesAboveTheHoleForColumn(column: Int) -> [Cookie]? {
        let (foundHole, holeRowIndex) = rowIndexForFirstHoleInColume(column)
        if (foundHole) {
            if let cookieArray = cookiesAboveTheRow(holeRowIndex, OfColumn: column) {
                return cookieArray
            }
        }
        
        return nil
    }
    
    private func rowIndexForFirstHoleInColume(column: Int) -> (foundHole: Bool, holeRowIndex: Int) {
        for row in 0 ..< LevelConstants.NumRows {
            if findHoleAtColumn(column, row: row) {
                return (true, row)
            }
        }
        
        return (false, -1)
    }
    
    private func findHoleAtColumn(column: Int, row: Int) -> Bool {
        return tiles[column, row] != nil && cookies[column, row] == nil
    }
    
    private func cookiesAboveTheRow(row: Int, OfColumn column: Int) -> [Cookie]? {
        var cookiesArray = [Cookie]()
        
        for lookup in (row + 1) ..< LevelConstants.NumRows {
            if let cookie = cookies[column, lookup] {
                cookiesArray.append(cookie)
            }
        }
        
        if cookiesArray.count > 0 {
            return cookiesArray
        }
        return nil
    }
    
    private func fallDownAllCookies(cookieArrays: [[Cookie]]) {
        for cookieArray in cookieArrays {
            performFallDownForCookies(cookieArray)
        }
    }
    
    private func performFallDownForCookies(cookieArray: [Cookie]) {
        let column = cookieArray.first!.column
        for cookie in cookieArray {
            let (foundHole, targetRow) = rowIndexForFirstHoleInColume(column)
            if foundHole {
                cookies[column, cookie.row] = nil
                cookie.row = targetRow
                cookies[column, cookie.row] = cookie
            }
        }
    }
    
    // MARK: Supply new cookies
    func supplyNewCookies() -> [[Cookie]] {
        var newCookieArrays = [[Cookie]]()
        
        let columns = columnsWithHole()
        for column in columns {
            let newCookieArray = supplyNewCookiesForColumn(column)
            newCookieArrays.append(newCookieArray)
        }
        
        return newCookieArrays
    }
    
    private func columnsWithHole() -> [Int] {
        var columns = [Int]()
        
        for column in 0 ..< LevelConstants.NumColumns {
            let (found, _) = rowIndexForFirstHoleInColume(column)
            if found {
                columns.append(column)
            }
        }
        
        return columns
    }
    
    private func supplyNewCookiesForColumn(column: Int) -> [Cookie] {
        var cookies = [Cookie]()
        
        let (found, holeRowIndex) = rowIndexForFirstHoleInColume(column)
        if found {
            for row in holeRowIndex ..< LevelConstants.NumRows {
                if findHoleAtColumn(column, row: row) {
                    let cookie = addNewCookieIntoColumn(column, row: row)
                    cookies.append(cookie)
                }
            }
        }
        
        return cookies
    }
    
    private func addNewCookieIntoColumn(column: Int, row: Int) -> Cookie {
        let cookieType = CookieType.random()
        let cookie = Cookie(column: column, row: row, cookieType: cookieType)
        cookies[column, row] = cookie
        return cookie
    }
    
}
