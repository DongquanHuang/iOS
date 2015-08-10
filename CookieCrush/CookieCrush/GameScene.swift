//
//  GameScene.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/10/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: - Constants
    struct GameSceneConstants {
        static let TileWidth: CGFloat = 32.0
        static let TileHeight: CGFloat = 36.0
    }
    
    // MARK: - Variables
    var level: Level!
    
    let gameLayer = SKNode()
    let cookiesLayer = SKNode()
    
    // MARK: - Init method
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        setAnchorPointToMiddle()
        addBackgroundNode()
        addGameLayer()
        configureCookiesLayerPosition()
        addCookiesLayerIntoGameLayer()
    }
    
    private func setAnchorPointToMiddle() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    private func addBackgroundNode() {
        let background = SKSpriteNode(imageNamed: "Background")
        addChild(background)
    }
    
    private func addGameLayer() {
        addChild(gameLayer)
    }
    
    private func configureCookiesLayerPosition() {
        let layerPosition = CGPoint(x: -GameSceneConstants.TileWidth * CGFloat(LevelConstants.NumColumns) / 2, y: -GameSceneConstants.TileHeight * CGFloat(LevelConstants.NumRows) / 2)
        cookiesLayer.position = layerPosition
    }
    
    private func addCookiesLayerIntoGameLayer() {
        gameLayer.addChild(cookiesLayer)
    }
    
    // MARK: - 
    func addSpritesForCookies(cookies: Set<Cookie>) {
        for cookie in cookies {
            let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
            sprite.position = pointForColumn(cookie.column, row: cookie.row)
            cookie.sprite = sprite
            cookiesLayer.addChild(sprite)
        }
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * GameSceneConstants.TileWidth + GameSceneConstants.TileWidth / 2,
            y: CGFloat(row) * GameSceneConstants.TileHeight + GameSceneConstants.TileHeight / 2)
    }
}
