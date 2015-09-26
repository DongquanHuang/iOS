//
//  JsonFileParserTests.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/23/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import XCTest

class JsonFileParserTests: XCTestCase {
    
    var jsonFileParser: JsonFileParser?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        jsonFileParser = JsonFileParser()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParserCanReturnValidJsonDictionaryArrayForValidJsonFile() {
        let filePath = NSBundle.mainBundle().pathForResource("badges", ofType: "json")
        let jsonDictionaryArray = jsonFileParser?.getJsonDictionaryArrayFromFile(filePath)
        XCTAssertTrue(jsonDictionaryArray != nil)
    }
    
    func testParserWillReturnNilForInvalidFile() {
        let jsonDictionaryArray = jsonFileParser?.getJsonDictionaryArrayFromFile("Invalid File")
        XCTAssertTrue(jsonDictionaryArray == nil)
    }

}
