//
//  GameSceneTests.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/10/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest
import SpriteKit

class GameSceneTests: XCTestCase {
    
    var gameScene = GameScene(size: CGSize(width: 640, height: 1136))
    
    var cookie1: Cookie?
    var cookie1Type = CookieType.Croissant
    var cookies = Set<Cookie>()
    
    var mockGameScene = MockGameScene(size: CGSize(width: 100, height: 100))
    var mockTouch = MockUITouch()
    var touches = Set<NSObject>()
    
    static let expectedCol = 5
    static let expectedRow = 4
    static let point = CGPoint(x: GameScene.GameSceneConstants.TileWidth * CGFloat(GameSceneTests.expectedCol) + 1, y: GameScene.GameSceneConstants.TileHeight * CGFloat(GameSceneTests.expectedRow) + 1)
    
    class MockUITouch: UITouch {
        override func locationInNode(node: SKNode!) -> CGPoint {
            return GameSceneTests.point
        }
    }
    
    class MockLevel: Level {
        var cookie: Cookie?
        
        override func cookieAtColumn(column: Int, row: Int) -> Cookie? {
            if cookie == nil {
                cookie = Cookie(column: 5, row: 4, cookieType: .Croissant)
                let sprite = SKSpriteNode(imageNamed: cookie!.cookieType.spriteName)
                cookie!.sprite = sprite
            }
            
            return cookie
        }
    }
    
    class MockLevel2: Level {
        override func cookieAtColumn(column: Int, row: Int) -> Cookie? {
            return nil
        }
    }
    
    class MockGameScene: GameScene {
        var horzontalDelta = 0
        var verticalDelta = 0
        
        override func trySwapHorizontal(horzDelta: Int, vertical vertDelta: Int) {
            horzontalDelta = horzDelta
            verticalDelta = vertDelta
        }
    }
    
    var mockSwipeHandlerGetsCalled = false
    func mockSwipeHander(swap: Swap) {
        mockSwipeHandlerGetsCalled = true
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cookie1 = Cookie(column: 5, row: 4, cookieType: cookie1Type)
        cookies.insert(cookie1!)
        
        touches.insert(mockTouch)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAnchorPointIsSetCorrectly() {
        XCTAssertTrue(gameScene.anchorPoint == CGPoint(x: 0.5, y: 0.5))
    }
    
    func testBackgroundAddedAsFirstNode() {
        let nodes = gameScene.children as! [SKNode]
        let background = nodes.first
        XCTAssertTrue(background != nil)
    }
    
    func testGameSceneHasGameLayerProperty() {
        XCTAssertTrue(gameScene.gameLayer.isKindOfClass(SKNode) == true)
    }
    
    func testGameSceneHasCookiesLayerProperty() {
        XCTAssertTrue(gameScene.cookiesLayer.isKindOfClass(SKNode) == true)
    }
    
    func testGameSceneHasGameLayerAsItsChildNode() {
        let nodes = gameScene.children as! [SKNode]
        let gameLayer = nodes[1]
        XCTAssertTrue(gameScene.gameLayer == gameLayer)
    }
    
    func testCookiesLayerPositionIsCorrect() {
        let expectedPosition = CGPoint(x: -GameScene.GameSceneConstants.TileWidth * CGFloat(LevelConstants.NumColumns) / 2, y: -GameScene.GameSceneConstants.TileHeight * CGFloat(LevelConstants.NumRows) / 2)
        XCTAssertTrue(gameScene.cookiesLayer.position == expectedPosition)
    }
    
    func testGameLayerHasCookiesLayerAsItsSecondChildNode() {
        let nodes = gameScene.gameLayer.children as! [SKNode]
        let cookiesLayer = nodes[1]
        XCTAssertTrue(cookiesLayer == gameScene.cookiesLayer)
    }
    
    func testCanAddSpritesForCookies() {
        gameScene.addSpritesForCookies(cookies)
        XCTAssertTrue(cookie1?.sprite != nil)
    }
    
    func testCookieSpriteIsAddedIntoCookiesLayer() {
        gameScene.addSpritesForCookies(cookies)
        let nodes = gameScene.cookiesLayer.children as! [SKNode]
        XCTAssertTrue(nodes.count == cookies.count)
    }
    
    func testCookieSpritePositionIsSetCorrectly() {
        let expectedPostion = CGPoint(x: CGFloat(cookie1!.column) * GameScene.GameSceneConstants.TileWidth + GameScene.GameSceneConstants.TileWidth / 2, y: CGFloat(cookie1!.row) * GameScene.GameSceneConstants.TileHeight + GameScene.GameSceneConstants.TileHeight / 2)
        gameScene.addSpritesForCookies(cookies)
        XCTAssertTrue(cookie1!.sprite?.position == expectedPostion)
    }
    
    func testGameSceneHasTilesLayerProperty() {
        XCTAssertNotNil(gameScene.tilesLayer)
    }
    
    func testTilesLayerPositionIsCorrect() {
        let expectedPosition = CGPoint(x: -GameScene.GameSceneConstants.TileWidth * CGFloat(LevelConstants.NumColumns) / 2, y: -GameScene.GameSceneConstants.TileHeight * CGFloat(LevelConstants.NumRows) / 2)
        XCTAssertTrue(gameScene.tilesLayer.position == expectedPosition)
    }
    
    func testGameLayerHasTilesLayerAsItsFirstChildNode() {
        let nodes = gameScene.gameLayer.children as! [SKNode]
        let tilesLayer = nodes.first
        XCTAssertTrue(tilesLayer == gameScene.tilesLayer)
    }
    
    func testCanAddTilesIntoTilesLayer() {
        gameScene.level = Level(filename: "Level_0")
        gameScene.addTiles()
        XCTAssertTrue(gameScene.tilesLayer.children.count == 9)
    }
    
    func testTileSpritePositionIsSetCorrectly() {
        let expectedPostion = CGPoint(x: CGFloat(3) * GameScene.GameSceneConstants.TileWidth + GameScene.GameSceneConstants.TileWidth / 2, y: CGFloat(3) * GameScene.GameSceneConstants.TileHeight + GameScene.GameSceneConstants.TileHeight / 2)
        
        gameScene.level = Level(filename: "Level_0")
        gameScene.addTiles()
        
        let tile = gameScene.tilesLayer.children.first as! SKSpriteNode
        
        XCTAssertTrue(tile.position == expectedPostion)
    }

    func testSwipeFromRowAndColumnAreNilAfterGameSceneInit() {
        XCTAssertNil(gameScene.swipeFromRow)
        XCTAssertNil(gameScene.swipeFromColumn)
    }
    
    func testConvertInvalidPointToColumnAndRowReturnsFalseTupleWithColumnAndRowSetToZero() {
        let point = CGPoint(x: 9999, y: -9)
        let result = gameScene.convertPointToColumnAndRow(point)
        XCTAssertTrue(result.success == false)
        XCTAssertTrue(result.column == 0)
        XCTAssertTrue(result.row == 0)
    }
    
    func testConvertValidPointToColumnAndRowReturnsTrueTupleWithCorrectColumnAndRow() {
        let result = gameScene.convertPointToColumnAndRow(GameSceneTests.point)
        XCTAssertTrue(result.success == true)
        println("Row: \(result.row), Col: \(result.column)")
        XCTAssertTrue(result.column == GameSceneTests.expectedCol)
        XCTAssertTrue(result.row == GameSceneTests.expectedRow)
    }
    
    func testTouchesBeganWillSetSwipeColumnAndRow() {
        gameScene.level = MockLevel(filename: "filename")
        
        gameScene.touchesBegan(touches, withEvent: UIEvent())
        
        XCTAssertTrue(gameScene.swipeFromColumn == 5)
        XCTAssertTrue(gameScene.swipeFromRow == 4)
    }
    
    func testTouchesMovedToLeft() {
        mockGameScene.swipeFromColumn = 4
        mockGameScene.swipeFromRow = 4
        
        mockGameScene.level = MockLevel(filename: "filename")
        
        mockGameScene.touchesMoved(touches, withEvent: UIEvent())
        XCTAssertTrue(mockGameScene.horzontalDelta == 1)
        XCTAssertTrue(mockGameScene.verticalDelta == 0)
    }
    
    func testTouchesMovedToRight() {
        mockGameScene.swipeFromColumn = 6
        mockGameScene.swipeFromRow = 4
        
        mockGameScene.level = MockLevel(filename: "filename")
        
        mockGameScene.touchesMoved(touches, withEvent: UIEvent())
        XCTAssertTrue(mockGameScene.horzontalDelta == -1)
        XCTAssertTrue(mockGameScene.verticalDelta == 0)
    }
    
    func testTouchesMovedUpside() {
        mockGameScene.swipeFromColumn = 5
        mockGameScene.swipeFromRow = 3
        
        mockGameScene.level = MockLevel(filename: "filename")
        
        mockGameScene.touchesMoved(touches, withEvent: UIEvent())
        XCTAssertTrue(mockGameScene.horzontalDelta == 0)
        XCTAssertTrue(mockGameScene.verticalDelta == 1)
    }
    
    func testTouchesMovedDownside() {
        mockGameScene.swipeFromColumn = 5
        mockGameScene.swipeFromRow = 5
        
        mockGameScene.level = MockLevel(filename: "filename")
        
        mockGameScene.touchesMoved(touches, withEvent: UIEvent())
        XCTAssertTrue(mockGameScene.horzontalDelta == 0)
        XCTAssertTrue(mockGameScene.verticalDelta == -1)
    }
    
    func testTouchesMovedWillNotPerformSwipeIfNotMoveOutside() {
        mockGameScene.horzontalDelta = -10
        mockGameScene.verticalDelta = -10
        
        mockGameScene.swipeFromColumn = 5
        mockGameScene.swipeFromRow = 4
        
        mockGameScene.level = MockLevel(filename: "filename")
        
        mockGameScene.touchesMoved(touches, withEvent: UIEvent())
        XCTAssertTrue(mockGameScene.horzontalDelta == -10)
        XCTAssertTrue(mockGameScene.verticalDelta == -10)
    }
    
    func testTouchesMovedWillIgnoreMoveEventIfSwipeFromInvalidPosition() {
        mockGameScene.horzontalDelta = -10
        mockGameScene.verticalDelta = -10
        
        mockGameScene.level = MockLevel(filename: "filename")
        
        mockGameScene.touchesMoved(touches, withEvent: UIEvent())
        XCTAssertTrue(mockGameScene.horzontalDelta == -10)
        XCTAssertTrue(mockGameScene.verticalDelta == -10)
    }
    
    func testTouchesMovedWillSetSwipeColumnAndRowBackToNilWhenSuccessfulMoveEnds() {
        mockGameScene.swipeFromColumn = 5
        mockGameScene.swipeFromRow = 5
        
        mockGameScene.level = MockLevel(filename: "filename")
        
        mockGameScene.touchesMoved(touches, withEvent: UIEvent())
        
        XCTAssertNil(mockGameScene.swipeFromColumn)
        XCTAssertNil(mockGameScene.swipeFromRow)
    }
    
    func testTouchesMovedWillNotResetSwipeColumnAndRowIfMoveInsideOneCookie() {
        mockGameScene.swipeFromColumn = 5
        mockGameScene.swipeFromRow = 4
        
        mockGameScene.level = MockLevel(filename: "filename")
        
        mockGameScene.touchesMoved(touches, withEvent: UIEvent())
        
        XCTAssertTrue(mockGameScene.swipeFromColumn == 5)
        XCTAssertTrue(mockGameScene.swipeFromRow == 4)
        
    }
    
    func testTouchesEndWillResetSwipeColumnAndRow() {
        gameScene.swipeFromColumn = 5
        gameScene.swipeFromRow = 4
        gameScene.touchesEnded(touches, withEvent: UIEvent())
        XCTAssertNil(mockGameScene.swipeFromColumn)
        XCTAssertNil(mockGameScene.swipeFromRow)
    }
    
    func testTouchesCancelledWillResetSwipeColumnAndRow() {
        gameScene.swipeFromColumn = 5
        gameScene.swipeFromRow = 4
        gameScene.touchesCancelled(touches, withEvent: UIEvent())
        XCTAssertNil(mockGameScene.swipeFromColumn)
        XCTAssertNil(mockGameScene.swipeFromRow)
    }
    
    func testGameSceneHaseSwipeHandlerAndItsNilByDefault() {
        XCTAssertTrue(gameScene.swipeHandler == nil)
    }
    
    func testSwipeHandlerIsCalledForValidSwipe() {
        gameScene.swipeHandler = mockSwipeHander
        
        gameScene.swipeFromColumn = 5
        gameScene.swipeFromRow = 5
        
        gameScene.level = MockLevel(filename: "filename")
        
        gameScene.touchesMoved(touches, withEvent: UIEvent())
        XCTAssertTrue(mockSwipeHandlerGetsCalled == true)
    }
    
    func testSwipeHanderIsNotCalledForSwipeOutsideCase() {
        gameScene.swipeHandler = mockSwipeHander
        
        gameScene.swipeFromColumn = 8
        gameScene.swipeFromRow = 8
        
        gameScene.trySwapHorizontal(1, vertical: 0)
        XCTAssertTrue(mockSwipeHandlerGetsCalled == false)
    }
    
    func testSwipeHanderIsNotCalledForSwipeToHoleCase() {
        gameScene.swipeHandler = mockSwipeHander
        gameScene.level = MockLevel2(filename: "filename")
        
        gameScene.swipeFromColumn = 8
        gameScene.swipeFromRow = 8
        
        gameScene.trySwapHorizontal(-1, vertical: 0)
        XCTAssertTrue(mockSwipeHandlerGetsCalled == false)
    }
    
    func testSelectedCookieIsHighlighted() {
        gameScene.level = MockLevel(filename: "filename")
        let cookie = gameScene.level.cookieAtColumn(5, row: 4)
        
        gameScene.touchesBegan(touches, withEvent: UIEvent())
        
        XCTAssertTrue(cookie?.sprite?.children.count == 1)
    }
    
    func testTouchesEndedWillRemoveHighlightedTexture() {
        gameScene.level = MockLevel(filename: "filename")
        let cookie = gameScene.level.cookieAtColumn(5, row: 4)
        
        gameScene.touchesBegan(touches, withEvent: UIEvent())
        gameScene.touchesEnded(touches, withEvent: UIEvent())
        
        XCTAssertTrue(cookie?.sprite?.children.count == 0)
    }
    
    func testTouchesCancelledWillRemoveHighlightedTexture() {
        gameScene.level = MockLevel(filename: "filename")
        let cookie = gameScene.level.cookieAtColumn(5, row: 4)
        
        gameScene.touchesBegan(touches, withEvent: UIEvent())
        gameScene.touchesCancelled(touches, withEvent: UIEvent())
        
        XCTAssertTrue(cookie?.sprite?.children.count == 0)
    }
    
    func testTouchesMovedShouldRemoveHighlightedTexture() {
        gameScene.level = MockLevel(filename: "filename")
        let cookie = gameScene.level.cookieAtColumn(5, row: 4)
        
        gameScene.touchesBegan(touches, withEvent: UIEvent())
        
        gameScene.swipeFromColumn = 5
        gameScene.swipeFromRow = 5
        gameScene.touchesMoved(touches, withEvent: UIEvent())
        
        XCTAssertTrue(cookie?.sprite?.children.count == 0)
    }
    
    func testRemoveAllCookieSpritesWillRemoveAll() {
        gameScene.addSpritesForCookies(cookies)
        gameScene.removeAllCookieSprites()
        let nodes = gameScene.cookiesLayer.children as! [SKNode]
        XCTAssertTrue(nodes.count == 0)
    }
    
    func testRemoveAllTileSpritesWillRemoveAll() {
        gameScene.level = Level(filename: "Level_0")
        gameScene.addTiles()
        gameScene.removeAllTileSprites()
        let nodes = gameScene.tilesLayer.children as! [SKNode]
        XCTAssertTrue(nodes.count == 0)
    }

}
