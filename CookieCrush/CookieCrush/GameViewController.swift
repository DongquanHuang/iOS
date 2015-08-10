//
//  GameViewController.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/10/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var scene: GameScene!
    var level: Level!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        disableMultipleTouch()
        setupLevel()
        configureSceneScaleMode(.AspectFill)
        passLevelToGameScene()
        presentScene()
        
        beginGame()
    }
    
    private func disableMultipleTouch() {
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
    }
    
    private func setupLevel() {
        if level == nil {
            level = Level()
        }
    }
    
    private func configureSceneScaleMode(mode: SKSceneScaleMode) {
        let skView = view as! SKView
        if scene == nil {
            scene = GameScene(size: skView.bounds.size)
        }
        scene.scaleMode = mode
    }
    
    private func passLevelToGameScene() {
        scene.level = level
    }
    
    private func presentScene() {
        let skView = view as! SKView
        skView.presentScene(scene)
    }
    
    func beginGame() {
        shuffle()
    }
    
    func shuffle() {
        let newCookies = level.shuffle()
        scene.addSpritesForCookies(newCookies)
    }
}