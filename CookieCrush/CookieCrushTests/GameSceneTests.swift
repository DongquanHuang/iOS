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

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cookie1 = Cookie(column: 3, row: 3, cookieType: cookie1Type)
        cookies.insert(cookie1!)
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
        gameScene.level = Level(filename: "Level_4")
        gameScene.addTiles()
        XCTAssertTrue(gameScene.tilesLayer.children.count == 9)
    }
    
    func testTileSpritePositionIsSetCorrectly() {
        let expectedPostion = CGPoint(x: CGFloat(3) * GameScene.GameSceneConstants.TileWidth + GameScene.GameSceneConstants.TileWidth / 2, y: CGFloat(3) * GameScene.GameSceneConstants.TileHeight + GameScene.GameSceneConstants.TileHeight / 2)
        
        gameScene.level = Level(filename: "Level_4")
        gameScene.addTiles()
        
        let tile = gameScene.tilesLayer.children.first as! SKSpriteNode
        
        XCTAssertTrue(tile.position == expectedPostion)
    }


}
