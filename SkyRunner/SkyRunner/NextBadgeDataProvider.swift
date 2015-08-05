//
//  NextBadgeDataProvider.swift
//  SkyRunner
//
//  Created by Peter Huang on 8/5/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import Foundation

protocol NextBadgeDataProvider {
    func nextBadge(currentDistance: Double) -> Badge?
}

class NextBadgeProvider: NSObject, NextBadgeDataProvider {
    private var badges = Badges()
    
    func nextBadge(currentDistance: Double) -> Badge? {
        if let badgeList = badges.badges {
            for badge in badgeList {
                if badge.distance > currentDistance {
                    return badge
                }
            }
        }
        
        return badges.badges?.last
    }
}