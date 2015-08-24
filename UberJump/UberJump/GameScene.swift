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
        
        static let ScreenBoundsThreshold: CGFloat = 20.0
        
        static let LabelFontName = "ChalkboardSE-Bold"
        static let LabelFontSize: CGFloat = 30
        
        static let FallThreshold: CGFloat = 800.0
    }
    
    struct PhysicsConstants {
        static let GameGravity = CGVector(dx: 0.0, dy: -2.0)
        static let InitialImpulse = CGVector(dx: 0.0, dy: 20.0)
        static let AccelerationFactor: CGFloat = 400.0
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
    var lblScore: SKLabelNode!
    var lblStars: SKLabelNode!
    
    var currentLevel = LevelConstants.StartLevel
    var levelLoader = GameLevelLoader()
    var gameLevel: GameLevel?
    var gameState = GameState.sharedInstance
    
    var maxPlayerY: Int = Int(GraphicsConstants.InitialPlayerPositionY)
    
    var gameOver = false
    
    var motionManager = MotionManager()
    
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
        
        readGameState()
        resetGameState()
        loadGameLevel()
        
        setupGravity()
        setupContactDelegate()
        
        setupBackground()
        setupMidground()
        setupForeground()
        addPlayerIntoForeground()
        setupHud()
        
        startCoreMotionManager()
    }
    
    // MARK: - Read game state
    private func readGameState() {
        gameState.readState()
    }
    
    // MARK: - Reset game state
    private func resetGameState() {
        maxPlayerY = Int(GraphicsConstants.InitialPlayerPositionY)
        
        // Not covered by unit test
        gameState.score = 0
        gameOver = false
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
        
        addTapToStartIntoHud()
        
        addScoreLabelIntoHud()
        addStarLabelIntoHud()
        addStarIconIntoHud()
        
        addChild(hudNode)
    }
    
    private func addTapToStartIntoHud() {
        tapToStartNode = createTapToStartNode()
        hudNode.addChild(tapToStartNode)
    }
    
    private func createTapToStartNode() -> SKSpriteNode {
        let startNode = SKSpriteNode(imageNamed: "TapToStart")
        startNode.position = CGPoint(x: self.size.width / 2, y: GraphicsConstants.TapToStartPositionY)
        return startNode
    }
    
    private func addScoreLabelIntoHud() {
        lblScore = commonLabel()
        
        lblScore.position = CGPoint(x: self.size.width - 20, y: self.size.height - 40)
        lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        
        lblScore.text = "0"
        
        hudNode.addChild(lblScore)
    }
    
    private func addStarLabelIntoHud() {
        lblStars = commonLabel()
        
        lblStars.position = CGPoint(x: 50, y: self.size.height - 40)
        lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        lblStars.text = String(format: "X %d", gameState.stars)
        
        hudNode.addChild(lblStars)
    }
    
    private func commonLabel() -> SKLabelNode {
        let label = SKLabelNode(fontNamed: GraphicsConstants.LabelFontName)
        label.fontSize = GraphicsConstants.LabelFontSize
        label.fontColor = SKColor.whiteColor()
        
        return label
    }
    
    private func addStarIconIntoHud() {
        let starIcon = SKSpriteNode(imageNamed: "Star")
        starIcon.position = CGPoint(x: 25, y: self.size.height - 30)
        hudNode.addChild(starIcon)
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

    // MARK: - Contact delegate method
    // Note: Not covered by unit test, since we cannot mock SKPhysicsContact object
    func didBeginContact(contact: SKPhysicsContact) {
        var shouldUpdateHud = false
        
        let whichNode = (contact.bodyA.node != player) ? contact.bodyA.node : contact.bodyB.node
        let other = whichNode as! GameObjectNode
        
        shouldUpdateHud = other.collisionWithPlayer(player)
        
        if shouldUpdateHud {
            updateHud()
        }
    }
    
    private func updateHud() {
        lblStars.text = String(format: "X %d", gameState.stars)
        lblScore.text = String(format: "%d", gameState.score)
    }
    
    // MARK: - Update method
    override func update(currentTime: NSTimeInterval) {
        if gameOver {
            return
        }
        
        checkIfGameOver()
        awardScore()
        removePassedGameObjects()
        moveLayers()
    }
    
    private func checkIfGameOver() {
        if playerReachedLevelTarget() {
            endGame()
        }
        
        if playerFalls() {
            endGame()
        }
    }
    
    private func playerReachedLevelTarget() -> Bool {
        return player.position.y > CGFloat(gameLevel!.endLevelY)
    }
    
    private func playerFalls() -> Bool {
        return player.position.y < CGFloat(maxPlayerY) - GraphicsConstants.FallThreshold
    }
    
    private func awardScore() {
        if Int(player.position.y) > maxPlayerY {
            gameState.score += Int(player.position.y) - maxPlayerY
            maxPlayerY = Int(player.position.y)
            lblScore.text = String(format: "%d", gameState.score)
        }
    }
    
    private func removePassedGameObjects() {
        foregroundNode.enumerateChildNodesWithName(NodeNameConstants.PlatformNodeName, usingBlock: {
            (node, stop) in
            let platform = node as! PlatformNode
            platform.removeNodeIfFarAwayFromPlayer(self.player.position.y)
        })
        
        foregroundNode.enumerateChildNodesWithName(NodeNameConstants.StarNodeName, usingBlock: {
            (node, stop) in
            let star = node as! StarNode
            star.removeNodeIfFarAwayFromPlayer(self.player.position.y)
        })
    }
    
    private func moveLayers() {
        if player.position.y > GraphicsConstants.ParallaxalizationThreshold {
            backgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - GraphicsConstants.ParallaxalizationThreshold) * GraphicsConstants.BackgroundParallaxalizationSpeed))
            midgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - GraphicsConstants.ParallaxalizationThreshold) * GraphicsConstants.MidgroundParallaxalizationSpeed))
            foregroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - GraphicsConstants.ParallaxalizationThreshold) * GraphicsConstants.ForegroundParallaxalizationSpeed))
        }
    }
    
    // MARK: - End game
    func endGame() {
        gameOver = true
        
        gameState.saveState()
        
        // Not covered by unit test
        presentEndGameScene()
    }
    
    private func presentEndGameScene() {
        let reveal = SKTransition.fadeWithDuration(0.5)
        let endGameScene = EndGameScene(size: self.size)
        self.view?.presentScene(endGameScene, transition: reveal)
    }
    
    // MARK: - Core Motion
    private func startCoreMotionManager() {
        motionManager.start()
    }
    
    override func didSimulatePhysics() {
        updatePlayerVelocity()
        makePlayerAlwaysInsideScreen()
    }
    
    private func updatePlayerVelocity() {
        player.physicsBody?.velocity = CGVector(dx: motionManager.xAcceleration * PhysicsConstants.AccelerationFactor, dy: player.physicsBody!.velocity.dy)
    }
    
    private func makePlayerAlwaysInsideScreen() {
        if player.position.x < -(GraphicsConstants.ScreenBoundsThreshold) {
            player.position = CGPoint(x: self.size.width + GraphicsConstants.ScreenBoundsThreshold, y: player.position.y)
        }
        else if (player.position.x > self.size.width + GraphicsConstants.ScreenBoundsThreshold) {
            player.position = CGPoint(x: -(GraphicsConstants.ScreenBoundsThreshold), y: player.position.y)
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
