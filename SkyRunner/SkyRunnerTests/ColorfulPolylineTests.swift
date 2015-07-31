//
//  ColorfulPolylineTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/30/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest
import CoreLocation

class ColorfulPolylineTests: XCTestCase {
    
    struct ColorConstants {
        // Slow run speed
        static let RedColor   = (r: 1.0, g: 20.0 / 255.0, b: 44.0 / 255.0)
        // Middle run speed
        static let YellowColor = (r: 1.0, g: 215.0 / 255.0, b: 0.0)
        // Fast run speed
        static let GreenColor  = (r: 0.0, g: 146.0 / 255.0, b: 78.0 / 255.0)
    }
    
    struct SpeedFactor {
        static let SlowFactor = 0.9     // Slower than average speed * 0.9
        static let FastFactor = 1.1     // Faster than average speed * 1.1
    }
    
    var colorfulPolyline = ColorfulPolyline()
    var colorfulPolylineGenerator = ColorfulPolylineGenerator()
    
    var location1 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 10.0, longitude: 20.0), altitude: 30.0, horizontalAccuracy: 5.0, verticalAccuracy: 5.0, course: 5.0, speed: 2.0, timestamp: NSDate(timeIntervalSinceNow: 1))
    var location2 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 10.001, longitude: 20.001), altitude: 30.0, horizontalAccuracy: 5.0, verticalAccuracy: 5.0, course: 5.0, speed: 2.0, timestamp: NSDate(timeIntervalSinceNow: 5))
    var location3 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 10.002, longitude: 20.002), altitude: 30.0, horizontalAccuracy: 5.0, verticalAccuracy: 5.0, course: 5.0, speed: 2.0, timestamp: NSDate(timeIntervalSinceNow: 7))
    var location4 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 10.003, longitude: 20.003), altitude: 30.0, horizontalAccuracy: 5.0, verticalAccuracy: 5.0, course: 5.0, speed: 2.0, timestamp: NSDate(timeIntervalSinceNow: 10))
    var locations = [CLLocation]()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        locations.append(location1)
        locations.append(location2)
        locations.append(location3)
        locations.append(location4)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testColorfulPolylineHasColorProperty() {
        colorfulPolyline.color = UIColor.orangeColor()
        
        XCTAssertTrue(colorfulPolyline.color == UIColor.orangeColor())
    }
    
    func testGeneratorCanProducePolylinesBasedOnLocations() {
        var polylines = colorfulPolylineGenerator.produceColorfulPolylinesForLocations(locations)
        
        XCTAssertTrue(polylines.count == locations.count - 1)
    }
    
    func testPolylinesHasExpectedColors() {
        var polylines = colorfulPolylineGenerator.produceColorfulPolylinesForLocations(locations)
        
        let polyline1 = polylines[0]
        let polyline2 = polylines[1]
        let polyline3 = polylines[2]
        
        let redColor = UIColor(red: CGFloat(ColorConstants.RedColor.r), green: CGFloat(ColorConstants.RedColor.g), blue: CGFloat(ColorConstants.RedColor.b), alpha: 1.0)
        let greenColor = UIColor(red: CGFloat(ColorConstants.GreenColor.r), green: CGFloat(ColorConstants.GreenColor.g), blue: CGFloat(ColorConstants.GreenColor.b), alpha: 1.0)
        let yellowColor = UIColor(red: CGFloat(ColorConstants.YellowColor.r), green: CGFloat(ColorConstants.YellowColor.g), blue: CGFloat(ColorConstants.YellowColor.b), alpha: 1.0)
        
        XCTAssertTrue(polyline1.color!.isEqual(redColor) == true)
        XCTAssertTrue(polyline2.color!.isEqual(greenColor) == true)
        XCTAssertTrue(polyline3.color!.isEqual(yellowColor) == true)
    }

}
