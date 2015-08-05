//
//  Badges.swift
//  SkyRunner
//
//  Created by Peter Huang on 8/5/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import Foundation

class Badges {
    var filePath = NSBundle.mainBundle().pathForResource("badges", ofType: "json")
    lazy var badges: [Badge]? = {
        [unowned self] in
        return self.badgeDataMgr.getBadgesFromFile(self.filePath)
    }()
    
    private var badgeDataMgr = BadgeDataManager()
}