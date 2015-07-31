//
//  BadgeDataManger.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/23/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import Foundation

class BadgeDataManager {

    var jsonFileParser: JsonFileParser?
    private var badges: [Badge]?
    
    init() {
        jsonFileParser = JsonFileParser()
    }
    
    init(parser: JsonFileParser?) {
        jsonFileParser = parser
    }
    
    func getBadgesFromFile(filePath: String!) -> [Badge]? {
        clearBadges()
        fillBadgesFromJsonFile(filePath)
        
        return badges
    }
    
    private func clearBadges() {
        badges?.removeAll(keepCapacity: false)
        badges = nil
    }
    
    private func fillBadgesFromJsonFile(filePath: String!) {
        if let jsonBadges = jsonFileParser?.getJsonDictionaryArrayFromFile(filePath) {
            badges = [Badge]()
            
            for jsonBadge in jsonBadges {
                badges?.append(Badge(badgeJsonString: jsonBadge))
            }
        }
    }
}
