//
//  Location.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/27/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import Foundation
import CoreData

// Make it public so when running unit test we can import module (SkyRunner) and use SkyRunner.Location
// Otherwise, the type will be SkyRunnerTests.Location, which will cause cast failure

public class Location: NSManagedObject {
    
    @NSManaged public var timestamp: NSDate
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var run: NSManagedObject
    
    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName("Location", inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
    
}
