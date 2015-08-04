//
//  BadgesDataSourceProviderTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/24/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest
import CoreData

class BadgesDataSourceProviderTests: XCTestCase {
    
    class MockBadgeEarnStatusMgr: BadgeEarnStatusDataProvider {
        let badgeJsonString1 = ["name":"Earth", "imageName":"earth", "distance":"0", "information": "badgeInformation1"]
        var badge1: Badge?
        let badgeJsonString2 = ["name":"Earth's Atmosphere", "imageName":"atmosphere", "distance":"804.672", "information": "badgeInformation2"]
        var badge2: Badge?
        
        var managedObjectContext: NSManagedObjectContext?
        lazy var badgeEarnStatuses: [BadgeEarnStatus]? = {
            [unowned self] in
            
            var _badgeEarnStatuses = [BadgeEarnStatus]()
            
            self.badge1 = Badge(badgeJsonString: self.badgeJsonString1)
            self.badge2 = Badge(badgeJsonString: self.badgeJsonString2)
            var _badgeEarnStatus1 = BadgeEarnStatus(badge: self.badge1!)
            _badgeEarnStatus1.earnRun = Run()
            var _badgeEarnStatus2 = BadgeEarnStatus(badge: self.badge2!)
            
            _badgeEarnStatuses.append(_badgeEarnStatus1)
            _badgeEarnStatuses.append(_badgeEarnStatus2)
            
            return _badgeEarnStatuses
        }()
    }
    
    var dataProvider: BadgesDataSourceProvider?
    var mockBadgeEarnStatusMgr = MockBadgeEarnStatusMgr()
    var tableView: UITableView?
    var cell: BadgeCell?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        dataProvider = BadgesDataSourceProvider()
        dataProvider?.badgeEarnStatusMgr = mockBadgeEarnStatusMgr
        
        var storyBoard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        var badgesTVC = storyBoard.instantiateViewControllerWithIdentifier("BadgesTableViewController") as? BadgesTableViewController
        tableView = badgesTVC?.tableView
        cell = dataProvider?.tableView(tableView!, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as? BadgeCell
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBadgeNumberIsCorrect() {
        let rows = dataProvider?.tableView(tableView!, numberOfRowsInSection:0)
        XCTAssertTrue(rows == 2)
    }
    
    func testCellIsBadgeCell() {
        XCTAssertTrue(cell?.isKindOfClass(BadgeCell) == true)
    }
    
    func testUnEarnedCellNameIsSetCorrectly() {
        XCTAssertTrue(cell?.badgeNameLabel.text == "??????")
    }
    
    func testEarnedCellNameIsSetCorrectly() {
        cell = dataProvider?.tableView(tableView!, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? BadgeCell
        XCTAssertTrue(cell?.badgeNameLabel.text == "Earth")
    }
    
    func testBadgeImageIsSetCorrectly() {
        XCTAssertTrue(cell?.badgeImageView.image != nil)
    }

}
