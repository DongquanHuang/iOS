//
//  GameScene.swift
//  UberJump
//
//  Created by Peter Huang on 8/20/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
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
    }
    
    // MARK: - Variables
    var backgroundNode: SKNode!
    var midgroundNode: SKNode!
    var foregroundNode: SKNode!
    var hudNode: SKNode!
    
    lazy var scaleFactor: CGFloat! = {
        return self.size.width / AdaptConstants.NormalPhoneWidth
    }()
    
    // MARK: - init methods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        setupBackground()
    }
    
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
            node.position = CGPoint(x: self.size.width / 2, y: GraphicsConstants.HeightOfSplitedBackgroundImage * CGFloat(i - 1) * scaleFactor)
            
            bgNode.addChild(node)
        }
        
        return bgNode
    }
    
}
