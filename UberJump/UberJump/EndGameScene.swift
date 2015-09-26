//
//  EndGameScene.swift
//  UberJump
//
//  Created by Peter Huang on 8/24/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import UIKit
import SpriteKit

class EndGameScene: SKScene {
    
    var gameState = GameState.sharedInstance
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        displayGameStatistic()
    }
    
    func displayGameStatistic() {
        removeAllChildren()
        
        addStarIcon()
        addStarsLabel()
        addScoreLabel()
        addHighScoreLabel()
        addTryAgainLabel()
    }
    
    // Not covered by unit test
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let reveal = SKTransition.fadeWithDuration(0.5)
        let gameScene = GameScene(size: self.size)
        self.view!.presentScene(gameScene, transition: reveal)
    }
    //
    
    private func addStarIcon() {
        let star = SKSpriteNode(imageNamed: "Star")
        star.position = CGPoint(x: 25, y: self.size.height - 30)
        addChild(star)
    }
    
    private func addStarsLabel() {
        let lblStars = commonLabel()
        lblStars.position = CGPoint(x: 50, y: self.size.height - 40)
        lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        lblStars.text = String(format: "X %d", gameState.stars)
        
        addChild(lblStars)
    }
    
    private func addScoreLabel() {
        let lblScore = commonLabel()
        lblScore.fontSize = 60
        lblScore.position = CGPoint(x: self.size.width / 2, y: 300)
        lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblScore.text = String(format: "%d", gameState.score)
        addChild(lblScore)
    }
    
    private func addHighScoreLabel() {
        let lblHighScore = commonLabel()
        lblHighScore.position = CGPoint(x: self.size.width / 2, y: 150)
        lblHighScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblHighScore.text = String(format: "High Score: %d", gameState.highScore)
        addChild(lblHighScore)
    }
    
    private func addTryAgainLabel() {
        let lblTryAgain = commonLabel()
        lblTryAgain.position = CGPoint(x: self.size.width / 2, y: 50)
        lblTryAgain.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblTryAgain.text = "Tap To Try Again"
        addChild(lblTryAgain)
    }
    
    private func commonLabel() -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        label.fontSize = 30
        label.fontColor = SKColor.whiteColor()
        
        return label
    }

    
}
