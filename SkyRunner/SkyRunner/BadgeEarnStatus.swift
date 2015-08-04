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

protocol NextBadgeDataProvider {
    func nextBadge(currentDistance: Double) -> Badge?
}

class BadgeEarnStatusMgr: NSObject, BadgeEarnStatusDataProvider, NextBadgeDataProvider {
    var managedObjectContext: NSManagedObjectContext?
    lazy var badgeEarnStatuses: [BadgeEarnStatus]? = {
        [unowned self] in
        return self.getBadgeEarnStatuses()
    }()
    
    func nextBadge(currentDistance: Double) -> Badge? {
        if let badgeList = badges {
            for badge in badgeList {
                if badge.distance > currentDistance {
                    return badge
                }
            }
        }
        
        return badges?.last
    }
    
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
            let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            if let runList = context.executeFetchRequest(fetchRequest, error: nil) as? [Run] {
                for run in runList {
                    runs.append(run)
                }
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
    
    private func fillRunInfoToBadgeEarnStatus(badgeEarnStatus: BadgeEarnStatus) {
        fillEarnRunToBadgeEarnStatus(badgeEarnStatus)
        fillSilverRunToBadgeEarnStatus(badgeEarnStatus)
        fillGoldRunToBadgeEarnStatus(badgeEarnStatus)
    }
    
    private func fillEarnRunToBadgeEarnStatus(badgeEarnStatus: BadgeEarnStatus) {
        let requiredDistance = badgeEarnStatus.badge!.distance
        for run in runs {
            if run.distance >= requiredDistance {
                if badgeEarnStatus.earnRun == nil {
                    badgeEarnStatus.earnRun = run
                    return
                }
            }
        }
    }
    
    struct AchievementConstants {
        static let SilverSpeedFactor = 1.05
        static let GoldSpeedFactor = 1.1
    }
    
    private func findRunForMiniumDistance(minDistance: Double, AndMiniumSpeed minSpeed: Double) -> Run? {
        for run in runs {
            if run.distance >= minDistance {
                let runSpeed = run.distance / run.duration
                if runSpeed >= minSpeed {
                    return run
                }
            }
        }
        
        return nil
    }
    
    private func fillSilverRunToBadgeEarnStatus(badgeEarnStatus: BadgeEarnStatus) {
        if badgeEarnStatus.badgeEarned() == false {
            return
        }
        
        let earnSpeed = badgeEarnStatus.earnRun!.distance / badgeEarnStatus.earnRun!.duration
        let targetSpeed = earnSpeed * AchievementConstants.SilverSpeedFactor
        
        if let run = findRunForMiniumDistance(badgeEarnStatus.earnRun!.distance, AndMiniumSpeed: targetSpeed) {
            badgeEarnStatus.silverRun = run
        }
    }
    
    private func fillGoldRunToBadgeEarnStatus(badgeEarnStatus: BadgeEarnStatus) {
        if badgeEarnStatus.badgeEarned() == false {
            return
        }
        
        let earnSpeed = badgeEarnStatus.earnRun!.distance / badgeEarnStatus.earnRun!.duration
        let targetSpeed = earnSpeed * AchievementConstants.GoldSpeedFactor
        
        if let run = findRunForMiniumDistance(badgeEarnStatus.earnRun!.distance, AndMiniumSpeed: targetSpeed) {
            badgeEarnStatus.goldRun = run
        }
    }

}
