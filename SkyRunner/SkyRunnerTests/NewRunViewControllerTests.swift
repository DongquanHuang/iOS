//
//  NewRunViewControllerTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/27/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest
import CoreLocation
import MapKit
import HealthKit
import CoreData
import ObjectiveC

class NewRunViewControllerTests: XCTestCase {
    
    var storyBoard: UIStoryboard?
    var newRunVC: NewRunViewController?
    var detailVC: DetailViewController?
    var homeVC: HomeViewController?
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!
    
    class MockNewRunViewController: NewRunViewController {
        var segueIdentifier: NSString?
        
        override func performSegueWithIdentifier(identifier: String?, sender: AnyObject?) {
            segueIdentifier = identifier
        }
    }
    
    var location1 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 10.0, longitude: 20.0), altitude: 30.0, horizontalAccuracy: 5.0, verticalAccuracy: 5.0, course: 5.0, speed: 2.0, timestamp: NSDate(timeIntervalSinceNow: 1))
    var location2 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 10.01, longitude: 20.01), altitude: 30.0, horizontalAccuracy: 5.0, verticalAccuracy: 5.0, course: 5.0, speed: 2.0, timestamp: NSDate(timeIntervalSinceNow: 5))
    
    class MockLocationManager: LocationManager {
        var stopped: Bool = false
        var started: Bool = false
        
        override func stopLocationUpdate() {
            stopped = true
            started = false
        }
        
        override func startLocationUpdate() {
            stopped = false
            started = true
        }
    }
    
    class MockDate: NSDate {
        override var timeIntervalSince1970: NSTimeInterval {
            get {
                return 10000
            }
        }
    }
    
    func swizzledEachSecond(timer: NSTimer) {
        timer.invalidate()
    }

    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        storyBoard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        newRunVC = storyBoard?.instantiateViewControllerWithIdentifier("NewRunViewController") as? NewRunViewController
        newRunVC?.view  //Must invoke this, so the IBOutlets are linked
        newRunVC?.viewWillAppear(false)
        
        detailVC = storyBoard?.instantiateViewControllerWithIdentifier("DetailViewController") as? DetailViewController
        detailVC?.view
        
        homeVC = storyBoard?.instantiateViewControllerWithIdentifier("HomeViewController") as? HomeViewController
        homeVC?.view
        
        // Prepare Core Data context
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        store = storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType,
            configuration: nil, URL: nil, options: nil, error: nil)
        
        managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - before run
    func testPromptLabelShouldBeVisibleAfterViewAppears() {
        XCTAssertTrue(newRunVC?.promptLabel.hidden == false)
    }
    
    func testDistanceLabelShouldBeHideAfterViewAppears() {
        XCTAssertTrue(newRunVC?.distanceLabel.hidden == true)
    }
    
    func testTimeLabelShouldBeHideAfterViewAppears() {
        XCTAssertTrue(newRunVC?.timeLabel.hidden == true)
    }
    
    func testPaceLabelShouldBeHideAfterViewAppears() {
        XCTAssertTrue(newRunVC?.paceLabel.hidden == true)
    }
    
    func testStartButtonShouldBeVisibleAfterViewAppears() {
        XCTAssertTrue(newRunVC?.startButton.hidden == false)
    }

    func testStopButtonShouldBeHideAfterViewAppears() {
        XCTAssertTrue(newRunVC?.stopButton.hidden == true)
    }
    
    func testCancelButtonShouldBeVisibleAfterViewAppears() {
        XCTAssertTrue(newRunVC?.cancelButton.hidden == false)
    }
    
    func testEarnedBadgeImageViewShouldBeHideAfterViewAppears() {
        XCTAssertTrue(newRunVC?.earnedBadgeImageView.hidden == true)
    }
    
    func testEarnedBadgeLabelShouldBeHideAfterViewAppears() {
        XCTAssertTrue(newRunVC?.earnedBadgeLabel.hidden == true)
    }
    
    func testNoTimerBeforeRun() {
        XCTAssertTrue(newRunVC?.timer == nil)
    }
    
    func testTimerWillBeInvalideAfterViewDisappears() {
        newRunVC?.viewWillDisappear(false)
        XCTAssertTrue(newRunVC?.timer == nil)
    }
    
    func testLocationManagerWillStopAfterViewDisappears() {
        newRunVC?.viewWillDisappear(false)
        XCTAssertTrue(newRunVC?.locationManager == nil)
    }
    
    func testLocationManagerNotStartedAfterViewAppears() {
        XCTAssertTrue(newRunVC?.locationManager == nil)
    }
    
    func testPressCancelWillGoBackToHomeViewController() {
        let controller = MockNewRunViewController()
        controller.cancelRun(UIButton())
        
        if let identifier = controller.segueIdentifier {
            XCTAssertEqual("Cancel Run", identifier)
        }
        else {
            XCTFail("Segue should be performed")
        }
    }
    
    // MARK: - during running
    func testPressStartWillHideStartButton() {
        newRunVC?.startRun(newRunVC!.startButton)
        XCTAssertTrue(newRunVC?.startButton.hidden == true)
    }
    
    func testPressStartWillHideCancelButton() {
        newRunVC?.startRun(newRunVC!.startButton)
        XCTAssertTrue(newRunVC?.cancelButton.hidden == true)
    }
    
    func testPressStartWillMakeStopButtonVisible() {
        newRunVC?.startRun(newRunVC!.startButton)
        XCTAssertTrue(newRunVC?.stopButton.hidden == false)
    }
    
    func testPressStartWillMakeEarnedBadgeImageViewVisible() {
        newRunVC?.startRun(newRunVC!.startButton)
        XCTAssertTrue(newRunVC?.earnedBadgeImageView.hidden == false)
    }
    
    func testPressStartWillMakeEarnedBadgeLabelVisible() {
        newRunVC?.startRun(newRunVC!.startButton)
        XCTAssertTrue(newRunVC?.earnedBadgeLabel.hidden == false)
    }
    
    func testPressStartWillMakePromptLabelHidden() {
        newRunVC?.startRun(newRunVC!.startButton)
        XCTAssertTrue(newRunVC?.promptLabel.hidden == true)
    }
    
    func testPressStartWillMakeDistanceLabelVisible() {
        newRunVC?.startRun(newRunVC!.startButton)
        XCTAssertTrue(newRunVC?.distanceLabel.hidden == false)
    }
    
    func testPressStartWillMakeTimeLabelVisible() {
        newRunVC?.startRun(newRunVC!.startButton)
        XCTAssertTrue(newRunVC?.timeLabel.hidden == false)
    }
    
    func testPressStartWillMakePaceLabelVisible() {
        newRunVC?.startRun(newRunVC!.startButton)
        XCTAssertTrue(newRunVC?.paceLabel.hidden == false)
    }
    
    func testPressStartWillRecordTheTimeStampForRun() {
        let mockDate = MockDate()
        newRunVC?.timestamp = mockDate
        
        newRunVC?.startRun(newRunVC!.startButton)
        let timestamp = newRunVC?.skyRun.timestamp
        let expectedTimeStamp = NSDate(timeIntervalSince1970: mockDate.timeIntervalSince1970)
        
        XCTAssertTrue(timestamp?.description == expectedTimeStamp.description)
    }
    
    func testPressStartWillStartTimer() {
        newRunVC?.startRun(newRunVC!.startButton)
        XCTAssertTrue(newRunVC?.timer != nil)
    }
    
    func testEachSecondMethodWillGetCalledAfterTimerStarted() {
        let originalSelector = Selector("eachSecond:")
        let swizzledSelector = Selector("swizzledEachSecond:")
        let originalMethod = class_getInstanceMethod(object_getClass(newRunVC), originalSelector)
        let swizzledMethod = class_getInstanceMethod(object_getClass(self), swizzledSelector)
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
        newRunVC?.startRun(newRunVC!.startButton)
        newRunVC?.timer?.fire()
        
        XCTAssertTrue(newRunVC?.timer?.valid == false)
    }
    
    func testPressStartWillStartLocationManager() {
        newRunVC?.startRun(newRunVC!.startButton)
        XCTAssertTrue(newRunVC?.locationManager != nil)
    }
    
    func testStartLocationMethodGetsCalledWhenPressStartButton() {
        let locMgr = MockLocationManager()
        newRunVC?.locationManager = locMgr
        newRunVC?.startRun(newRunVC!.startButton)
        XCTAssertTrue(locMgr.started == true)
    }
    
    func testDelegateOfLocationManagerIsSelf() {
        newRunVC?.startRun(newRunVC!.startButton)
        let delegate = newRunVC?.locationManager?.delegate as? NewRunViewController
        XCTAssertTrue(delegate == newRunVC!)
    }
    
    func testDistanceWillNotUpdateAfterOnlyOneLocationUpdate() {
        var location1 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 10.0, longitude: 20.0), altitude: 30.0, horizontalAccuracy: 5.0, verticalAccuracy: 5.0, course: 5.0, speed: 2.0, timestamp: NSDate())
        
        let originalDistance = newRunVC?.skyRun.distance
        newRunVC?.startRun(newRunVC!.startButton)
        newRunVC?.locationManager?.locationManager(nil, didUpdateLocations: [location1])
        let currentDistance = newRunVC?.skyRun.distance
        
        XCTAssertTrue(currentDistance == originalDistance)
    }
    
    private func serveOneLocation() {
        newRunVC?.startRun(newRunVC!.startButton)
        newRunVC?.locationManager?.locationManager(nil, didUpdateLocations: [location1])
    }
    
    private func serveTwoLocations() {
        newRunVC?.startRun(newRunVC!.startButton)
        newRunVC?.locationManager?.locationManager(nil, didUpdateLocations: [location1])
        newRunVC?.locationManager?.locationManager(nil, didUpdateLocations: [location2])
    }
    
    private func distanceBetweenTwoLocations() -> Double {
        return location2.distanceFromLocation(location1)
    }
    
    private func healthKitDistanceBetweenTwoLocations() -> String! {
        let distance = distanceBetweenTwoLocations()
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: distance)
        return "Distance: " + distanceQuantity.description
    }
    
    private func healthKitPaceBetweenTwoLocationsForOneSecond() -> String! {
        let distance = distanceBetweenTwoLocations()
        let paceUnit = HKUnit.meterUnit().unitDividedByUnit(HKUnit.secondUnit())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: distance / 1.0)
        return "Pace: " + paceQuantity.description
    }
    
    func testDistanceGetsUpdatedAfterTwoLocationUpdates() {
        let originalDistance = newRunVC?.skyRun.distance
        serveTwoLocations()
        let currentDistance = newRunVC?.skyRun.distance
        
        let distanceGap = distanceBetweenTwoLocations()
        
        XCTAssertTrue(currentDistance! == originalDistance! + distanceGap)
    }
    
    func testDistanceLabelGetsUpdatedAfterTwoLocationUpdates() {
        serveTwoLocations()
        
        newRunVC?.eachSecond(NSTimer())
        let distanceString = newRunVC?.distanceLabel.text
        let expectedDistanceString = healthKitDistanceBetweenTwoLocations()
        
        XCTAssertTrue(distanceString == expectedDistanceString)
    }
    
    func testTimeLabelGetsUpdatedForEachSecond() {
        newRunVC?.startRun(newRunVC!.startButton)
        newRunVC?.eachSecond(NSTimer())
        let timeString = newRunVC?.timeLabel.text
        
        XCTAssertTrue(timeString == "Time: 1 s")
    }
    
    func testRunLocationsGetSavedAfterLocationUpdate() {
        serveTwoLocations()
        
        XCTAssertTrue(newRunVC?.skyRun.locations.count == 2)
    }
    
    func testRunLocationTimestampIsSavedAfterLocationUpdate() {
        serveOneLocation()
        let expectedTimestamp = location1.timestamp
        let savedLocation = newRunVC?.skyRun.locations[0]
        let savedTimestamp = savedLocation?.timestamp
        
        XCTAssertTrue(expectedTimestamp == savedTimestamp)
    }
    
    func testLocationUpdateWithNilLocation() {
        newRunVC?.locationUpdated()
        XCTAssertTrue(newRunVC?.locationManager?.locations == nil)
    }
    
    func testPaceLabelGetsUpdated() {
        serveTwoLocations()
        
        newRunVC?.eachSecond(NSTimer())
        let paceString = newRunVC?.paceLabel.text
        let expectedPaceString = healthKitPaceBetweenTwoLocationsForOneSecond()
        
        XCTAssertTrue(paceString == expectedPaceString)
    }
    
    private func getRenderer() -> MKOverlayPathRenderer? {
        var coords = [CLLocationCoordinate2D]()
        coords.append(location1.coordinate)
        coords.append(location2.coordinate)
        let polyline = MKPolyline(coordinates: &coords, count: coords.count)
        
        let renderer = newRunVC?.mapView(newRunVC?.mapView, rendererForOverlay: polyline) as? MKOverlayPathRenderer
        return renderer
    }
    
    func testMapDelegateWillProvideRendererForPolyline() {
        let renderer = getRenderer()
        XCTAssertTrue(renderer != nil)
    }
    
    class Area {
        var overlayBoundingMapRect: MKMapRect?
        var midCoordinate: CLLocationCoordinate2D?
    }
    
    class MyMapOverlay: NSObject, MKOverlay {
        var coordinate: CLLocationCoordinate2D
        var boundingMapRect: MKMapRect
        
        init(area: Area) {
            boundingMapRect = area.overlayBoundingMapRect!
            coordinate = area.midCoordinate!
        }
    }
    
    func testMapDelegateWillProvideNilRendererForNonPolyline() {
        let area = Area()
        area.overlayBoundingMapRect = MKMapRect(origin: MKMapPoint(x: 0, y: 0), size: MKMapSize(width: 10, height: 10))
        area.midCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let renderer = newRunVC?.mapView(newRunVC?.mapView, rendererForOverlay: MyMapOverlay(area: area))
        XCTAssertTrue(renderer == nil)
    }
    
    func testMapDelegateWillProvideRendererWithBlueColor() {
        let renderer = getRenderer()
        XCTAssertTrue(renderer?.strokeColor == UIColor.blueColor())
    }
    
    func testMapDelegateWillProvideRendererWithLineWidthOfFour() {
        let renderer = getRenderer()
        XCTAssertTrue(renderer?.lineWidth == 4.0)
    }
    
    func testFirstLocationUpdateWillNotAddOverlayToMap() {
        let mapView = newRunVC?.mapView
        serveOneLocation()
        let currentOverlayCount = mapView?.overlays?.count
        
        XCTAssertTrue(currentOverlayCount == nil)
    }
    
    func testLocationUpdateWillAddOverlayToMap() {
        let mapView = newRunVC?.mapView
        serveTwoLocations()
        let currentOverlayCount = mapView?.overlays?.count
        
        XCTAssertTrue(currentOverlayCount == 1)
    }
    
    private func equalCoordinates(coordinates: (first: CLLocationCoordinate2D?, second: CLLocationCoordinate2D?)?) -> Bool {
        if let validCoordinates = coordinates {
            let epsilon = 0.0000000000001
            if let firstCoordinate = validCoordinates.first {
                if let secondCoordinate = validCoordinates.second {
                return fabs(firstCoordinate.latitude - secondCoordinate.latitude) <= epsilon && fabs(firstCoordinate.longitude - secondCoordinate.longitude) <= epsilon
                }
            }
        }
        
        return false
    }
    
    func testMapCenterIsSetToLatestLocationCoordinate() {
        let mapView = newRunVC?.mapView
        serveTwoLocations()
        
        XCTAssertTrue(equalCoordinates((mapView?.region.center, location2.coordinate)) == true)
    }
    
    func testMapViewDelegateIsSetCorrectly() {
        XCTAssertTrue(newRunVC?.mapView?.delegate.isKindOfClass(NewRunViewController) == true)
    }
    
    // MARK: - stop run
    func testPressStopWillStopTimer() {
        newRunVC?.startRun(newRunVC!.startButton)
        newRunVC?.stopRun(newRunVC!.stopButton)
        XCTAssertTrue(newRunVC?.timer == nil)
    }
    
    func testPressStopWillStopLocationManager() {
        newRunVC?.startRun(newRunVC!.startButton)
        newRunVC?.stopRun(newRunVC!.stopButton)
        XCTAssertTrue(newRunVC?.locationManager == nil)
    }
    
    func testStopLocationMethodGetsCalledWhenPressStopButton() {
        let locMgr = MockLocationManager()
        newRunVC?.locationManager = locMgr
        newRunVC?.startRun(newRunVC!.startButton)
        newRunVC?.stopRun(newRunVC!.stopButton)
        XCTAssertTrue(locMgr.stopped == true)
    }
    
    func testDelegateOfLocationManagerSetsToNilAfterPressStopButton() {
        newRunVC?.startRun(newRunVC!.startButton)
        newRunVC?.stopRun(newRunVC!.stopButton)
        XCTAssertTrue(newRunVC!.locationManager?.delegate == nil)
    }
    
    func testPressStopButtonWillTransitToDetailViewController() {
        let controller = MockNewRunViewController()
        controller.stopRun(UIButton())
        
        if let identifier = controller.segueIdentifier {
            XCTAssertEqual("Show Run Detail", identifier)
        }
        else {
            XCTFail("Segue should be performed")
        }
    }
    
    func testCoreDataContextPassedToDetailViewController() {
        newRunVC?.managedObjectContext = managedObjectContext
        let segue = UIStoryboardSegue(identifier: "Show Run Detail", source: newRunVC!, destination: detailVC!)
        newRunVC?.prepareForSegue(segue, sender: nil)
        
        if let passedArgument = detailVC?.managedObjectContext {
            XCTAssertEqual(managedObjectContext, passedArgument)
        }
        else {
            XCTFail("Argument should be passed")
        }
    }
    
    func testLatestRunPassedToDetailViewController() {
        let run = SkyRun()
        newRunVC?.skyRun = run
        let segue = UIStoryboardSegue(identifier: "Show Run Detail", source: newRunVC!, destination: detailVC!)
        newRunVC?.prepareForSegue(segue, sender: nil)
        
        if let passedArgument = detailVC?.skyRun {
            XCTAssertEqual(run, passedArgument)
        }
        else {
            XCTFail("Argument should be passed")
        }
    }

}
