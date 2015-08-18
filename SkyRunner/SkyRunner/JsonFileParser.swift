//
//  JsonFileParser.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/23/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import Foundation

class JsonFileParser {
    
    func getJsonDictionaryArrayFromFile(filePath: String!) -> [Dictionary<String, String>]? {
        var error: NSError?
        if let jsonData = NSData(contentsOfFile: filePath, options: NSDataReadingOptions(), error: &error) {
            var error: NSError?
            if let jsonDictionaryArray = NSJSONSerialization.JSONObjectWithData(jsonData,
                options: NSJSONReadingOptions.AllowFragments, error: &error) as? [Dictionary<String, String>] {
                return jsonDictionaryArray
            }
        }
        
        return nil
    }
}