//
//  GameViewControllerTests.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/10/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest
import SpriteKit

class GameViewControllerTests: XCTestCase {
    
    var gameVC: GameViewController!
    var skView: SKView!
    var mockObjConfiguration = MockObjConfiguration()
    
    var cookie1: Cookie?
    var cookie1Type = CookieType.Croissant
    var cookie2: Cookie?
    var cookie2Type = CookieType.Cupcake
    var swap: Swap?
    
    class MockSKView: SKView {
        var scenePresented = false
        
        override func presentScene(scene: SKScene?) {
            scenePresented = true
        }
    }
    
    class MockLevel: Level {
        var shuffleCalled = false
        var performSwapCalled = false
        var removeMatchesCalled = false
        var fillHolesCalled = false
        var supplyNewCookiesCalled = false
        var detectPossibleSwapsCalled = false
        
        override func shuffle() -> Set<Cookie> {
            var cookies = Set<Cookie>()
            
            shuffleCalled = true
            
            return cookies
        }
        
        override func performSwap(swap: Swap) {
            performSwapCalled = true
        }
        
        override func removeMatches() -> Set<Chain> {
            var matches = Set<Chain>()
            
            if removeMatchesCalled {
                return matches
            }
            else {
                removeMatchesCalled = true
                let chain = Chain(chainType: .Horizontal)
                matches.insert(chain)
            }
            
            return matches
        }
        
        override func fillHoles() -> [[Cookie]] {
            var columns = [[Cookie]]()
            
            fillHolesCalled = true
            
            return columns
        }
        
        override func supplyNewCookies() -> [[Cookie]] {
            var columns = [[Cookie]]()
            
            supplyNewCookiesCalled = true
            
            return columns
        }
        
        override func detectPossibleSwaps() {
            detectPossibleSwapsCalled = true
        }
        
        override func calculateScores(chains: Set<Chain>) {
            
        }
    }
    
    class MockLevelWithPerformSwapImpossible: MockLevel {
        override func isPossibleSwap(swap: Swap) -> Bool {
            return false
        }
    }
    
    class MockLevelWithPerformSwapPossible: MockLevel {
        override func isPossibleSwap(swap: Swap) -> Bool {
            return true
        }
    }
    
    class MockGameScene: GameScene {
        var addSpritesCalled = false
        var removeAllCookieSpritesCalled = false
        var addTilesCalled = false
        var removeAllTileSpritesCalled = false
        var animateSwapCalled = false
        var animateInvalidSwapCalled = false
        var animateMatchedCookiesCalled = false
        var animateFallingCookiesCalled = false
        var animateNewCookiesCalled = false
        var animateGameOverCalled = false
        var animateBeginGameCalled = false
        
        override func addSpritesForCookies(cookies: Set<Cookie>) {
            addSpritesCalled = true
        }
        
        override func removeAllCookieSprites() {
            removeAllCookieSpritesCalled = true
        }
        
        override func addTiles() {
            addTilesCalled = true
        }
        
        override func removeAllTileSprites() {
            removeAllTileSpritesCalled = true
        }
        
        override func animateSwap(swap: Swap, completion: () -> ()) {
            animateSwapCalled = true
        }
        
        override func animateInvalidSwap(swap: Swap, completion: () -> ()) {
            animateInvalidSwapCalled = true
        }
        
        override func animateMatchedCookies(chains: Set<Chain>, completion: () -> ()) {
            animateMatchedCookiesCalled = true
            completion()
        }
        
        override func animateFallingCookies(columns: [[Cookie]], completion: () -> ()) {
            animateFallingCookiesCalled = true
            completion()
        }
        
        override func animateNewCookies(columns: [[Cookie]], completion: () -> ()) {
            animateNewCookiesCalled = true
            completion()
        }
        
        override func animateGameOver(completion: () -> ()) {
            animateGameOverCalled = true
            completion()
        }
        
        override func animateBeginGame(completion: () -> ()) {
            animateBeginGameCalled = true
            completion()
        }
        
    }
    
    class MockObjConfiguration: ObjectConfiguration {
        override func level(filename: String) -> Level {
            return MockLevel(filename: filename)
        }
        override func gameScene(size: CGSize) -> GameScene {
            return MockGameScene(size: size)
        }
    }

    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        gameVC = storyBoard.instantiateViewControllerWithIdentifier("GameViewController") as! GameViewController
        skView = gameVC.view as! SKView
        gameVC.viewDidLoad()
        
        cookie1 = Cookie(column: 0, row: 0, cookieType: cookie1Type)
        cookie2 = Cookie(column: 1, row: 1, cookieType: cookie2Type)
        swap = Swap(cookieA: cookie1!, cookieB: cookie2!)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPrefersStatusBarHiddenReturnsTrue() {
        XCTAssertTrue(gameVC.prefersStatusBarHidden() == true)
    }
    
    func testShouldAutorotateReturnsTrue() {
        XCTAssertTrue(gameVC.shouldAutorotate() == true)
    }
    
    func testSupportedInterfaceOrientationsReturnsAllButUpsideDown() {
        XCTAssertTrue(gameVC.supportedInterfaceOrientations() == Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue))
    }
    
    func testSKViewDoesNotAllowMultipleTouch() {
        XCTAssertTrue(skView.multipleTouchEnabled == false)
    }
    
    func testSceneScaleModeSetToAspectFill() {
        XCTAssertTrue(gameVC.scene.scaleMode == .AspectFill)
    }
    
    func testScenePresentedAfterViewDidLoad() {
        let mockSKView = MockSKView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        gameVC.view = mockSKView
        gameVC.viewDidLoad()
        XCTAssertTrue(mockSKView.scenePresented == true)
    }
    
    func testLevelIsPreparedAfterViewDidLoad() {
        XCTAssertTrue(gameVC.level != nil)
    }
    
    func testLevelIsSetToGameSceneAfterViewDidLoad() {
        XCTAssertTrue(gameVC.scene.level != nil)
    }
    
    func testSuffleMethodOfLevelClassWillBeCalledWhenLoadingGameVC() {
        gameVC.objConfiguration = mockObjConfiguration
        gameVC.viewDidLoad()
        let mockLevel = gameVC.level as! MockLevel
        XCTAssertTrue(mockLevel.shuffleCalled == true)
    }
    
    func testAddSpritesIsCalledWhenLoadingGameVC() {
        gameVC.objConfiguration = mockObjConfiguration
        gameVC.viewDidLoad()
        let scene = gameVC.scene as! MockGameScene
        XCTAssertTrue(scene.addSpritesCalled == true)
    }
    
    func testAddTilesIsCalledWhenLoadingGameVC() {
        gameVC.objConfiguration = mockObjConfiguration
        gameVC.viewDidLoad()
        let scene = gameVC.scene as! MockGameScene
        XCTAssertTrue(scene.addTilesCalled == true)
    }
    
    func testHandleSwapWillCallPerformSwapInLevelDataModel() {
        gameVC.level = MockLevelWithPerformSwapPossible(filename: "filename")
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.handleSwipe(swap!)
        let mockLevel = gameVC.level as! MockLevel
        XCTAssertTrue(mockLevel.performSwapCalled == true)
    }
    
    func testhandleSwapWillCallAnimateSwapInGameScene() {
        gameVC.level = MockLevelWithPerformSwapPossible(filename: "filename")
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.handleSwipe(swap!)
        let mockScene = gameVC.scene as! MockGameScene
        XCTAssertTrue(mockScene.animateSwapCalled == true)
    }
    
    func testSwapHanderIsSetToGameScene() {
        gameVC.objConfiguration = mockObjConfiguration
        gameVC.viewDidLoad()
        let mockScene = gameVC.scene as! MockGameScene
        XCTAssertTrue(mockScene.swipeHandler != nil)
    }
    
    func testPerformSwapNotCalledIfItsImpossible() {
        gameVC.level = MockLevelWithPerformSwapImpossible(filename: "filename")
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.handleSwipe(swap!)
        
        let mockLevel = gameVC.level as! MockLevelWithPerformSwapImpossible
        let mockScene = gameVC.scene as! MockGameScene
        XCTAssertTrue(mockLevel.performSwapCalled == false)
        XCTAssertTrue(mockScene.animateSwapCalled == false)
    }
    
    func testPerformSwapCalledIfItsPossible() {
        gameVC.level = MockLevelWithPerformSwapPossible(filename: "filename")
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.handleSwipe(swap!)
        
        let mockLevel = gameVC.level as! MockLevelWithPerformSwapPossible
        let mockScene = gameVC.scene as! MockGameScene
        XCTAssertTrue(mockLevel.performSwapCalled == true)
        XCTAssertTrue(mockScene.animateSwapCalled == true)
    }

    func testInvalidSwipeWillCallanimateInvalidSwap() {
        gameVC.level = MockLevelWithPerformSwapImpossible(filename: "filename")
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.handleSwipe(swap!)
        
        let mockScene = gameVC.scene as! MockGameScene
        XCTAssertTrue(mockScene.animateInvalidSwapCalled == true)
    }
    
    func testHandleMatchesWillCallRemoveMatchesInLevelDataModel() {
        gameVC.level = MockLevel(filename: "filename")
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.handleMatches()
        let mockLevel = gameVC.level as! MockLevel
        XCTAssertTrue(mockLevel.removeMatchesCalled == true)
    }
    
    func testHandleMatchesWillCallAnimateMatchedCookiesInGameScene() {
        gameVC.level = MockLevel(filename: "filename")
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.handleMatches()
        
        let mockScene = gameVC.scene as! MockGameScene
        XCTAssertTrue(mockScene.animateMatchedCookiesCalled == true)
    }
    
    func testHandleMatchesWillCallFillHolesInLevelDataModel() {
        gameVC.level = MockLevel(filename: "filename")
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.handleMatches()
        
        let mockLevel = gameVC.level as! MockLevel
        XCTAssertTrue(mockLevel.fillHolesCalled == true)
    }
    
    func testHandleMatchesWillCallAnimateFallingCookiesInGameScene() {
        gameVC.level = MockLevel(filename: "filename")
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.handleMatches()
        
        let mockScene = gameVC.scene as! MockGameScene
        XCTAssertTrue(mockScene.animateFallingCookiesCalled == true)
    }
    
    func testHandleMatchesWillCallSupplyNewCookiesInLevelDataModel() {
        gameVC.level = MockLevel(filename: "filename")
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.handleMatches()
        
        let mockLevel = gameVC.level as! MockLevel
        XCTAssertTrue(mockLevel.supplyNewCookiesCalled == true)
    }
    
    func testHandleMatchesWillCallAnimateNewCookiesInGameScene() {
        gameVC.level = MockLevel(filename: "filename")
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.handleMatches()
        
        let mockScene = gameVC.scene as! MockGameScene
        XCTAssertTrue(mockScene.animateNewCookiesCalled == true)
    }
    
    func testBeginNextTurnWillSetUserInteractiveToTrue() {
        gameVC.view.userInteractionEnabled = false
        gameVC.beginNextTurn()
        XCTAssertTrue(gameVC.view.userInteractionEnabled == true)
    }
    
    func testBeginNextTurnWillDetectPossibleSwap() {
        gameVC.level = MockLevel(filename: "filename")
        gameVC.beginNextTurn()
        let mockLevel = gameVC.level as! MockLevel
        XCTAssertTrue(mockLevel.detectPossibleSwapsCalled == true)
    }
    
    func testBeginWillLoadLevelScoreInfo() {
        gameVC.beginGame()
        XCTAssertTrue(gameVC.targetLabel.text == "001000")
        XCTAssertTrue(gameVC.movesLabel.text == "000015")
        XCTAssertTrue(gameVC.scoreLabel.text == "000000")
    }
    
    func testHandleMatchesWillUpdateScore() {
        let originalScoreLabelText = gameVC.scoreLabel.text
        
        gameVC.level = Level(filename: "Level_0")
        gameVC.level.shuffle()
        let swaps = gameVC.level.possibleSwaps
        gameVC.level.performSwap(swaps[advance(swaps.startIndex, swaps.count - 1)])
        
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        
        gameVC.handleMatches()
        
        XCTAssertTrue(gameVC.scoreLabel.text != originalScoreLabelText)
    }
    
    func testBeginGameWillResetComboMultiplier() {
        gameVC.level = MockLevel(filename: "filename")
        gameVC.level.comboMultiplier = 3
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
    
        gameVC.beginGame()
        XCTAssertTrue(gameVC.level.comboMultiplier == 1)
    }
    
    func testBeginNextRoundWillResetComboMultiplier() {
        gameVC.level = MockLevel(filename: "filename")
        gameVC.level.comboMultiplier = 3
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        
        gameVC.beginNextTurn()
        XCTAssertTrue(gameVC.level.comboMultiplier == 1)
    }
    
    func testBeginNextRoundWillDecreaseMoves() {
        gameVC.level = Level(filename: "Level_0")
        gameVC.beginGame()
        let originalMoves = gameVC.movesLeft
        let expectedMovesLabelText = String(format: "%.6ld", originalMoves - 1)
        gameVC.beginNextTurn()
        let currentMovesLabelText = String(format: "%.6ld", gameVC.movesLeft)
        XCTAssertTrue(currentMovesLabelText == expectedMovesLabelText)
    }
    
    func testGameOverPanelIsHiddenAfterViewDidLoad() {
        XCTAssertTrue(gameVC.gameOverPanel.hidden == true)
    }
    
    func testShowGameOverWillShowGameOverPanel() {
        gameVC.showGameOver()
        XCTAssertTrue(gameVC.gameOverPanel.hidden == false)
    }
    
    func testShowGameOverWillDisableUserInteractiveForGameScene() {
        gameVC.showGameOver()
        XCTAssertTrue(gameVC.scene.userInteractionEnabled == false)
    }
    
    func testShowGameOverWillSetupTapGesture() {
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        
        var originalGestureCount = gameVC.view.gestureRecognizers?.count
        if originalGestureCount == nil {
            originalGestureCount = 0
        }
        
        gameVC.showGameOver()
        XCTAssertTrue(gameVC.tapGestureRecognizer != nil)
        XCTAssertTrue(gameVC.view.gestureRecognizers?.count == originalGestureCount! + 1)
    }
    
    func testHideGameOverWillRemoveTapGesture() {
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.showGameOver()
        
        var originalGestureCount = gameVC.view.gestureRecognizers?.count
        if originalGestureCount == nil {
            originalGestureCount = 0
        }
        
        gameVC.hideGameOver()
        
        var currentGestureCount = gameVC.view.gestureRecognizers?.count
        if currentGestureCount == nil {
            currentGestureCount = 0
        }
        
        XCTAssertTrue(gameVC.tapGestureRecognizer == nil)
        XCTAssertTrue(currentGestureCount! == originalGestureCount! - 1)
    }
    
    func testHideGameOverWillEnableUserInteractiveForGameScene() {
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        
        gameVC.showGameOver()
        gameVC.hideGameOver()
        
        XCTAssertTrue(gameVC.scene.userInteractionEnabled == true)
    }
    
    func testHideGameOverWillHideGameOverPanel() {
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        
        gameVC.showGameOver()
        gameVC.hideGameOver()
        
        XCTAssertTrue(gameVC.gameOverPanel.hidden == true)
    }
    
    func testHideGameOverWillCallBeginGame() {
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        
        gameVC.beginGame()
        gameVC.score++
        
        gameVC.showGameOver()
        gameVC.hideGameOver()
        
        XCTAssertTrue(gameVC.score == 0)
    }
    
    func testBeginNextTurnWillShowGameFailIfMovesLeftIsZero() {
        gameVC.beginGame()
        gameVC.movesLeft = 1
        gameVC.beginNextTurn()
        
        XCTAssertTrue(gameVC.gameOverPanel.image == UIImage(named: "GameOver"))
        XCTAssertTrue(gameVC.gameOverPanel.hidden == false)
    }
    
    func testBeginNextTurnWillShowGameWinIfTargetScoreReached() {
        gameVC.beginGame()
        gameVC.score = gameVC.level.targetScore + 1
        gameVC.beginNextTurn()
        
        XCTAssertTrue(gameVC.gameOverPanel.image == UIImage(named: "LevelComplete"))
        XCTAssertTrue(gameVC.gameOverPanel.hidden == false)
    }
    
    func testShowGameOverWillCallAnimateGameOver() {
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.showGameOver()
        
        let mockScene = gameVC.scene as! MockGameScene
        XCTAssertTrue(mockScene.animateGameOverCalled == true)
    }
    
    func testBeginGameWillCallAnimateBeginGame() {
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.beginGame()
        
        let mockScene = gameVC.scene as! MockGameScene
        XCTAssertTrue(mockScene.animateBeginGameCalled == true)
    }
    
    func testShuffleWillCallRemoveAllCookieSprites() {
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.shuffle()
        let mockScene = gameVC.scene as! MockGameScene
        XCTAssertTrue(mockScene.removeAllCookieSpritesCalled == true)
    }
    
    func testShuffleWillCallRemoveAllTileSprites() {
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.shuffle()
        let mockScene = gameVC.scene as! MockGameScene
        XCTAssertTrue(mockScene.removeAllTileSpritesCalled == true)
    }
    
    func testShuffleWillCallAddTileForGameScene() {
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.shuffle()
        let mockScene = gameVC.scene as! MockGameScene
        XCTAssertTrue(mockScene.addTilesCalled == true)
    }
    
    func testCanLoadLevelFileCorrectlyAfterViewDidLoad() {
        gameVC.currentLevel = 4
        gameVC.viewDidLoad()
        let expectedLevel = Level(filename: "Level_4")
        XCTAssertTrue(gameVC.level.maximumMoves == expectedLevel.maximumMoves)
    }
    
    func testBeginGameWillLoadLevelFileCorrectly() {
        gameVC.currentLevel = 4
        gameVC.beginGame()
        let expectedLevel = Level(filename: "Level_4")
        XCTAssertTrue(gameVC.level.maximumMoves == expectedLevel.maximumMoves)
    }
    
    func testBeginNextTurnWillLoadNewLevelIfUserPassedTheCurrentLevel() {
        gameVC.beginGame()
        let currentLevel = gameVC.currentLevel
        gameVC.score = gameVC.level.targetScore + 1
        gameVC.beginNextTurn()
        
        XCTAssertTrue(gameVC.currentLevel == currentLevel + 1)
    }
    
    func testBeginGameWillPassNewLevelToGameScene() {
        gameVC.scene.level = nil
        gameVC.beginGame()
        XCTAssertTrue(gameVC.scene.level != nil)
    }
    
    func testShowGameOverWillHideShuffleButton() {
        gameVC.showGameOver()
        
        XCTAssertTrue(gameVC.shuffleButton.hidden == true)
    }
    
    func testBeginGameWillShowShuffleButton() {
        gameVC.scene = MockGameScene(size: CGSize(width: 100, height: 100))
        gameVC.shuffleButton.hidden = true
        gameVC.beginGame()
        
        XCTAssertTrue(gameVC.shuffleButton.hidden == false)
    }
    
    func testPressShuffleButtonWillCallShuffleInLevelDataModel() {
        gameVC.level = MockLevel(filename: "filename")
        gameVC.shuffleButtonPressed(UIButton())
        let mockLevel = gameVC.level as! MockLevel
        XCTAssertTrue(mockLevel.shuffleCalled == true)
    }
    
    func testPressShuffleButtonWillDecreaseMovesLeftByOne() {
        gameVC.movesLeft = 10
        gameVC.shuffleButtonPressed(UIButton())
        XCTAssertTrue(gameVC.movesLeft == 9)
        XCTAssertTrue(gameVC.movesLabel.text == "000009")
    }
    
    func testPressShuffleButtonWillCheckGameResult() {
        gameVC.movesLeft = 1
        gameVC.shuffleButtonPressed(UIButton())
        XCTAssertTrue(gameVC.gameOverPanel.image == UIImage(named: "GameOver"))
    }

}
