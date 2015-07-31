//
//  BadgesDataSourceProviderTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/24/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest

class BadgesDataSourceProviderTests: XCTestCase {
    
    var dataProvider: BadgesDataSourceProvider?
    var tableView: UITableView?
    var cell: BadgeCell?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        dataProvider = BadgesDataSourceProvider()
        
        var storyBoard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        var badgesTVC = storyBoard.instantiateViewControllerWithIdentifier("BadgesTableViewController") as? BadgesTableViewController
        tableView = badgesTVC?.tableView
        
        cell = dataProvider?.tableView(tableView!, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as? BadgeCell
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFilePathIsValid() {
        let filePath = NSBundle.mainBundle().pathForResource("badges", ofType: "json")
        XCTAssertTrue(dataProvider?.filePath == filePath)
    }
    
    func testBadgeNumberIsCorrect() {
        let rows = dataProvider?.tableView(tableView!, numberOfRowsInSection:0)
        XCTAssertTrue(rows == 33)
    }
    
    func testCellIsBadgeCell() {
        XCTAssertTrue(cell?.isKindOfClass(BadgeCell) == true)
    }
    
    func testCellNameIsSetCorrectly() {
        XCTAssertTrue(cell?.badgeNameLabel.text == "Earth's Atmosphere")
    }
    
    func testBadgeImageIsSetCorrectly() {
        XCTAssertTrue(cell?.badgeImageView.image != nil)
    }

}
