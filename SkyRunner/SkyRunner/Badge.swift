//
//  Badge.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/22/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import Foundation

struct JsonConstants {
    static let BadgeName = "name"
    static let BadgeImageName = "imageName"
    static let BadgeInformation = "information"
    static let BadgeDistance = "distance"
}

class Badge {
    let name: String?
    let imageName: String?
    let information: String?
    let distance: Double?
    
    init(badgeJsonString: [String : String]) {
        name = badgeJsonString[JsonConstants.BadgeName]
        imageName = badgeJsonString[JsonConstants.BadgeImageName]
        information = badgeJsonString[JsonConstants.BadgeInformation]
        if let distanceString = badgeJsonString[JsonConstants.BadgeDistance] as String! {
            distance = NSString(string: distanceString).doubleValue
        }
        else {
            distance = 0.0
        }
    }
}