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
    var managedObjectContext: NSManagedObjectContext?
    var dataSourceProvider: UITableViewDataSource! = BadgesDataSourceProvider()
}

extension BadgesTableViewController: UITableViewDataSource {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceProvider.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return dataSourceProvider.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
}
