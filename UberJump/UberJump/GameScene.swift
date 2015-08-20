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
    }
    
    struct PhysicsConstants {
        static let GameGravity = CGVector(dx: 0.0, dy: -2.0)
        static let InitialImpulse = CGVector(dx: 0.0, dy: 20.0)
    }
    
    struct NodeNameConstants {
        static let StarNodeName = "NODE_STAR"
    }
    
    // MARK: - Variables
    var backgroundNode: SKNode!
    var midgroundNode: SKNode!
    var foregroundNode: SKNode!
    var hudNode: SKNode!
    var player: SKNode!
    var tapToStartNode: SKNode!
    
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
        
        setupGravity()
        setupContactDelegate()
        
        setupBackground()
        setupForeground()
        addPlayerIntoForeground()
        setupHud()
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
    
    // MARK: - Add foreground for the game
    private func setupForeground() {
        foregroundNode = SKNode()
        addChild(foregroundNode)
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
    func createStarAtPosition(position: CGPoint) -> StarNode {
        let star = StarNode()
        
        setupPosition(position, ForStarNode: star)
        setupNameForStarNode(star)
        
        let sprite = addSpriteForStarNode(star)
        
        setupPhysicsForStarNode(star, WithSprite: sprite)
        
        return star
    }
    
    private func setupPosition(position: CGPoint, ForStarNode star: SKNode) {
        star.position = adaptForPosition(position)
    }
    
    private func setupNameForStarNode(star: StarNode) {
        star.name = NodeNameConstants.StarNodeName
    }
    
    private func addSpriteForStarNode(star: StarNode) -> SKSpriteNode {
        let sprite = SKSpriteNode(imageNamed: "Star")
        star.addChild(sprite)
        return sprite
    }
    
    private func setupPhysicsForStarNode(star: StarNode, WithSprite sprite: SKSpriteNode) {
        star.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        star.physicsBody?.dynamic = false
        
        star.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Star
        star.physicsBody?.collisionBitMask = 0
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
