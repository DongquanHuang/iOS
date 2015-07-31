//
//  ColorfulPolyline.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/30/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import MapKit

class ColorfulPolyline: MKPolyline {
    var color: UIColor?
}

class ColorfulPolylineGenerator: NSObject {
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
    
    private var polylines = [ColorfulPolyline]()
    
    func produceColorfulPolylinesForLocations(locations: [CLLocation]) -> [ColorfulPolyline] {
        generatePolylines(locations)
        fillColorForPolylinesBasedOnLocations(locations)
        
        return polylines
    }
    
    private func generatePolylines(locations: [CLLocation]) {
        for i in 1 ..< locations.count {
            var coords = [CLLocationCoordinate2D]()
            coords.append(locations[i - 1].coordinate)
            coords.append(locations[i].coordinate)
            
            let polyline = ColorfulPolyline(coordinates: &coords, count: coords.count)
            polylines.append(polyline)
        }
    }
    
    private func fillColorForPolylinesBasedOnLocations(locations: [CLLocation]) {
        var colors = colorSegementsForLocations(locations)
        
        for i in 0 ..< colors.count {
            polylines[i].color = colors[i]
        }
    }
    
    private func colorSegementsForLocations(locations: [CLLocation]) -> [UIColor] {
        var colors = [UIColor]()
        let speeds = speedSegmentsForLocations(locations)
        let average = averageSpeed(speeds)
        
        for i in 0 ..< speeds.count {
            let speed = speeds[i]
            if slowSpeed(speed, averageSpeed: average) {
                let redColor = UIColor(red: CGFloat(ColorConstants.RedColor.r), green: CGFloat(ColorConstants.RedColor.g), blue: CGFloat(ColorConstants.RedColor.b), alpha: 1.0)
                colors.append(redColor)
            }
            else if fastSpeed(speed, averageSpeed: average) {
                let greenColor = UIColor(red: CGFloat(ColorConstants.GreenColor.r), green: CGFloat(ColorConstants.GreenColor.g), blue: CGFloat(ColorConstants.GreenColor.b), alpha: 1.0)
                colors.append(greenColor)
            }
            else {
                let yellowColor = UIColor(red: CGFloat(ColorConstants.YellowColor.r), green: CGFloat(ColorConstants.YellowColor.g), blue: CGFloat(ColorConstants.YellowColor.b), alpha: 1.0)
                colors.append(yellowColor)
            }
        }
        
        return colors
    }
    
    private func speedSegmentsForLocations(locations: [CLLocation]) -> [Double] {
        var speeds = [Double]()
        
        for i in 1 ..< locations.count {
            let startLocation = locations[i - 1]
            let endLocation = locations[i]
            let distance = endLocation.distanceFromLocation(startLocation)
            let timeGap = endLocation.timestamp.timeIntervalSinceDate(startLocation.timestamp)
            let speed = distance / timeGap
            
            speeds.append(speed)
        }
        
        return speeds
    }
    
    private func averageSpeed(speeds: [Double]) -> Double {
        var averageSpeed = 0.0
        var sumSpeed = 0.0
        
        for i in 0 ..< speeds.count {
            sumSpeed += speeds[i]
        }
        
        averageSpeed = sumSpeed / Double(speeds.count)
        
        return averageSpeed
    }
    
    private func slowSpeed(speed: Double, averageSpeed: Double) -> Bool {
        return speed < averageSpeed * SpeedFactor.SlowFactor
    }
    
    private func fastSpeed(speed: Double, averageSpeed: Double) -> Bool {
        return speed > averageSpeed * SpeedFactor.FastFactor
    }
    
}
