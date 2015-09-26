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
    
    class MockBadgeEarnStatus: BadgeEarnStatus {
        var isDeserveSiler: Bool = false
        var isDeserveGold: Bool = false
        
        override func deserveSilver() -> Bool {
            return isDeserveSiler
        }
        
        override func deserveGold() -> Bool {
            return isDeserveGold
        }
    }
    
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
            var _badgeEarnStatus1 = MockBadgeEarnStatus(badge: self.badge1!)
            _badgeEarnStatus1.earnRun = Run()
            _badgeEarnStatus1.isDeserveSiler = true
            _badgeEarnStatus1.isDeserveGold = true
            var _badgeEarnStatus2 = MockBadgeEarnStatus(badge: self.badge2!)
            
            _badgeEarnStatuses.append(_badgeEarnStatus1)
            _badgeEarnStatuses.append(_badgeEarnStatus2)
            
            return _badgeEarnStatuses
        }()
    }
    
    var dataProvider: BadgesDataSourceProvider?
    var mockBadgeEarnStatusMgr = MockBadgeEarnStatusMgr()
    var tableView: UITableView?
    var cell: BadgeCell?
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        dataProvider = BadgesDataSourceProvider()
        dataProvider?.badgeEarnStatusMgr = mockBadgeEarnStatusMgr
        
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        let badgesTVC = storyBoard.instantiateViewControllerWithIdentifier("BadgesTableViewController") as? BadgesTableViewController
        
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        store = try? storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType,
            configuration: nil, URL: nil, options: nil)
        managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        
        dataProvider?.managedObjectContext = managedObjectContext
        
        tableView = badgesTVC?.tableView
        cell = dataProvider?.tableView(tableView!, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as? BadgeCell
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDataProviderWillPassTheCoreDataContext() {
        XCTAssertTrue(dataProvider?.badgeEarnStatusMgr.managedObjectContext != nil)
    }
    
    func testChangeBadgeEarnStatusMgrWillSetCoreDataContextAsWell() {
        dataProvider?.badgeEarnStatusMgr = MockBadgeEarnStatusMgr()
        XCTAssertTrue(dataProvider?.badgeEarnStatusMgr.managedObjectContext != nil)
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
    
    func testSilierImageIsInvisibleIfNotDeserve() {
        XCTAssertTrue(cell?.silverImageView.hidden == true)
    }
    
    func testGoldImageIsInvisibleIfNotDeserve() {
        XCTAssertTrue(cell?.goldImageView.hidden == true)
    }
    
    func testEarnLabelSetToEarnedIfThisBadgeIsAlreadyEarned() {
        cell = dataProvider?.tableView(tableView!, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? BadgeCell
        XCTAssertTrue(cell?.badgeEarnedLabel.text == "Earned")
    }
    
    func testEarnLabelIsSetToProperTextIfThisBadgeIsNotEarnedYet() {
        XCTAssertTrue(cell?.badgeEarnedLabel.text == "Run 804.672 meters to earn")
    }
    
    func testEarnedCellCanAcceptUserTouch() {
        cell = dataProvider?.tableView(tableView!, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? BadgeCell
        XCTAssertTrue(cell?.userInteractionEnabled == true)
    }
    
    func testUnearnedCellCannotAcceptUserTouch() {
        XCTAssertTrue(cell?.userInteractionEnabled == false)
    }

}
