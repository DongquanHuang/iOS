//
//  LocationManager.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/27/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import Foundation
import CoreLocation

struct Constants {
    static let CL_DistanceFilter: Double = 10.0
    static let CL_HorizontalAccuracy: Double = 20.0
    static let CL_TimeAccuracy: Double = 10.0
}

protocol LocationManagerDelegate {
    func locationUpdated() -> Void
}

class LocationManager: NSObject {
    
    var locations = [CLLocation]()
    var clLocationManager: CLLocationManager?
    var delegate: LocationManagerDelegate?
    
    func stopLocationUpdate() {
        clLocationManager?.stopUpdatingLocation()
        clLocationManager?.delegate = nil
        clLocationManager = nil
    }
    
    func startLocationUpdate() {
        clLocationManager = CLLocationManager()
        if clLocationManager != nil {
            clLocationManager!.delegate = self
            clLocationManager!.desiredAccuracy = kCLLocationAccuracyBest
            clLocationManager!.activityType = .Fitness
            
            // Movement threshold for new events
            clLocationManager!.distanceFilter = Constants.CL_DistanceFilter
            
            clLocationManager!.requestAlwaysAuthorization()
            clLocationManager!.startUpdatingLocation()
        }
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            if (locationIsValid(location )) {
                saveLocation(location )
                informDelegateNewLocationUpdated()
            }
        }
    }
    
    private func locationIsValid(location: CLLocation!) -> Bool {
        return locationIsAccurate(location) && locationIsRecentEnough(location)
    }
    
    private func locationIsAccurate(location: CLLocation!) -> Bool {
        return location.horizontalAccuracy < Constants.CL_HorizontalAccuracy
    }
    
    private func locationIsRecentEnough(location: CLLocation!) -> Bool {
        let howRecent = location.timestamp.timeIntervalSinceNow
        return abs(howRecent) < Constants.CL_TimeAccuracy
    }
    
    private func saveLocation(location: CLLocation!) {
        locations.append(location)
    }
    
    private func informDelegateNewLocationUpdated() {
        delegate?.locationUpdated()
    }
}
