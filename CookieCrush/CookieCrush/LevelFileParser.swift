//
//  LevelFileParser.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/11/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import Foundation

class LevelFileParser {
    static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {
            do {
                let data = try NSData(contentsOfFile: path, options: NSDataReadingOptions())
                let dictionary: AnyObject?
                do {
                    dictionary = try NSJSONSerialization.JSONObjectWithData(data,
                                        options: NSJSONReadingOptions())
                } catch {
                    dictionary = nil
                }
                if let dictionary = dictionary as? Dictionary<String, AnyObject> {
                    return dictionary
                }
            } catch {
                
            }
        }
        
        return nil
    }
}