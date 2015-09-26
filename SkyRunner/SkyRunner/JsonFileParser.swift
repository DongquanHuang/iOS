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
        do {
            let jsonData = try NSData(contentsOfFile: filePath, options: NSDataReadingOptions())
            let dictionaryArray: AnyObject?
            do {
                dictionaryArray = try NSJSONSerialization.JSONObjectWithData(jsonData,
                    options: NSJSONReadingOptions())
            } catch {
                return nil
            }
            if let dictionaryArray = dictionaryArray as? [Dictionary<String, String>] {
                return dictionaryArray
            }
        } catch {
            return nil
        }
        
        return nil
    }
}