//
//  GameScene.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/10/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        setAnchorPointToMiddle()
        addBackgroundNode()
    }
    
    private func setAnchorPointToMiddle() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    private func addBackgroundNode() {
        let background = SKSpriteNode(imageNamed: "Background")
        addChild(background)
    }
}
