//
//  Run.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/27/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import Foundation
import CoreData

// Make it public so when running unit test we can import module (SkyRunner) and use SkyRunner.Run
// Otherwise, the type will be SkyRunnerTests.Run, which will cause cast failure

public class Run: NSManagedObject {
    
    @NSManaged public var duration: Double
    @NSManaged public var distance: Double
    @NSManaged public var timestamp: NSDate
    @NSManaged public var locations: NSSet
    
    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName("Run", inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
    
}
