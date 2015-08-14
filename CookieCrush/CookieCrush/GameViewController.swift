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
    
    var objConfiguration = ObjectConfiguration()
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
        
        configureGameScene()
        presentScene()
        
        beginGame()
    }
    
    // MARK: - Setup game
    private func disableMultipleTouch() {
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
    }
    
    private func setupLevel() {
        level = objConfiguration.level("Level_0")
    }
    
    private func configureGameScene() {
        configureSceneScaleMode(.AspectFill)
        
        passLevelToGameScene()
        passSwapHanderToGameScene()
        
        addTilesInGameScene()
    }
    
    private func configureSceneScaleMode(mode: SKSceneScaleMode) {
        let skView = view as! SKView
        scene = objConfiguration.gameScene(skView.bounds.size)
        scene.scaleMode = mode
    }
    
    private func passLevelToGameScene() {
        scene.level = level
    }
    
    private func passSwapHanderToGameScene() {
        scene.swipeHandler = handleSwipe
    }
    
    private func addTilesInGameScene() {
        scene.addTiles()
    }
    
    private func presentScene() {
        let skView = view as! SKView
        skView.presentScene(scene)
    }
    
    // MARK: - Game logic
    func beginGame() {
        shuffle()
    }
    
    func shuffle() {
        let newCookies = level.shuffle()
        scene.addSpritesForCookies(newCookies)
    }
    
    func handleSwipe(swap: Swap) {
        disableUserInteraction()
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            scene.animateSwap(swap, completion: handleMatches)
        }
        else {
            scene.animateInvalidSwap(swap) {
                self.enableUserInteraction()
            }
        }
    }
    
    func handleMatches() {
        let chains = level.removeMatches()
        
        // Not covered by unit test
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        
        scene.animateMatchedCookies(chains) {
            let columns = self.level.fillHoles()
            self.scene.animateFallingCookies(columns) {
                let columns = self.level.supplyNewCookies()
                self.scene.animateNewCookies(columns) {
                    self.handleMatches()    // Not covered by unit test
                }
            }
        }
    }
    
    func beginNextTurn() {
        enableUserInteraction()
        level.detectPossibleSwaps()
    }
    
    private func enableUserInteraction() {
        view.userInteractionEnabled = true
    }
    
    private func disableUserInteraction() {
        view.userInteractionEnabled = false
    }
}