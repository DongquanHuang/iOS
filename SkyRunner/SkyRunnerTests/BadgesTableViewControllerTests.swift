//
//  BadgesTableViewControllerTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/24/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest

class BadgesTableViewControllerTests: XCTestCase {
    
    var storyBoard: UIStoryboard?
    var badgesTVC: BadgesTableViewController?
    var mockDataSourceProvider: MockDataSourceProvider?
    
    class MockDataSourceProvider: NSObject, UITableViewDataSource {
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
        badgesTVC?.dataSourceProvider = mockDataSourceProvider
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
