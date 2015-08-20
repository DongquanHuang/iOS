//
//  GameViewControllerTests.swift
//  UberJump
//
//  Created by Peter Huang on 8/20/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import UIKit
import XCTest
import SpriteKit

class GameViewControllerTests: XCTestCase {
    
    var gameVC: GameViewController!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        loadGameViewControllerFromStoryboary()
    }
    
    private func loadGameViewControllerFromStoryboary() {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        gameVC = storyboard.instantiateViewControllerWithIdentifier("GameViewController") as! GameViewController
        gameVC.viewDidLoad()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testViewDidLoadWillConfigureGameSceneSizeProperly() {
        XCTAssertTrue(gameVC.scene?.size == gameVC.view.bounds.size)
    }

    func testViewDidLoadWillConfigureGameSceneScaleModeToAspectFit() {
        XCTAssertTrue(gameVC.scene?.scaleMode == SKSceneScaleMode.AspectFit)
    }

}
