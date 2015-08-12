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
        
        override func shuffle() -> Set<Cookie> {
            var cookies = Set<Cookie>()
            
            shuffleCalled = true
            
            return cookies
        }
        
        var performSwapCalled = false
        
        override func performSwap(swap: Swap) {
            performSwapCalled = true
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
        var addTilesCalled = false
        var animateSwapCalled = false
        var animateInvalidSwapCalled = false
        
        override func addSpritesForCookies(cookies: Set<Cookie>) {
            addSpritesCalled = true
        }
        
        override func addTiles() {
            addTilesCalled = true
        }
        
        override func animateSwap(swap: Swap, completion: () -> ()) {
            animateSwapCalled = true
        }
        
        override func animateInvalidSwap(swap: Swap, completion: () -> ()) {
            animateInvalidSwapCalled = true
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

}
