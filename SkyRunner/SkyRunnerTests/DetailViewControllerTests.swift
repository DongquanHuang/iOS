//
//  DetailViewControllerTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/29/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest
import HealthKit
import CoreLocation
import MapKit
import CoreData

class DetailViewControllerTests: XCTestCase {
    
    // MARK: - Variables
    var storyBoard: UIStoryboard?
    var detailVC: DetailViewController?
    var homeVC: HomeViewController?
    var skyRun: SkyRun?
    
    var location1 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 10.0, longitude: 20.0), altitude: 30.0, horizontalAccuracy: 5.0, verticalAccuracy: 5.0, course: 5.0, speed: 2.0, timestamp: NSDate(timeIntervalSinceNow: 1))
    var location2 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 10.001, longitude: 20.001), altitude: 30.0, horizontalAccuracy: 5.0, verticalAccuracy: 5.0, course: 5.0, speed: 2.0, timestamp: NSDate(timeIntervalSinceNow: 3))
    var location3 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 10.002, longitude: 20.002), altitude: 30.0, horizontalAccuracy: 5.0, verticalAccuracy: 5.0, course: 5.0, speed: 2.0, timestamp: NSDate(timeIntervalSinceNow: 5))
    var locations = [CLLocation]()
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!
    
    // MARK: - Mock objects
    class MockDetailViewController: DetailViewController {
        var segueIdentifier: NSString?
        
        override func performSegueWithIdentifier(identifier: String?, sender: AnyObject?) {
            segueIdentifier = identifier
        }
    }

    // MARK: - Setup & Tear down
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        skyRun = SkyRun()
        skyRun?.distance = 100.0
        skyRun?.duration = 10.0
        skyRun?.timestamp = NSDate(timeIntervalSince1970: 100000)
        skyRun?.appendLocation(location1)
        skyRun?.appendLocation(location2)
        skyRun?.appendLocation(location3)
        
        locations.append(location1)
        locations.append(location2)
        locations.append(location3)
        
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        store = storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType,
            configuration: nil, URL: nil, options: nil, error: nil)
        
        managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        
        storyBoard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        
        detailVC = storyBoard?.instantiateViewControllerWithIdentifier("DetailViewController") as? DetailViewController
        detailVC?.view
        detailVC?.skyRun = skyRun
        detailVC?.viewWillAppear(false)
        
        homeVC = storyBoard?.instantiateViewControllerWithIdentifier("HomeViewController") as? HomeViewController
        homeVC?.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Tests
    func testPressDiscardWillGoBackToHomeViewController() {
        let controller = MockDetailViewController()
        controller.discardRun(UIButton())
        
        if let identifier = controller.segueIdentifier {
            XCTAssertEqual("Discard Run", identifier)
        }
        else {
            XCTFail("Segue should be performed")
        }
    }
    
    func testDistanceLabelShowsCorrectValue() {
        XCTAssertTrue(detailVC?.distanceLabel.text == "Distance: " + skyRun!.distance.description + " m")
    }
    
    func testDistanceLabelShowsNAIfNoRunValue() {
        setSkyRunToNilAndShowTheDetailView()
        
        XCTAssertTrue(detailVC?.distanceLabel.text == "Distance: N/A")
    }
    
    func testDateLabelShowsCorrectValue() {
        XCTAssertTrue(detailVC?.dateLabel.text == "Date: " + NSDate(timeIntervalSince1970: 100000).description)
    }
    
    func testDateLabelShowsNAIfNoRunValue() {
        setSkyRunToNilAndShowTheDetailView()
        
        XCTAssertTrue(detailVC?.dateLabel.text == "Date: N/A")
    }
    
    func testTimeLabelShowsCorrectValue() {
        XCTAssertTrue(detailVC?.timeLabel.text == "Duration: " + skyRun!.duration.description + " s")
    }
    
    func testTimeLabelShowsNAIfNoRunValue() {
        setSkyRunToNilAndShowTheDetailView()
        
        XCTAssertTrue(detailVC?.timeLabel.text == "Duration: N/A")
    }
    
    func testPaceLabelShowsCorrectValue() {
        let paceUnit = HKUnit.meterUnit().unitDividedByUnit(HKUnit.secondUnit())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: skyRun!.distance / skyRun!.duration)
        XCTAssertTrue(detailVC?.paceLabel.text == "Pace: " + paceQuantity.description)
    }
    
    func testPacLabelShowsNAIfNoRunValue() {
        setSkyRunToNilAndShowTheDetailView()
        
        XCTAssertTrue(detailVC?.paceLabel.text == "Pace: N/A")
    }
    
    func testMapViewDelegateSetCorrectly() {
        XCTAssertTrue(detailVC?.mapView.delegate?.isKindOfClass(DetailViewController) == true)
    }
    
    func testMapRegionSetCorrectly() {
        let region = mapRegion()
        let realRegion = detailVC?.mapView.regionThatFits(region)
        
        XCTAssertTrue(equalRegions((first: detailVC?.mapView.region, second: realRegion)) == true)
    }
    
    func testMapRegionSetToDefaultIfNoLocationInTheRunObject() {
        detailVC?.viewWillAppear(false)
        let originalMapRegion = detailVC?.mapView.region
        
        skyRun?.locations = [CLLocation]()
        detailVC?.viewWillAppear(false)
        let expectedMapRegion = detailVC?.mapView.region
        
        XCTAssertTrue(equalRegions((first: originalMapRegion, second: expectedMapRegion)) == true)
    }
    
    func testMapViewWillAddOverlaysForRunWhichHasMoreThanOneLocations() {
        XCTAssertTrue(detailVC?.mapView.overlays?.count == skyRun!.locations.count - 1)
    }
    
    func testMapViewWillNotAddOverlaysForRunWhichHasNoLocation() {
        detailVC?.skyRun = SkyRun()
        detailVC?.viewWillAppear(false)
        XCTAssertTrue(detailVC?.mapView.overlays.count == 0)
    }
    
    func testMapViewWillNotAddOverlaysForRunWhichHasOnlyOneLocation() {
        detailVC?.skyRun = SkyRun()
        detailVC?.skyRun?.appendLocation(location1)
        detailVC?.viewWillAppear(false)
        XCTAssertTrue(detailVC?.mapView.overlays.count == 0)
    }
    
    func testOverlaysCoordinatesAreCorrect() {
        let overlays = detailVC?.mapView.overlays
        let overlay1 = overlays![0] as! MKPolyline
        let overlay2 = overlays![1] as! MKPolyline
        
        let expectedOverlay1Coordinate = CLLocationCoordinate2D(latitude: (location1.coordinate.latitude + location2.coordinate.latitude) / 2, longitude: (location1.coordinate.longitude + location2.coordinate.longitude) / 2)
        let expectedOverlay2Coordinate = CLLocationCoordinate2D(latitude: (location2.coordinate.latitude + location3.coordinate.latitude) / 2, longitude: (location2.coordinate.longitude + location3.coordinate.longitude) / 2)
        
        XCTAssertTrue(equalCoordinates((overlay1.coordinate, expectedOverlay1Coordinate)) == true)
        XCTAssertTrue(equalCoordinates((overlay2.coordinate, expectedOverlay2Coordinate)) == true)
    }
    
    func testAddedOverlaysAreColorfulPolyline() {
        let overlays = detailVC?.mapView.overlays
        let overlay1 = overlays![0] as! MKPolyline
        
        XCTAssertTrue(overlay1.isKindOfClass(ColorfulPolyline) == true)
    }
    
    func testMapDelegateWillProvideRendererForColorfulPolyline() {
        let renderer = getRenderer()
        XCTAssertTrue(renderer != nil)
    }
    
    func testMapDelegateWillNotProvideRendererForNormalPolyline() {
        var coords = [CLLocationCoordinate2D]()
        coords.append(location1.coordinate)
        coords.append(location2.coordinate)
        let polyline = MKPolyline(coordinates: &coords, count: coords.count)
        let renderer = detailVC?.mapView(detailVC?.mapView, rendererForOverlay: polyline) as? MKOverlayPathRenderer
        
        XCTAssertTrue(renderer == nil)
    }
    
    func testMapDelegateWillProvideNilRendererForNonPolyline() {
        let area = Area()
        area.overlayBoundingMapRect = MKMapRect(origin: MKMapPoint(x: 0, y: 0), size: MKMapSize(width: 10, height: 10))
        area.midCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let renderer = detailVC?.mapView(detailVC?.mapView, rendererForOverlay: MyMapOverlay(area: area))
        XCTAssertTrue(renderer == nil)
    }
    
    func testMapDelegateWillProvideRendererColor() {
        let renderer = getRenderer()
        XCTAssertTrue(renderer?.strokeColor?.isEqual(UIColor.brownColor()) == true)
    }
    
    func testMapDelegateWillProvideRendererWithLineWidthOfFour() {
        let renderer = getRenderer()
        XCTAssertTrue(renderer?.lineWidth == 4.0)
    }
    
    func testPressSaveWillSaveTheRun() {
        detailVC?.managedObjectContext = managedObjectContext
        detailVC?.saveRun(UIButton())
        
        let fetchRequest = NSFetchRequest(entityName: "Run")
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let runs = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as! [Run]
        
        if runs.count > 0 {
            let theSkyRun = runs[0]
            
            XCTAssert(theSkyRun.distance == skyRun?.distance)
            XCTAssert(theSkyRun.duration == skyRun?.duration)
            XCTAssert(theSkyRun.locations.count == skyRun?.locations.count)
        }
        else {
            XCTFail("No Run saved")
        }
    }
    
    
    // MARK: - Helper methods
    private func setSkyRunToNilAndShowTheDetailView() {
        detailVC?.skyRun = nil
        detailVC?.viewWillAppear(false)
    }
    
    private func mapRegion() -> MKCoordinateRegion {
        let initialLoc = locations[0]
        
        var minLat = initialLoc.coordinate.latitude
        var minLng = initialLoc.coordinate.longitude
        var maxLat = minLat
        var maxLng = minLng
        
        for location in locations {
            minLat = min(minLat, location.coordinate.latitude)
            minLng = min(minLng, location.coordinate.longitude)
            maxLat = max(maxLat, location.coordinate.latitude)
            maxLng = max(maxLng, location.coordinate.longitude)
        }
        
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                longitude: (minLng + maxLng)/2),
            span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1,
                longitudeDelta: (maxLng - minLng)*1.1))
        
        return region
    }
    
    private func equalRegions(regions: (first: MKCoordinateRegion?, second: MKCoordinateRegion?)) -> Bool {
        let firstRegion = regions.first
        let secondRegion = regions.second
        
        if (firstRegion == nil || secondRegion == nil) {
            return false
        }
        
        let epsilon = 0.0000001
        
        return fabs(firstRegion!.center.latitude - secondRegion!.center.latitude) <= epsilon &&
        fabs(firstRegion!.center.longitude - secondRegion!.center.longitude) <= epsilon &&
        fabs(firstRegion!.span.latitudeDelta - secondRegion!.span.latitudeDelta) <= epsilon &&
        fabs(firstRegion!.span.longitudeDelta - secondRegion!.span.longitudeDelta) <= epsilon
    }
    
    private func equalCoordinates(coordinates: (first: CLLocationCoordinate2D?, second: CLLocationCoordinate2D?)?) -> Bool {
        if let validCoordinates = coordinates {
            let epsilon = 0.0000001
            if let firstCoordinate = validCoordinates.first {
                if let secondCoordinate = validCoordinates.second {
                    return fabs(firstCoordinate.latitude - secondCoordinate.latitude) <= epsilon && fabs(firstCoordinate.longitude - secondCoordinate.longitude) <= epsilon
                }
            }
        }
        
        return false
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
    
    private func getRenderer() -> MKOverlayPathRenderer? {
        var coords = [CLLocationCoordinate2D]()
        coords.append(location1.coordinate)
        coords.append(location2.coordinate)
        let polyline = ColorfulPolyline(coordinates: &coords, count: coords.count)
        polyline.color = UIColor.brownColor()
        
        let renderer = detailVC?.mapView(detailVC?.mapView, rendererForOverlay: polyline) as? MKOverlayPathRenderer
        return renderer
    }

}
