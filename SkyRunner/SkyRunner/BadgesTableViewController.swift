//
//  BadgesTableViewController.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/24/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import CoreData

class BadgesTableViewController: UITableViewController {
    
    struct StoryBoardConstants {
        static let ShowBadgeDetail = "Show Badge Detail"
    }
    
    var managedObjectContext: NSManagedObjectContext? {
        didSet {
            dataSourceProvider.managedObjectContext = managedObjectContext
        }
    }
    var dataSourceProvider: BadgeDataProvider = BadgesDataSourceProvider() {
        didSet {
            dataSourceProvider.managedObjectContext = managedObjectContext
        }
    }
    
    var badgeEarnStatus: BadgeEarnStatus?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryBoardConstants.ShowBadgeDetail {
            let badgeDetailVC = segue.destinationViewController as? BadgeDetailViewController
            badgeDetailVC?.badgeEarnStatus = badgeEarnStatus
        }
    }
}

extension BadgesTableViewController: UITableViewDataSource {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceProvider.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return dataSourceProvider.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
}

extension BadgesTableViewController: UITableViewDelegate {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        badgeEarnStatus = dataSourceProvider.badgeEarnStatusForIndex(indexPath.row)
        performSegueWithIdentifier("Show Badge Detail", sender: nil) 
    }
}
