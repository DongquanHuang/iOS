//
//  LocationManagerTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/27/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest
import CoreLocation

class LocationManagerTests: XCTestCase {
    
    class MockLocationMgrDelegate: NSObject, LocationManagerDelegate {
        var delegateMethodGetsCalled = false
        
        func locationUpdated() {
            delegateMethodGetsCalled = true
        }
    }
    
    var locationMgr: LocationManager?
    var locations: [CLLocation]?
    var location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 10.0, longitude: 20.0), altitude: 30.0, horizontalAccuracy: 5.0, verticalAccuracy: 5.0, course: 5.0, speed: 2.0, timestamp: NSDate())
    var inaccurateLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 10.0, longitude: 20.0), altitude: 30.0, horizontalAccuracy: 25.0, verticalAccuracy: 5.0, course: 5.0, speed: 2.0, timestamp: NSDate())
    var outOfDateLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 10.0, longitude: 20.0), altitude: 30.0, horizontalAccuracy: 15.0, verticalAccuracy: 5.0, course: 5.0, speed: 2.0, timestamp: NSDate(timeIntervalSince1970: 1000))
    var locationMgrDelegate: MockLocationMgrDelegate?
    

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        locationMgr = LocationManager()
        locationMgrDelegate = MockLocationMgrDelegate()
        locationMgr?.delegate = locationMgrDelegate
        locations = [CLLocation]()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLocationManagerHasLocationsProperty() {
        XCTAssertTrue(locationMgr?.locations != nil)
    }
    
    func testLocationManagerHasEmptyLocationsRightAfterInitialized() {
        XCTAssertTrue(locationMgr?.locations.count == 0)
    }
    
    func testLocationManagerWillOnlySaveLocationIfItIsARecentUpdate() {
        locations?.append(location)
        locationMgr?.locationManager(CLLocationManager(), didUpdateLocations: locations!)
        XCTAssertTrue(locationMgr?.locations.count == 1)
    }
    
    func testLocationManagerWillNotSaveLocationIfTheUpdateIsNotAccuratyEnough() {
        locations?.append(inaccurateLocation)
        locationMgr?.locationManager(CLLocationManager(), didUpdateLocations: locations!)
        XCTAssertTrue(locationMgr?.locations.count == 0)
    }
    
    func testLocationManagerWillNotSaveLocationIfItIsOutOfDate() {
        locations?.append(outOfDateLocation)
        locationMgr?.locationManager(CLLocationManager(), didUpdateLocations: locations!)
        XCTAssertTrue(locationMgr?.locations.count == 0)
    }
    
    func testDelegateMethodGetsCalledIfGetsValidLocationUpdate() {
        locations?.append(location)
        locationMgr?.locationManager(CLLocationManager(), didUpdateLocations: locations!)
        XCTAssertTrue(locationMgrDelegate?.delegateMethodGetsCalled == true)
    }
    
}
