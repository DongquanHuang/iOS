//
//  Run.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/27/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import Foundation
import CoreData

class Run: NSManagedObject {
    
    @NSManaged var duration: Double
    @NSManaged var distance: Double
    @NSManaged var timestamp: NSDate
    @NSManaged var locations: NSOrderedSet
    
}
