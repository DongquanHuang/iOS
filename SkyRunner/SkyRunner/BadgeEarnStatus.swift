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
    var bestRun: Run?
    
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
    var managedObjectContext: NSManagedObjectContext? {
        didSet {
            databaseReader.managedObjectContext = managedObjectContext
        }
    }
    
    lazy var badgeEarnStatuses: [BadgeEarnStatus]? = {
        [unowned self] in
        return self.getBadgeEarnStatuses()
    }()
    
    var databaseReader: SkyRunDatabaseInterface = SkyRunDatabase() {
        didSet {
            databaseReader.managedObjectContext = managedObjectContext
        }
    }
    
    private var badges = Badges()
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
        
        if let badgeList = badges.badges {
            for badge in badgeList {
                let badgeEarnStatus = BadgeEarnStatus(badge: badge)
                badgeEarnStatusList?.append(badgeEarnStatus)
            }
        }
    }
    
    private func readRunsFromDatabase() {
        runs = [Run]()
        
        let allRuns = databaseReader.allRuns()
        for run in allRuns {
            runs.append(run)
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
        fillBestRunToBadgeEarnStatus(badgeEarnStatus)
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
    
    private func fillBestRunToBadgeEarnStatus(badgeEarnStatus: BadgeEarnStatus) {
        let earnedRuns = allRunsForBadge(badgeEarnStatus.badge)
        let bestRun = bestRunInRuns(earnedRuns)
        badgeEarnStatus.bestRun = bestRun
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
    
    private func allRunsForBadge(badge: Badge?) -> [Run] {
        var earnedRuns = [Run]()
        
        if badge == nil {
            return earnedRuns
        }
        
        let allEarnedRuns = databaseReader.allRunsForBadge(badge!)
        for run in allEarnedRuns {
            earnedRuns.append(run)
        }
        
        return earnedRuns
    }
    
    private func bestRunInRuns(runs: [Run]) -> Run? {
        var run: Run?
        var maxSpeed = 0.0
        
        for eachRun in runs {
            let runSpeed = eachRun.distance / eachRun.duration
            if runSpeed > maxSpeed {
                maxSpeed = runSpeed
                run = eachRun
            }
        }
        
        return run
    }

}
