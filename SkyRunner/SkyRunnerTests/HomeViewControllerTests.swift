//
//  HomeViewControllerTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/23/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest
import CoreData

import SkyRunner

class HomeViewControllerTests: XCTestCase {
    
    var homeViewController: HomeViewController?
    var newRunVC: NewRunViewController?
    var badgesTVC: BadgesTableViewController?
    
    class MockHomeViewController: HomeViewController {
        var segueIdentifier: NSString?
        
        override func performSegueWithIdentifier(identifier: String, sender: AnyObject?) {
            segueIdentifier = identifier
        }
    }
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        homeViewController = storyBoard.instantiateViewControllerWithIdentifier("HomeViewController") as? HomeViewController
        homeViewController?.view    // Force link IBOutlets
        newRunVC = storyBoard.instantiateViewControllerWithIdentifier("NewRunViewController") as? NewRunViewController
        newRunVC?.view
        badgesTVC = storyBoard.instantiateViewControllerWithIdentifier("BadgesTableViewController") as? BadgesTableViewController
        badgesTVC?.view
        
        // Prepare Core Data context
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        store = try? storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType,
            configuration: nil, URL: nil, options: nil)
        
        managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testHomeViewControllerHasManagedObjectContextProperty() {
        XCTAssertTrue(homeViewController?.managedObjectContext == nil)
    }
    
    func testCanSetManagedObjectContextProperty() {
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        _ = try? storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType,
            configuration: nil, URL: nil, options: nil)
        
        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        
        homeViewController?.managedObjectContext = managedObjectContext
        
        XCTAssertTrue(homeViewController?.managedObjectContext == managedObjectContext)
    }
    
    func testPressNewRunButtonWillTransitToNextViewController() {
        let controller = MockHomeViewController()
        controller.startNewRun(UIButton())
        
        if let identifier = controller.segueIdentifier {
            XCTAssertEqual("New Run", identifier)
        }
        else {
            XCTFail("Segue should be performed")
        }
    }
    
    func testPressBadgesButtonWillTransitToNextViewController() {
        let controller = MockHomeViewController()
        controller.showBadges(UIButton())
        
        if let identifier = controller.segueIdentifier {
            XCTAssertEqual("Show Badges", identifier)
        }
        else {
            XCTFail("Segue should be performed")
        }
    }
    
    func testCoreDataContextPassedToNewRunViewController() {
        homeViewController?.managedObjectContext = managedObjectContext
        let segue = UIStoryboardSegue(identifier: "New Run", source: homeViewController!, destination: newRunVC!)
        homeViewController?.prepareForSegue(segue, sender: nil)
        
        if let passedArgument = newRunVC?.managedObjectContext {
            XCTAssertEqual(managedObjectContext, passedArgument)
        }
        else {
            XCTFail("Argument should be passed")
        }
    }
    
    func testCoreDataContextPassedToBadgesTableViewController() {
        homeViewController?.managedObjectContext = managedObjectContext
        let segue = UIStoryboardSegue(identifier: "Show Badges", source: homeViewController!, destination: badgesTVC!)
        homeViewController?.prepareForSegue(segue, sender: nil)
        
        if let passedArgument = badgesTVC?.managedObjectContext {
            XCTAssertEqual(managedObjectContext, passedArgument)
        }
        else {
            XCTFail("Argument should be passed")
        }
    }

}
