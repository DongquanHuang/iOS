//
//  BadgeEarnStatus.swift
//  SkyRunner
//
//  Created by Peter Huang on 8/3/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import Foundation
import CoreData

class BadgeEarnStatus {
    var badge: Badge?
    var earnRun: Run?
    var silverRun: Run?
    var goldRun: Run?
    
    init(badge: Badge) {
        self.badge = badge
    }
    
    func badgeEarned() -> Bool {
        return earnRun != nil
    }
    
    func deserveSilver() -> Bool {
        return silverRun != nil
    }
    
    func deserveGold() -> Bool {
        return goldRun != nil
    }
    
}

protocol BadgeEarnStatusDataProvider {
    var managedObjectContext: NSManagedObjectContext? {get set}
    var badgeEarnStatuses: [BadgeEarnStatus]? {get}
}

class BadgeEarnStatusMgr: NSObject, BadgeEarnStatusDataProvider {
    var managedObjectContext: NSManagedObjectContext?
    lazy var badgeEarnStatuses: [BadgeEarnStatus]? = {
        [unowned self] in
        return self.getBadgeEarnStatuses()
    }()
    
    private var filePath = NSBundle.mainBundle().pathForResource("badges", ofType: "json")
    private var badgeDataMgr = BadgeDataManager()
    private lazy var badges: [Badge]? = {
        [unowned self] in
        return self.badgeDataMgr.getBadgesFromFile(self.filePath)
    }()
    
    private var badgeEarnStatusList: [BadgeEarnStatus]?
    private var runs = [Run]()
    
    private func getBadgeEarnStatuses() -> [BadgeEarnStatus]? {
        generateBadgeEarnStatuses()
        readRunsFromDatabase()
        fillRunInfoToBadgeEarnStatuses()
        
        return badgeEarnStatusList
    }
    
    private func generateBadgeEarnStatuses() {
        badgeEarnStatusList = [BadgeEarnStatus]()
        
        if let badgeList = badges {
            for badge in badgeList {
                var badgeEarnStatus = BadgeEarnStatus(badge: badge)
                badgeEarnStatusList?.append(badgeEarnStatus)
            }
        }
    }
    
    private func readRunsFromDatabase() {
        runs = [Run]()
        
        if let context = self.managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "Run")
            let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            if let runList = context.executeFetchRequest(fetchRequest, error: nil) as? [Run] {
                for run in runList {
                    runs.append(run)
                }
            }
        }
    }
    
    private func fillRunInfoToBadgeEarnStatus(badgeEarnStatus: BadgeEarnStatus) {
        let requiredDistance = badgeEarnStatus.badge!.distance
        for run in runs {
            if run.distance >= requiredDistance {
                badgeEarnStatus.earnRun = run
            }
        }
    }
    
    private func fillRunInfoToBadgeEarnStatuses() {
        if let earnStatusList = badgeEarnStatusList {
            for badgeEarnStatus in earnStatusList {
                fillRunInfoToBadgeEarnStatus(badgeEarnStatus)
            }
        }
    }

}
