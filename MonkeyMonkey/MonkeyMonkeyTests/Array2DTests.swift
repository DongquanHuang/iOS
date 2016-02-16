//
//  Array2DTests.swift
//  MonkeyMonkey
//
//  Created by Peter Huang on 2/16/16.
//  Copyright © 2016 Peter Huang. All rights reserved.
//

import XCTest

enum TestClassType: Int, CustomStringConvertible {
	case Type1 = 0, Type2, Type3
	
	var testClassTypeName: String {
		let classTypeNames = [
			"Type1",
			"Type2",
			"Type3"
		]
		
		return classTypeNames[rawValue]
	}
	
	var description: String {
		return testClassTypeName
	}
}

class TestClass {
	let testClassType: TestClassType
	
	init(type: TestClassType) {
		self.testClassType = type
	}
	
	var description: String {
		return "Type:\(testClassType)"
	}
}

class Array2DTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testCanSetAndGetElementInArray2D() {
		var array = Array2D<TestClass>(columns: 4, rows: 4)
		let element = TestClass(type: .Type1)
		
		array[1, 1] = element
		XCTAssertTrue(array[1, 1]?.description == "Type:Type1")
	}

}
