//
//  SkyRun.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/28/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import Foundation
import CoreLocation

class SkyRun: NSObject {
    var distance: Double = 0.0
    var duration: Double = 0.0
    var locations = [CLLocation]()
    var timestamp: NSDate?
    
    func appendLocation(location: CLLocation!) {
        locations.append(location)
    }
}