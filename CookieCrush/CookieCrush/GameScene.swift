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
    
    struct AdaptConstants {
        // 320.0: screen width for iPhone devices before iPhone6
        static let NormalPhoneWidth: CGFloat = 320.0
    }
    lazy var scaleFactor: CGFloat! = {
        return self.size.width / AdaptConstants.NormalPhoneWidth
    }()
    
    // MARK: - Variables
    var level: Level!
    
    let gameLayer = SKNode()
    let tilesLayer = SKNode()
    let cookiesLayer = SKNode()
    
    var swipeFromColumn: Int?
    var swipeFromRow: Int?
    var swipeHandler: ((Swap) -> ())?
    
    var selectionSprite = SKSpriteNode()
    
    // Note: below sound variables are not covered by unit test
    let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
    let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
    let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
    let fallingCookieSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
    let addCookieSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
    
    // MARK: - Init method
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        setAnchorPointToMiddle()
        addBackgroundNode()
        addGameLayer()
        addOtherLayersIntoGameLayer()
    }
    
    override func addChild(node: SKNode) {
        node.setScale(scaleFactor)
        super.addChild(node)
    }
    
    private func setAnchorPointToMiddle() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    private func addBackgroundNode() {
        let background = SKSpriteNode(imageNamed: "Background")
        addChild(background)
    }
    
    private func addGameLayer() {
        gameLayer.hidden = true
        addChild(gameLayer)
    }
    
    private func addOtherLayersIntoGameLayer() {
        configureTilesLayerPosition()
        addTilesLayerIntoGameLayer()
        
        configureCookiesLayerPosition()
        addCookiesLayerIntoGameLayer()
    }
    
    private func configureTilesLayerPosition() {
        tilesLayer.position = commonLayerPosition()
    }
    
    private func addTilesLayerIntoGameLayer() {
        gameLayer.addChild(tilesLayer)
    }
    
    private func configureCookiesLayerPosition() {
        cookiesLayer.position = commonLayerPosition()
    }
    
    private func addCookiesLayerIntoGameLayer() {
        gameLayer.addChild(cookiesLayer)
    }
    
    private func commonLayerPosition() -> CGPoint {
        return CGPoint(x: -GameSceneConstants.TileWidth * CGFloat(LevelConstants.NumColumns) / 2, y: -GameSceneConstants.TileHeight * CGFloat(LevelConstants.NumRows) / 2)
    }
    
    // MARK: - Add Tiles & Cookies
    func addTiles() {
        for row in 0 ..< LevelConstants.NumRows {
            for column in 0 ..< LevelConstants.NumColumns {
                if let _ = level.tileAtColumn(column, row: row) {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.position = pointForColumn(column, row: row)
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    func removeAllTileSprites() {
        tilesLayer.removeAllChildren()
    }
    
    func addSpritesForCookies(cookies: Set<Cookie>) {
        for cookie in cookies {
            let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
            sprite.position = pointForColumn(cookie.column, row: cookie.row)
            cookie.sprite = sprite
            cookiesLayer.addChild(sprite)
            
            animateAddingSprites(sprite)
        }
    }
    
    func removeAllCookieSprites() {
        cookiesLayer.removeAllChildren()
    }
    
    // MARK: - Convert points
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * GameSceneConstants.TileWidth + GameSceneConstants.TileWidth / 2,
            y: CGFloat(row) * GameSceneConstants.TileHeight + GameSceneConstants.TileHeight / 2)
    }
    
    func convertPointToColumnAndRow(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if pointInsideCookiesLayer(point) {
            return (true, Int(point.x / GameSceneConstants.TileWidth), Int(point.y / GameSceneConstants.TileHeight))
        }
        return (false, 0, 0)
    }
    
    private func pointInsideCookiesLayer(point: CGPoint) -> Bool {
        return point.x >= 0 && point.x < rangeOfCookiesLayer().width && point.y >= 0 && point.y < rangeOfCookiesLayer().height
    }
    
    private func rangeOfTilesLayer() -> (width: CGFloat, height: CGFloat) {
        let widthOfLayer = CGFloat(LevelConstants.NumColumns) * GameSceneConstants.TileWidth
        let heightOfLayer = CGFloat(LevelConstants.NumRows) * GameSceneConstants.TileHeight
        
        return (widthOfLayer, heightOfLayer)
    }
    
    private func rangeOfCookiesLayer() -> (width: CGFloat, height: CGFloat) {
        return rangeOfTilesLayer()
    }
    
    // MARK: - Handle touches
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location = locationInCookiesLayerFromTouch(touches)
        setSwipeStartPosition(location)
        highlightSelectedCookie()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if moveStartsFromValidPosition() == false {
            return
        }
        
        let location = locationInCookiesLayerFromTouch(touches)
        let (horzontalDelta, verticalDelta) = getMoveDelta(location)
        
        if horzontalDelta != 0 || verticalDelta != 0 {
            trySwapHorizontal(horzontalDelta, vertical: verticalDelta)
            cancelHighlightSelectionIndication()
            resetSwipeStartPosition()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        cancelHighlightSelectionIndication()
        resetSwipeStartPosition()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touchesEnded(touches!, withEvent: event)
    }
    
    private func locationInCookiesLayerFromTouch(touches: Set<NSObject>) -> CGPoint {
        let touch = touches.first as! UITouch
        return touch.locationInNode(cookiesLayer)
    }
    
    private func setSwipeStartPosition(location: CGPoint) {
        let (column, row) = getCookieIndexForTouchPosition(location)
        swipeFromColumn = column
        swipeFromRow = row
    }
    
    private func getCookieIndexForTouchPosition(location: CGPoint) -> (column: Int?, row: Int?) {
        var cookieColumn: Int?
        var cookieRow: Int?
        
        let (success, column, row) = convertPointToColumnAndRow(location)
        if success {
            if let _ = level.cookieAtColumn(column, row: row) {
                cookieColumn = column
                cookieRow = row
            }
        }
        
        return (cookieColumn, cookieRow)
    }
    
    private func moveStartsFromValidPosition() -> Bool {
        return swipeFromColumn != nil && swipeFromRow != nil
    }
    
    private func getMoveDelta(location: CGPoint) -> (horzontalDelta: Int, verticalDelta: Int) {
        var horzDelta = 0, vertDelta = 0
        
        let (newColumn, newRow) = getCookieIndexForTouchPosition(location)
        if newColumn != nil && newRow != nil {
            if newColumn! < swipeFromColumn! {          // swipe left
                horzDelta = -1
            } else if newColumn! > swipeFromColumn! {   // swipe right
                horzDelta = 1
            } else if newRow! < swipeFromRow! {         // swipe down
                vertDelta = -1
            } else if newRow! > swipeFromRow! {         // swipe up
                vertDelta = 1
            }
        }
        
        return (horzDelta, vertDelta)
    }
    
    private func resetSwipeStartPosition() {
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    // MARK: - Highlight the cookie
    private func highlightSelectedCookie() {
        if moveStartsFromValidPosition() {
            if let selectedCookie = level.cookieAtColumn(swipeFromColumn!, row: swipeFromRow!) {
                addHighlightedTextureToSpriteOfCookie(selectedCookie)
            }
        }
    }
    
    private func addHighlightedTextureToSpriteOfCookie(selectedCookie: Cookie) {
        let texture = SKTexture(imageNamed: selectedCookie.cookieType.highlightedSpriteName)
        selectionSprite.size = texture.size()
        selectionSprite.runAction(SKAction.setTexture(texture))
        
        selectedCookie.sprite!.addChild(selectionSprite)
        selectionSprite.alpha = 1.0
    }
    
    private func cancelHighlightSelectionIndication() {
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
    }
    
    // MARK: - Swipe cookies
    func trySwapHorizontal(horzDelta: Int, vertical vertDelta: Int) {
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta
        
        if toColumn < 0 || toColumn >= LevelConstants.NumColumns { return }
        if toRow < 0 || toRow >= LevelConstants.NumRows { return }
        
        if let toCookie = level.cookieAtColumn(toColumn, row: toRow) {
            if let fromCookie = level.cookieAtColumn(swipeFromColumn!, row: swipeFromRow!) {
                if let handler = swipeHandler {
                    let swap = Swap(cookieA: fromCookie, cookieB: toCookie)
                    handler(swap)
                }
            }
        }
    }
    
    // TODO: Below functions are not covered by unit test
    func animateSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.3
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        
        spriteA.runAction(moveA, completion: completion)
        spriteB.runAction(moveB)
        
        playSoundAction(swapSound)
    }
    
    func animateInvalidSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.2
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        
        spriteA.runAction(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.runAction(SKAction.sequence([moveB, moveA]))
        
        playSoundAction(invalidSwapSound)
    }
    
    func animateMatchedCookies(chains: Set<Chain>, completion: () -> ()) {
        for chain in chains {
            animateScoreForChain(chain)
            removeMatchedCookiesInChain(chain)
        }
        playSoundAction(matchSound)
        runAction(SKAction.waitForDuration(0.3), completion: completion)
    }
    
    func animateFallingCookies(columns: [[Cookie]], completion: () -> ()) {
        var longestDuration: NSTimeInterval = 0
        
        for array in columns {
            for (idx, cookie) in array.enumerate() {
                let newPosition = pointForColumn(cookie.column, row: cookie.row)
                let delay = 0.05 + 0.15 * NSTimeInterval(idx)
                let sprite = cookie.sprite!
                let duration = NSTimeInterval(((sprite.position.y - newPosition.y) / GameSceneConstants.TileHeight) * 0.1)
                longestDuration = max(longestDuration, duration + delay)
                
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                sprite.runAction(
                    SKAction.sequence([
                        SKAction.waitForDuration(delay),
                        SKAction.group([moveAction, fallingCookieSound])]))
            }
        }
        
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
    }
    
    func animateNewCookies(columns: [[Cookie]], completion: () -> ()) {
        var longestDuration: NSTimeInterval = 0
        
        for array in columns {
            for (idx, cookie) in array.enumerate() {
                let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
                sprite.position = pointForColumn(cookie.column, row: LevelConstants.NumRows)
                cookiesLayer.addChild(sprite)
                cookie.sprite = sprite
                
                let newPosition = pointForColumn(cookie.column, row: cookie.row)
                let delay = 0.1 + 0.2 * NSTimeInterval(idx)
                let duration = NSTimeInterval(((sprite.position.y - newPosition.y) / GameSceneConstants.TileHeight) * 0.1)
                longestDuration = max(longestDuration, duration + delay)
                
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                sprite.alpha = 0
                sprite.runAction(
                    SKAction.sequence([
                        SKAction.waitForDuration(delay),
                        SKAction.group([
                            SKAction.fadeInWithDuration(0.05),
                            moveAction,
                            addCookieSound])
                        ]))
            }
        }
        
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
    }
    
    func animateScoreForChain(chain: Chain) {
        // Figure out what the midpoint of the chain is.
        let firstSprite = chain.firstCookie().sprite!
        let lastSprite = chain.lastCookie().sprite!
        let centerPosition = CGPoint(
            x: (firstSprite.position.x + lastSprite.position.x)/2,
            y: (firstSprite.position.y + lastSprite.position.y)/2 - 8)
        
        // Add a label for the score that slowly floats up.
        let scoreLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
        scoreLabel.fontSize = 16
        scoreLabel.text = String(format: "%ld", chain.score)
        scoreLabel.position = centerPosition
        scoreLabel.zPosition = 300
        cookiesLayer.addChild(scoreLabel)
        
        let moveAction = SKAction.moveBy(CGVector(dx: 0, dy: 3), duration: 0.7)
        moveAction.timingMode = .EaseOut
        scoreLabel.runAction(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
    }
    
    func animateGameOver(completion: () -> ()) {
        let action = SKAction.moveBy(CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .EaseIn
        gameLayer.runAction(action, completion: completion)
    }
    
    func animateBeginGame(completion: () -> ()) {
        gameLayer.hidden = false
        gameLayer.position = CGPoint(x: 0, y: size.height)
        let action = SKAction.moveBy(CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .EaseOut
        gameLayer.runAction(action, completion: completion)
    }
    
    private func removeMatchedCookiesInChain(chain: Chain) {
        for cookie in chain.cookies {
            if let sprite = cookie.sprite {
                if sprite.actionForKey("removing") == nil {
                    let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
                    scaleAction.timingMode = .EaseOut
                    sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                        withKey:"removing")
                }
            }
        }
    }
    
    private func playSoundAction(soundAction: SKAction) {
        runAction(soundAction)
    }
    
    private func animateAddingSprites(sprite: SKSpriteNode) {
        sprite.alpha = 0
        sprite.xScale = 0.5
        sprite.yScale = 0.5
        
        sprite.runAction(
            SKAction.sequence([
                SKAction.waitForDuration(0.25, withRange: 0.5),
                SKAction.group([
                    SKAction.fadeInWithDuration(0.25),
                    SKAction.scaleTo(1.0, duration: 0.25)
                    ])
                ]))
    }
    
}
