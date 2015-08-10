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
    
    class MockSKView: SKView {
        var scenePresented = false
        
        override func presentScene(scene: SKScene?) {
            scenePresented = true
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

}
