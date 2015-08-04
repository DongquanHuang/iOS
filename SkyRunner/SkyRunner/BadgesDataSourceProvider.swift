//
//  BadgesDataSourceProvider.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/24/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import CoreData

protocol BadgeDataProvider: UITableViewDataSource {
    var managedObjectContext: NSManagedObjectContext? {get set}
}

class BadgesDataSourceProvider: NSObject, BadgeDataProvider {
    var managedObjectContext: NSManagedObjectContext?
    var badgeEarnStatusMgr: BadgeEarnStatusDataProvider = BadgeEarnStatusMgr()
    
}

extension BadgesDataSourceProvider: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if badgeEarnStatusMgr.badgeEarnStatuses != nil {
            return badgeEarnStatusMgr.badgeEarnStatuses!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BadgeCell") as? BadgeCell
        let badgeEarnStatus = badgeEarnStatusMgr.badgeEarnStatuses?[indexPath.row]
        configureCell(cell, WithBadgeEarnStatus: badgeEarnStatus)
        return cell!
    }
    
    struct CellConstants {
        static let UnEarnedName = "??????"
    }
    
    private func configureCell(cell: BadgeCell?, WithBadgeEarnStatus badgeEarnStatus: BadgeEarnStatus?) {
        configureNameForCell(cell, WithBadgeEarnStatus: badgeEarnStatus)
        configureImageForCell(cell, WithBadgeEarnStatus: badgeEarnStatus)
    }
    
    private func configureNameForCell(cell: BadgeCell?, WithBadgeEarnStatus badgeEarnStatus: BadgeEarnStatus?) {
        if badgeEarnStatus?.badgeEarned() == true {
            cell?.badgeNameLabel.text = badgeEarnStatus?.badge?.name
        }
        else {
            cell?.badgeNameLabel.text =  CellConstants.UnEarnedName
        }
    }
    
    private func configureImageForCell(cell: BadgeCell?, WithBadgeEarnStatus badgeEarnStatus: BadgeEarnStatus?) {
        if let badge = badgeEarnStatus?.badge {
            cell?.badgeImageView.image = UIImage(named: badge.imageName!)
        }
    }
}
