//
//  GameViewController.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/10/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

struct GameLevelConstants {
    static let TotalLevels = 10
}

class GameViewController: UIViewController {
    
    var objConfiguration = ObjectConfiguration()
    var scene: GameScene!
    var level: Level!
    var currentLevel = 1
    
    var movesLeft = 0
    var score = 0
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    lazy var backgroundMusic: AVAudioPlayer = {
        let url = NSBundle.mainBundle().URLForResource("Mining by Moonlight", withExtension: "mp3")
        let player = try? AVAudioPlayer(contentsOfURL: url!)
        player!.numberOfLoops = -1
        return player!
    }()
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverPanel: UIImageView!
    @IBOutlet weak var shuffleButton: UIButton!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.AllButUpsideDown
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideGameOverPanel()
        disableMultipleTouch()
        
        configureGameScene()
        presentScene()
        
        backgroundMusic.play()
        beginGame()
    }
    
    @IBAction func shuffleButtonPressed(sender: UIButton) {
        shuffle()
        decreaseMovesLeft()
        checkGameResult()
        updateLabels()
    }
    
    // MARK: - Setup game
    private func disableMultipleTouch() {
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
    }
    
    private func setupLevel() {
        let fileName = levelFileName()
        level = objConfiguration.level(fileName)
    }
    
    private func levelFileName() -> String {
        return String(format: "Level_%ld", currentLevel % (GameLevelConstants.TotalLevels + 1))
    }
    
    private func configureGameScene() {
        configureSceneScaleMode(.AspectFill)
        passSwapHanderToGameScene()
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
    
    // MARK: - Update score
    func updateLabels() {
        updateTargetLabel()
        updateMovesLabel()
        updateScoreLabel()
    }
    
    private func updateTargetLabel() {
        targetLabel.text = String(format: "%.6ld", level.targetScore)
    }
    
    private func updateMovesLabel() {
        movesLabel.text = String(format: "%.6ld", movesLeft)
    }
    
    private func updateScoreLabel() {
        scoreLabel.text = String(format: "%.6ld", score)
    }
    
    private func updateScoreBasedOnChains(chains: Set<Chain>) {
        for chain in chains {
            self.score += chain.score
        }
    }
    
    // MARK: - Game logic
    func beginGame() {
        setupLevel()
        passLevelToGameScene()
        initGameScoreLabels()
        resetScoreComboMulitplier()
        scene.animateBeginGame() {
            self.showShuffleButton()
        }
        shuffle()
    }
    
    private func resetScoreComboMulitplier() {
        level.resetComboMultiplier()
    }
    
    private func initGameScoreLabels() {
        initGameMovesLeft()
        initGameScore()
        updateLabels()
    }
    
    private func initGameMovesLeft() {
        movesLeft = level.maximumMoves
    }
    
    private func decreaseMovesLeft() {
        movesLeft -= 1
    }
    
    private func initGameScore() {
        score = 0
    }
    
    private func increaseLevel() {
        currentLevel = (currentLevel + 1) % (GameLevelConstants.TotalLevels + 1)
        if currentLevel == 0 {
            currentLevel = 1
        }
    }
    
    private func checkGameResult() {
        if score >= level.targetScore {
            gameOverPanel.image = UIImage(named: "LevelComplete")
            increaseLevel()
            showGameOver()
        }
        else if movesLeft == 0 {
            gameOverPanel.image = UIImage(named: "GameOver")
            showGameOver()
        }
    }
    
    func shuffle() {
        let newCookies = level.shuffle()
        scene.removeAllCookieSprites()
        scene.removeAllTileSprites()
        scene.addTiles()
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
        
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        
        scene.animateMatchedCookies(chains) {
            
            self.updateScoreBasedOnChains(chains)
            self.updateLabels()
            
            let columns = self.level.fillHoles()
            self.scene.animateFallingCookies(columns) {
                let columns = self.level.supplyNewCookies()
                self.scene.animateNewCookies(columns) {
                    self.handleMatches()
                }
            }
        }
    }
    
    func beginNextTurn() {
        decreaseMovesLeft()
        checkGameResult()
        updateLabels()
        resetScoreComboMulitplier()
        
        enableUserInteraction()
        level.detectPossibleSwaps()
    }
    
    func showGameOver() {
        hideShuffleButton()
        showGameOverPanel()
        disableGameSceneUserInteraction()
        scene.animateGameOver() {
            self.setupTapGestureRecognizer()
        }
    }
    
    func hideGameOver() {
        removeTapGestureRecognier()
        enableGameSceneUserInteraction()
        hideGameOverPanel()
        
        beginGame()
    }
    
    private func enableUserInteraction() {
        view.userInteractionEnabled = true
    }
    
    private func disableUserInteraction() {
        view.userInteractionEnabled = false
    }
    
    private func enableGameSceneUserInteraction() {
        scene.userInteractionEnabled = true
    }
    
    private func disableGameSceneUserInteraction() {
        scene.userInteractionEnabled = false
    }
    
    private func setupTapGestureRecognizer() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameViewController.hideGameOver))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func removeTapGestureRecognier() {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
    }
    
    private func hideGameOverPanel() {
        gameOverPanel.hidden = true
    }
    
    private func showGameOverPanel() {
        gameOverPanel.hidden = false
    }
    
    private func hideShuffleButton() {
        shuffleButton.hidden = true
    }
    
    private func showShuffleButton() {
        shuffleButton.hidden = false
    }

}