//
//  BadgesDataSourceProvider.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/24/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit

class BadgesDataSourceProvider: NSObject, UITableViewDataSource {
    var filePath = NSBundle.mainBundle().pathForResource("badges", ofType: "json")
    var badgeDataMgr = BadgeDataManager()
    lazy var badges : [Badge]? = {
        return self.badgeDataMgr.getBadgesFromFile(self.filePath)
    }()
    
}

extension BadgesDataSourceProvider: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if badges != nil {
            return badges!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BadgeCell") as? BadgeCell
        if let badge = badges?[indexPath.row] {
            cell?.badgeNameLabel.text = badge.name
            cell?.badgeImageView.image = UIImage(named: badge.imageName!)
        }
        
        return cell!
    }
}
