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
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        storyBoard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        badgesTVC = storyBoard?.instantiateViewControllerWithIdentifier("BadgesTableViewController") as? BadgesTableViewController
        mockDataSourceProvider = MockDataSourceProvider()
        
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

}
