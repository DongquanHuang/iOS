//
//  GameScene.swift
//  UberJump
//
//  Created by Peter Huang on 8/20/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Constants
    struct AdaptConstants {
        // 320.0: screen width for iPhone devices before iPhone6
        static let NormalPhoneWidth: CGFloat = 320.0
    }
    
    struct GraphicsConstants {
        // The whole background image is devided into 20 parts
        static let NumberOfBackgroundImages = 20
        // The image height of splited background images
        static let HeightOfSplitedBackgroundImage: CGFloat = 64.0
        
        static let InitialPlayerPositionY: CGFloat = 80.0
        static let TapToStartPositionY: CGFloat = 180.0
        
        static let NumberOfMidgroundSprites = 10
        static let GapBetweenMidgroundSprites: CGFloat = 500.0
        
        static let ParallaxalizationThreshold: CGFloat = 200.0
        static let BackgroundParallaxalizationSpeed: CGFloat = 1.0 / 10.0
        static let MidgroundParallaxalizationSpeed: CGFloat = 1.0 / 4.0
        static let ForegroundParallaxalizationSpeed: CGFloat = 1.0
    }
    
    struct PhysicsConstants {
        static let GameGravity = CGVector(dx: 0.0, dy: -2.0)
        static let InitialImpulse = CGVector(dx: 0.0, dy: 20.0)
    }
    
    struct NodeNameConstants {
        static let StarNodeName = "NODE_STAR"
        static let PlatformNodeName = "NODE_PLATFORM"
    }
    
    // MARK: - Variables
    var backgroundNode: SKNode!
    var midgroundNode: SKNode!
    var foregroundNode: SKNode!
    var hudNode: SKNode!
    var player: SKNode!
    var tapToStartNode: SKNode!
    
    var currentLevel = LevelConstants.StartLevel
    var levelLoader = GameLevelLoader()
    var gameLevel: GameLevel?
    
    // Adapt for all iPhone devices
    lazy var scaleFactor: CGFloat! = {
        return self.size.width / AdaptConstants.NormalPhoneWidth
    }()
    
    // MARK: - init methods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        loadGameLevel()
        
        setupGravity()
        setupContactDelegate()
        
        setupBackground()
        setupMidground()
        setupForeground()
        addPlayerIntoForeground()
        setupHud()
    }
    
    // MARK: - Load game level
    private func loadGameLevel() {
        gameLevel = levelLoader.loadLevel(currentLevel)
    }
    
    func goToNextLevel() {
        currentLevel++
    }
    
    // MARK: - Setup gravity for the game
    private func setupGravity() {
        physicsWorld.gravity = PhysicsConstants.GameGravity
    }
    
    // MARK: - Setup contact delegate
    private func setupContactDelegate() {
        physicsWorld.contactDelegate = self
    }
    
    // MARK: - Add background for the game
    private func setupBackground() {
        backgroundColor = SKColor.whiteColor()
        backgroundNode = createBackgourndNode()
        addChild(backgroundNode)
    }
    
    private func createBackgourndNode() -> SKNode {
        let bgNode = SKNode()
        
        for i in 1 ... GraphicsConstants.NumberOfBackgroundImages {
            let node = SKSpriteNode(imageNamed:String(format: "Background%02d", i))
            
            node.setScale(scaleFactor)
            node.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            node.position = CGPoint(x: midOfScreenWidth(), y: GraphicsConstants.HeightOfSplitedBackgroundImage * CGFloat(i - 1) * scaleFactor)
            
            bgNode.addChild(node)
        }
        
        return bgNode
    }
    
    // MARK: - Add midground for the game
    private func setupMidground() {
        midgroundNode = SKNode()
        addChild(midgroundNode)
        
        addMidgroundSprites()
    }
    
    private func addMidgroundSprites() {
        var spriteName: String
        var anchor: CGPoint!
        var xPosition: CGFloat!
        
        for i in 0 ..< GraphicsConstants.NumberOfMidgroundSprites {
            let r = arc4random() % 2
            if r > 0 {
                spriteName = "BranchRight"
                anchor = CGPoint(x: 1.0, y: 0.5)
                xPosition = self.size.width
            } else {
                spriteName = "BranchLeft"
                anchor = CGPoint(x: 0.0, y: 0.5)
                xPosition = 0.0
            }
            
            let branchNode = SKSpriteNode(imageNamed: spriteName)
            branchNode.anchorPoint = anchor
            branchNode.position = CGPoint(x: xPosition, y: GraphicsConstants.GapBetweenMidgroundSprites * CGFloat(i))
            midgroundNode.addChild(branchNode)
        }
    }
    
    // MARK: - Add foreground for the game
    private func setupForeground() {
        foregroundNode = SKNode()
        addChild(foregroundNode)
        
        addPlatformsIntoForeground()
        addStarsIntoForeground()
    }
    
    // MARK: - Add player for the game
    private func addPlayerIntoForeground() {
        player = createPlayer()
        foregroundNode.addChild(player)
    }
    
    private func createPlayer() -> SKNode {
        let playerNode = SKNode()
        
        setupInitialPositionForPlayer(playerNode)
        let sprite = addSpriteForPlayer(playerNode)
        setupPhysicsForPlayer(playerNode, WithSprite: sprite)
        
        return playerNode
    }
    
    private func setupInitialPositionForPlayer(playerNode: SKNode) {
        playerNode.position = CGPoint(x: midOfScreenWidth(), y: GraphicsConstants.InitialPlayerPositionY)
    }
    
    private func addSpriteForPlayer(playerNode: SKNode) -> SKSpriteNode {
        let sprite = SKSpriteNode(imageNamed: "Player")
        playerNode.addChild(sprite)
        
        return sprite
    }
    
    private func setupPhysicsForPlayer(playerNode: SKNode, WithSprite sprite: SKSpriteNode) {
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        
        playerNode.physicsBody?.dynamic = false
        playerNode.physicsBody?.allowsRotation = false
        
        playerNode.physicsBody?.restitution = 1.0
        playerNode.physicsBody?.friction = 0.0
        playerNode.physicsBody?.angularDamping = 0.0
        playerNode.physicsBody?.linearDamping = 0.0
        
        playerNode.physicsBody?.usesPreciseCollisionDetection = true
        playerNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
        playerNode.physicsBody?.collisionBitMask = 0
        playerNode.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Star | CollisionCategoryBitmask.Platform
    }
    
    // MARK: - Add Hud for the game
    private func setupHud() {
        hudNode = SKNode()
        
        tapToStartNode = createTapToStartNode()
        hudNode.addChild(tapToStartNode)
        
        addChild(hudNode)
    }
    
    private func createTapToStartNode() -> SKSpriteNode {
        let startNode = SKSpriteNode(imageNamed: "TapToStart")
        startNode.position = CGPoint(x: self.size.width / 2, y: GraphicsConstants.TapToStartPositionY)
        return startNode
    }
    
    // MARK: - Begin the game
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if gameInProgress() {
            return
        }
        
        startGame()
    }
    
    private func startGame() {
        removeTapToStartNodeFromHud()
        startActionForPlayer()
    }
    
    private func removeTapToStartNodeFromHud() {
        tapToStartNode.removeFromParent()
    }
    
    private func startActionForPlayer() {
        player.physicsBody?.dynamic = true
        player.physicsBody?.applyImpulse(PhysicsConstants.InitialImpulse)
    }
    
    // MARK: - Add star for the game
    func addStarsIntoForeground() {
        for starNode in gameLevel!.stars {
            let star = createStarAtPosition(starNode.position, OfType: starNode.starType)
            foregroundNode.addChild(star)
        }
    }
    
    func createStarAtPosition(position: CGPoint, OfType type: StarType) -> StarNode {
        let star = StarNode()
        
        setupPosition(position, ForGameObjectNode: star)
        setupNameForStarNode(star)
        setupType(type, ForStarNode: star)
        
        let sprite = addSpriteForStarNode(star, OfType: type)
        
        setupPhysicsForStarNode(star, WithSprite: sprite)
        
        return star
    }
    
    private func setupNameForStarNode(star: StarNode) {
        star.name = NodeNameConstants.StarNodeName
    }
    
    private func setupType(type: StarType, ForStarNode star: StarNode) {
        star.starType = type
    }
    
    private func addSpriteForStarNode(star: StarNode, OfType type: StarType) -> SKSpriteNode {
        var sprite: SKSpriteNode
        
        if type == .Special {
            sprite = SKSpriteNode(imageNamed: "StarSpecial")
        }
        else {
            sprite = SKSpriteNode(imageNamed: "Star")
        }
        
        star.addChild(sprite)
        return sprite
    }
    
    private func setupPhysicsForStarNode(star: StarNode, WithSprite sprite: SKSpriteNode) {
        star.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        star.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Star
        
        setupCommonPhysicsForGameObjectNode(star)
    }
    
    // MARK: - Add platform for the game
    func addPlatformsIntoForeground() {
        for platformNode in gameLevel!.platforms {
            let platform = createPlatformAtPosition(platformNode.position, OfType: platformNode.platformType)
            foregroundNode.addChild(platform)
        }
    }
    
    func createPlatformAtPosition(position: CGPoint, OfType type: PlatformType) -> PlatformNode {
        let platform = PlatformNode()
        
        setupPosition(position, ForGameObjectNode: platform)
        setupNameForPlatformNode(platform)
        setupType(type, ForPlatformNode: platform)
        
        let sprite = addSpriteForPlatformNode(platform, OfType: type)
        
        setupPhysicsForPlatformNode(platform, WithSprite: sprite)
        
        return platform
    }
    
    private func setupNameForPlatformNode(platform: PlatformNode) {
        platform.name = NodeNameConstants.PlatformNodeName
    }
    
    private func setupType(type: PlatformType, ForPlatformNode platform: PlatformNode) {
        platform.platformType = type
    }
    
    private func addSpriteForPlatformNode(platform: PlatformNode, OfType type: PlatformType) -> SKSpriteNode {
        var sprite: SKSpriteNode
        
        if type == .Break {
            sprite = SKSpriteNode(imageNamed: "PlatformBreak")
        }
        else {
            sprite = SKSpriteNode(imageNamed: "Platform")
        }
        
        platform.addChild(sprite)
        return sprite
    }
    
    private func setupPhysicsForPlatformNode(platform: PlatformNode, WithSprite sprite: SKSpriteNode) {
        platform.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        platform.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Platform

        setupCommonPhysicsForGameObjectNode(platform)
    }
    
    // MARK: - Common code for Star & Platform
    private func setupPosition(position: CGPoint, ForGameObjectNode node: SKNode) {
        node.position = adaptForPosition(position)
    }
    
    private func setupCommonPhysicsForGameObjectNode(node: GameObjectNode) {
        node.physicsBody?.dynamic = false
        node.physicsBody?.collisionBitMask = 0
    }

    // MARK: - Contact delegate method
    // Note: Not covered by unit test, since we cannot mock SKPhysicsContact object
    func didBeginContact(contact: SKPhysicsContact) {
        var shouldUpdateHud = false
        
        let whichNode = (contact.bodyA.node != player) ? contact.bodyA.node : contact.bodyB.node
        let other = whichNode as! GameObjectNode
        
        shouldUpdateHud = other.collisionWithPlayer(player)
        
        if shouldUpdateHud {
            
        }
    }
    
    // MARK: - Update method for parallaxalization
    override func update(currentTime: NSTimeInterval) {
        moveLayers()
    }
    
    private func moveLayers() {
        if player.position.y > GraphicsConstants.ParallaxalizationThreshold {
            backgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - GraphicsConstants.ParallaxalizationThreshold) * GraphicsConstants.BackgroundParallaxalizationSpeed))
            midgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - GraphicsConstants.ParallaxalizationThreshold) * GraphicsConstants.MidgroundParallaxalizationSpeed))
            foregroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - GraphicsConstants.ParallaxalizationThreshold) * GraphicsConstants.ForegroundParallaxalizationSpeed))
        }
    }
    
    // MARK: - Helper mehtods
    private func midOfScreenWidth() -> CGFloat {
        return self.size.width / 2
    }
    
    private func gameInProgress() -> Bool {
        if player.physicsBody?.dynamic == true {
            return true
        }
        return false
    }
    
    private func adaptForPosition(position: CGPoint) -> CGPoint {
        return CGPoint(x: position.x * scaleFactor, y: position.y)
    }
    
}
