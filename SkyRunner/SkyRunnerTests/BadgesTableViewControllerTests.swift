//
//  BadgesTableViewControllerTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/24/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest
import CoreData

class BadgesTableViewControllerTests: XCTestCase {
    var storyBoard: UIStoryboard?
    var badgesTVC: BadgesTableViewController?
    var mockDataSourceProvider: MockDataSourceProvider?
    var badgeDetailVC: BadgeDetailViewController?
    var mockBTVC: MockBadgesTVC?
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!
    
    class MockDataSourceProvider: NSObject, BadgeDataProvider {
        var managedObjectContext: NSManagedObjectContext?
        
        var numberOfRowsInSectionFuncGetsCalled = false
        var cellForRowAtIndexPathFuncGetsCalled = false
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            numberOfRowsInSectionFuncGetsCalled = true
            return 1
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            cellForRowAtIndexPathFuncGetsCalled = true
            return UITableViewCell()
        }
        
        func badgeEarnStatusForIndex(index: Int) -> BadgeEarnStatus? {
            return nil
        }
    }
    
    class MockBadgesTVC: BadgesTableViewController {
        var segueIdentifier: NSString?
        
        override func performSegueWithIdentifier(identifier: String?, sender: AnyObject?) {
            segueIdentifier = identifier
        }
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        storyBoard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        badgesTVC = storyBoard?.instantiateViewControllerWithIdentifier("BadgesTableViewController") as? BadgesTableViewController
        mockDataSourceProvider = MockDataSourceProvider()
        badgeDetailVC = storyBoard?.instantiateViewControllerWithIdentifier("BadgeDetailViewController") as? BadgeDetailViewController
        mockBTVC = MockBadgesTVC()
        
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        store = storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType,
            configuration: nil, URL: nil, options: nil, error: nil)
        managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        
        badgesTVC?.managedObjectContext = managedObjectContext
        
        badgesTVC?.dataSourceProvider = mockDataSourceProvider!
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testChangeCoreDataContextWillUpdateToDataProviderAsWell() {
        badgesTVC?.managedObjectContext = managedObjectContext
        XCTAssertTrue(badgesTVC?.dataSourceProvider.managedObjectContext != nil)
    }
    
    func testAssignDataSourceProviderWillSetCoreDataContext() {
        XCTAssertTrue(badgesTVC?.dataSourceProvider.managedObjectContext != nil)
    }
    
    func testCanGetRowNumbers() {
        let rows = badgesTVC?.tableView(UITableView(), numberOfRowsInSection:0)
        XCTAssertTrue(rows == 1)
    }
    
    func testCanGetTableViewCell() {
        let cell = badgesTVC?.tableView(UITableView(), cellForRowAtIndexPath:NSIndexPath())
        XCTAssertTrue(cell != nil)
    }
    
    func testGetRowNumbersDelegateToDataSourceProvider() {
        let rows = badgesTVC?.tableView(UITableView(), numberOfRowsInSection:0)
        XCTAssertTrue(mockDataSourceProvider?.numberOfRowsInSectionFuncGetsCalled == true)
    }
    
    func testGetCellDelegateToDataSourceProvider() {
        let cell = badgesTVC?.tableView(UITableView(), cellForRowAtIndexPath:NSIndexPath())
        XCTAssertTrue(mockDataSourceProvider?.cellForRowAtIndexPathFuncGetsCalled == true)
    }
    
    func testBadgesTVCHasADefaultDataProvider() {
        let btvc = storyBoard?.instantiateViewControllerWithIdentifier("BadgesTableViewController") as? BadgesTableViewController
        XCTAssertTrue(btvc?.dataSourceProvider != nil)
        
    }
    
    func testPressCellWillPerformSegue() {
        mockBTVC?.tableView(UITableView(), didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertTrue(mockBTVC?.segueIdentifier == "Show Badge Detail")
    }
    
    func testPressCellWillGenerateOneBadgeEarnStatus() {
        mockBTVC?.tableView(UITableView(), didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertTrue(mockBTVC?.badgeEarnStatus != nil)
    }
    
    func testPressCellWillPassBadgeEarnStatusToNextViewController() {
        let btvc = storyBoard?.instantiateViewControllerWithIdentifier("BadgesTableViewController") as? BadgesTableViewController
        btvc?.tableView(UITableView(), didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        
        let segue = UIStoryboardSegue(identifier: "Show Badge Detail", source: btvc!, destination: badgeDetailVC!)
        btvc?.prepareForSegue(segue, sender: nil)
        
        XCTAssertTrue(badgeDetailVC?.badgeEarnStatus != nil)
    }

}
