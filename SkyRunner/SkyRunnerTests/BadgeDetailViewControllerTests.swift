//
//  BadgeDetailViewControllerTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 8/5/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest

class BadgeDetailViewControllerTests: XCTestCase {
    
    var badgeDetailVC: BadgeDetailViewController?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        var storyBoard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        badgeDetailVC = storyBoard.instantiateViewControllerWithIdentifier("BadgeDetailViewController") as? BadgeDetailViewController
        badgeDetailVC?.view
        badgeDetailVC?.viewWillAppear(false)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

}
