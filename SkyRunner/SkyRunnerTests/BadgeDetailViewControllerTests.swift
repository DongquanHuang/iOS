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
    var bestRun: Run?
    
    var alertView = MockAlertView()
    
    class MockAlertView: UIAlertView {
        var theTitle: String?
        var theMessage: String?
        
        override func show() {
            theTitle = title
            theMessage = message
        }
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        store = try? storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType,
            configuration: nil, URL: nil, options: nil)
        managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        badgeDetailVC = storyBoard.instantiateViewControllerWithIdentifier("BadgeDetailViewController") as? BadgeDetailViewController
        badgeDetailVC?.view
        
        let badgeJsonString = ["name":"Earth", "imageName":"earth", "distance":"2.01", "information": "badgeInformation"]
        let badge = Badge(badgeJsonString: badgeJsonString)
        badgeEarnStatus = BadgeEarnStatus(badge: badge)
        
        earnRun = Run(context: managedObjectContext)
        earnRun?.timestamp = NSDate(timeIntervalSince1970: 1)
        earnRun?.duration = 13.0
        earnRun?.distance = 50.0
        badgeEarnStatus?.earnRun = earnRun
        
        silverRun = Run(context: managedObjectContext)
        silverRun?.timestamp = NSDate(timeIntervalSince1970: 1)
        badgeEarnStatus?.silverRun = silverRun
        
        goldRun = Run(context: managedObjectContext)
        goldRun?.timestamp = NSDate(timeIntervalSince1970: 1)
        badgeEarnStatus?.goldRun = goldRun
        
        bestRun = Run(context: managedObjectContext)
        bestRun?.duration = 11.0
        bestRun?.distance = 50.0
        badgeEarnStatus?.bestRun = bestRun
        
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
    
    func testSilverLabelShouldBeSetCorrectlyIfNotReached() {
        badgeEarnStatus?.silverRun = nil
        badgeDetailVC?.viewWillAppear(false)
        XCTAssertTrue(badgeDetailVC?.silverRunLabel.text == "Silver: Run 4.038 m/s to earn")
    }
    
    func testSilverLabelShouldBeSetCorrectlyIfReached() {
        XCTAssertTrue(badgeDetailVC?.silverRunLabel.text == "Silver: Reached @ Jan 1, 1970, 8:00:01 AM")
    }
    
    func testGoldLabelShouldBeSetCorrectlyIfNotReached() {
        badgeEarnStatus?.goldRun = nil
        badgeDetailVC?.viewWillAppear(false)
        XCTAssertTrue(badgeDetailVC?.goldRunLabel.text == "Gold: Run 4.231 m/s to earn")
    }
    
    func testGoldLabelShouldBeSetCorrectlyIfReached() {
        XCTAssertTrue(badgeDetailVC?.goldRunLabel.text == "Gold: Reached @ Jan 1, 1970, 8:00:01 AM")
    }
    
    func testBestLabelShouldBeSetCorrectly() {
        XCTAssertTrue(badgeDetailVC?.bestRunLabel.text == "Best: Your best speed is 4.545 m/s")
    }
    
    func testBestLabelIsHiddenIfNoBestRunSet() {
        badgeEarnStatus?.bestRun = nil
        badgeDetailVC?.viewWillAppear(false)
        XCTAssertTrue(badgeDetailVC?.bestRunLabel.hidden == true)
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
    
    func testAlertViewWillPopupAfterPressInfoButton() {
        badgeDetailVC?.badgeInfoAlertView = alertView
        badgeDetailVC?.showInfo(UIButton())
        XCTAssert(alertView.theTitle == "Earth")
        XCTAssert(alertView.theMessage == "badgeInformation")
        XCTAssert(alertView.delegate == nil)
        XCTAssert(alertView.buttonTitleAtIndex(0) == "OK")
    }

}
