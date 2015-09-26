//
//  SkyRunDatabase.swift
//  SkyRunner
//
//  Created by Peter Huang on 8/6/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import Foundation
import CoreData

protocol SkyRunDatabaseInterface {
    var managedObjectContext: NSManagedObjectContext? {get set}
    
    func allRuns() -> [Run]
    func allRunsForBadge(badge: Badge) -> [Run]
}

class SkyRunDatabase: NSObject, SkyRunDatabaseInterface {
    var managedObjectContext: NSManagedObjectContext?
    
    func allRuns() -> [Run] {
        var runs = [Run]()
        
        if let context = self.managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "Run")
            let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            // Swift bug here for core data unit test
            // Try to set debug point and run test case "testAllRunsWillReturnAllStoredData()"
            
            // Works
            //let anyObjects = context.executeFetchRequest(fetchRequest, error: nil)
            // Works
            //let managedObjects = anyObjects as? [NSManagedObject]
            // Get nil from below code
            //let runArray = managedObjects as? [Run]
            
            if let runList = (try? context.executeFetchRequest(fetchRequest)) as? [Run] {
                for run in runList {
                    runs.append(run)
                }
            }
        }
        
        return runs
    }
    
    func allRunsForBadge(badge: Badge) -> [Run] {
        var earnedRuns = [Run]()
        
        if let context = self.managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "Run")
            
            let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let predicate = NSPredicate(format: "distance >= %@", badge.distance!.description)
            fetchRequest.predicate = predicate
            
            // Note: If you run unit test "testRunsForBadgeWillReturnFilteredData()"
            // You will get a crash in next line
            // This is related to above predicate for fetch request
            // Dont know why yet, perhaps Swift bug
            
            if let runList = (try? context.executeFetchRequest(fetchRequest)) as? [Run] {
                for run in runList {
                    earnedRuns.append(run)
                }
            }
        }
        
        return earnedRuns
    }
}
