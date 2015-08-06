//
//  BadgeEarnStatusTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 8/3/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import SkyRunner

class BadgeEarnStatusTests: XCTestCase {
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!
    
    var badgeEarnStatus: BadgeEarnStatus?
    var badge: Badge?
    let badgeJsonString = ["name":"badgeName", "imageName":"badgeImageName", "distance":"100.0", "information": "badgeInformation"]
    
    var badgeEarnStatusMgr = BadgeEarnStatusMgr()
    
    class MockDB: SkyRunDatabaseInterface {
        var managedObjectContext: NSManagedObjectContext?
        
        var run1: Run?
        var run2: Run?
        var run3: Run?
        
        func allRuns() -> [Run] {
            var runs = [Run]()
            
            runs.append(run1!)
            runs.append(run2!)
            runs.append(run3!)
            
            return runs
        }
        
        func allRunsForBadge(badge: Badge) -> [Run] {
            var runs = [Run]()
            
            runs.append(run1!)
            runs.append(run2!)
            runs.append(run3!)
            
            return runs
        }
    }
    
    var mockDB = MockDB()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        preapreBadgeEarnStatus()
        
        prepareCoreDataContext()
        setManagedObjectContext()
        
        prepareDatabase()
        
        setDBInterfaceForBadgeEarnStatusMgr()
    }
    
    private func preapreBadgeEarnStatus() {
        badge = Badge(badgeJsonString: badgeJsonString)
        badgeEarnStatus = BadgeEarnStatus(badge: badge!)
    }
    
    private func prepareCoreDataContext() {
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        store = storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType,
            configuration: nil, URL: nil, options: nil, error: nil)
        managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
    }
    
    private func setManagedObjectContext() {
        badgeEarnStatusMgr.managedObjectContext = managedObjectContext
    }
    
    private func prepareDatabase() {
        mockDB.run1 = Run(context: managedObjectContext)
        mockDB.run1?.timestamp = NSDate(timeIntervalSince1970: 1)
        mockDB.run1?.duration = 13.0
        mockDB.run1?.distance = 50.0
        
        mockDB.run2 = Run(context: managedObjectContext)
        mockDB.run2?.timestamp = NSDate(timeIntervalSince1970: 2)
        mockDB.run2?.duration = 113.0
        mockDB.run2?.distance = 931.04
        
        mockDB.run3 = Run(context: managedObjectContext)
        mockDB.run3?.timestamp = NSDate(timeIntervalSince1970: 3)
        mockDB.run3?.duration = 685.0
        mockDB.run3?.distance = 1931.04
        
        managedObjectContext.save(nil)
    }
    
    private func setDBInterfaceForBadgeEarnStatusMgr() {
        badgeEarnStatusMgr.databaseReader = mockDB
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCanInitBadgeEarnStatusWithBadge() {
        XCTAssertTrue(badgeEarnStatus?.badge != nil)
    }
    
    func testCanSetCoreDataContextToMgr() {
        XCTAssert(badgeEarnStatusMgr.managedObjectContext == managedObjectContext)
    }
    
    func testContextIsPassedToDatabaseInterface() {
        XCTAssertTrue(mockDB.managedObjectContext == managedObjectContext)
    }
    
    func testNumberOfBadgeEarnStatusesIsCorrect() {
        XCTAssertTrue(badgeEarnStatusMgr.badgeEarnStatuses?.count == 33)
    }
    
    func testThreeBadgesAreEarned() {
        if let earnStatuses = badgeEarnStatusMgr.badgeEarnStatuses {
            let earthEarnedBadge = earnStatuses[0]
            let atmosphereEarnedBadge = earnStatuses[1]
            let moonEarndBadge = earnStatuses[2]
            
            XCTAssertTrue(earthEarnedBadge.badgeEarned() == true)
            XCTAssertTrue(atmosphereEarnedBadge.badgeEarned() == true)
            XCTAssertTrue(moonEarndBadge.badgeEarned() == true)
        }
        else {
            XCTFail("Failed to get earn statuses")
        }
    }
    
    func testMagnetotailBadgeIsNotEarned() {
        if let earnStatuses = badgeEarnStatusMgr.badgeEarnStatuses {
            let magnetotailEarnedBadge = earnStatuses[3]
            XCTAssertTrue(magnetotailEarnedBadge.badgeEarned() == false)
        }
        else {
            XCTFail("Failed to get earn statuses")
        }
    }
    
    func testBestRunForEarthBadge() {
        if let earnStatuses = badgeEarnStatusMgr.badgeEarnStatuses {
            let earthEarnedBadge = earnStatuses[0]
            XCTAssertTrue(earthEarnedBadge.bestRun == mockDB.run2)
        }
        else {
            XCTFail("Failed to get earn statuses")
        }
    }
    
    func testSilverRunForEarthBadge() {
        if let earnStatuses = badgeEarnStatusMgr.badgeEarnStatuses {
            let earthEarnedBadge = earnStatuses[0]
            XCTAssertTrue(earthEarnedBadge.silverRun == mockDB.run2)
        }
        else {
            XCTFail("Failed to get earn statuses")
        }
    }
    
    func testGoldRunForEarthBadge() {
        if let earnStatuses = badgeEarnStatusMgr.badgeEarnStatuses {
            let earthEarnedBadge = earnStatuses[0]
            XCTAssertTrue(earthEarnedBadge.goldRun == mockDB.run2)
        }
        else {
            XCTFail("Failed to get earn statuses")
        }
    }
    
}
