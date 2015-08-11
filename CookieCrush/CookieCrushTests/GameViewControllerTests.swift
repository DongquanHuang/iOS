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
    }
    
    class MockGameScene: GameScene {
        var addSpritesCalled = false
        var addTilesCalled = false
        
        override func addSpritesForCookies(cookies: Set<Cookie>) {
            addSpritesCalled = true
        }
        
        override func addTiles() {
            addTilesCalled = true
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

}
