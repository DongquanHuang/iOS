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
        return createInitialCookies()
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
        } while (findHorzonalChainIfAddCookieType(cookieType, AtColumn: column, row: row) || findVerticalChainIfAddCookieType(cookieType, AtColumn: column, row: row))
        
        return cookieType
    }
    
    private func findHorzonalChainIfAddCookieType(cookieType: CookieType, AtColumn column: Int, row: Int) -> Bool {
        return column >= 2 && cookies[column - 1, row]?.cookieType == cookieType && cookies[column - 2, row]?.cookieType == cookieType
    }
    
    private func findVerticalChainIfAddCookieType(cookieType: CookieType, AtColumn column: Int, row: Int) -> Bool {
        return row >= 2 && cookies[column, row - 1]?.cookieType == cookieType && cookies[column, row - 2]?.cookieType == cookieType
    }
    
    // MARK: - Swipe cookies
    func performSwap(swap: Swap) {
        let cookieA = swap.cookieA
        let cookieB = swap.cookieB
        
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
