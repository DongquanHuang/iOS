//
//  BadgeDetailViewControllerTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 8/5/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest
import CoreData

class BadgeDetailViewControllerTests: XCTestCase {
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!
    
    var badgeDetailVC: BadgeDetailViewController?
    var badgeEarnStatus: BadgeEarnStatus?
    var earnRun: Run?
    var silverRun: Run?
    var goldRun: Run?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        store = storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType,
            configuration: nil, URL: nil, options: nil, error: nil)
        managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        
        var storyBoard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        badgeDetailVC = storyBoard.instantiateViewControllerWithIdentifier("BadgeDetailViewController") as? BadgeDetailViewController
        badgeDetailVC?.view
        
        let badgeJsonString = ["name":"Earth", "imageName":"earth", "distance":"2.01", "information": "badgeInformation1"]
        var badge = Badge(badgeJsonString: badgeJsonString)
        badgeEarnStatus = BadgeEarnStatus(badge: badge)
        
        earnRun = Run(context: managedObjectContext)
        earnRun?.timestamp = NSDate(timeIntervalSince1970: 1)
        earnRun?.duration = 13.0
        earnRun?.distance = 50.0
        badgeEarnStatus?.earnRun = earnRun
        
        silverRun = Run(context: managedObjectContext)
        badgeEarnStatus?.silverRun = silverRun
        
        goldRun = Run(context: managedObjectContext)
        badgeEarnStatus?.goldRun = goldRun
        
        badgeDetailVC?.badgeEarnStatus = badgeEarnStatus
        badgeDetailVC?.viewWillAppear(false)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testImageShouldBeSetCorrectly() {
        XCTAssertTrue(badgeDetailVC?.badgeImageView.image != nil)
    }
    
    func testBadgeNameShouldBeSetCorrectly() {
        XCTAssertTrue(badgeDetailVC?.badgeNameLabel.text == "Earth")
    }
    
    func testDistanceLabelShouldBeSetCorrectly() {
        XCTAssertTrue(badgeDetailVC?.distanceLabel.text == "Distance: 2.01")
    }
    
    func testEarnLabelShouldBeSetCorrectly() {
        XCTAssertTrue(badgeDetailVC?.earnRunLabel.text == "Earned: Jan 1, 1970, 8:00:01 AM")
    }
    
    func testSilverLabelShouldBeSetCorrectly() {
        XCTAssertTrue(badgeDetailVC?.silverRunLabel.text == "Silver: Run 4.038 m/s to earn")
    }
    
    func testGoldLabelShouldBeSetCorrectly() {
        XCTAssertTrue(badgeDetailVC?.goldRunLabel.text == "Gold: Run 4.231 m/s to earn")
    }
    
    func testBestLabelShouldBeSetCorrectly() {
        XCTFail("fail")
    }
    
    func testSilverImageShouldBeVisibleIfSilverRunIsNotNil() {
        XCTAssertTrue(badgeDetailVC?.silverImageView.hidden == false)
    }
    
    func testSilverImageShouldBeInvisibleIfSilverRunIsNil() {
        badgeEarnStatus?.silverRun = nil
        badgeDetailVC?.viewWillAppear(false)
        XCTAssertTrue(badgeDetailVC?.silverImageView.hidden == true)
    }
    
    func testGoldImageShouldBeVisibleIfGoldRunIsNotNil() {
        XCTAssertTrue(badgeDetailVC?.goldImageView.hidden == false)
    }
    
    func testGoldImageShouldBeInvisibleIfGoldRunIsNil() {
        badgeEarnStatus?.goldRun = nil
        badgeDetailVC?.viewWillAppear(false)
        XCTAssertTrue(badgeDetailVC?.goldImageView.hidden == true)
    }

}
