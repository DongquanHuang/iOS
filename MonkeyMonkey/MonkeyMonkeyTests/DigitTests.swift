//
//  DigitTests.swift
//  MonkeyMonkey
//
//  Created by Peter Huang on 2/16/16.
//  Copyright © 2016 Peter Huang. All rights reserved.
//

import XCTest

class DigitTests: XCTestCase {
	
	var digit2: Digit?
	var digit2Type = DigitType.Two
	
	var digit4: Digit?
	var digit4Type = DigitType.Four

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		digit2 = Digit(column: 0, row: 1, digitType: digit2Type)
		digit4 = Digit(column: 2, row: 2, digitType: digit4Type)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testDigitHasRowAndColumnInfo() {
		XCTAssertTrue(digit2?.column == 0)
		XCTAssertTrue(digit2?.row == 1)
	}
	
	func testDigitTypeSetCorrectly() {
		XCTAssertTrue(digit2?.digitType == .Two)
	}
	
	func testDigitHasNilSpriteNodeByDefault() {
		XCTAssertTrue(digit2!.sprite == nil)
	}
	
	func testCanGetCorrectSpriteName() {
		XCTAssertTrue(digit2Type.spriteName == "2")
	}
	
	func testCanGetRandomDigitType2Or4() {
		let randomType = DigitType.random()
		XCTAssertTrue(randomType.rawValue >= DigitType.Two.rawValue && randomType.rawValue <= DigitType.Four.rawValue)
	}
	
	func testCanPrintDigit() {
		XCTAssertTrue(digit2!.description == "Type:2 Square:(0,1)")
	}
	
	func testCanCompareTwoDigits() {
		let otherDigit2 = Digit(column: 1, row: 2, digitType: .Two)
		XCTAssertTrue(digit2! == otherDigit2)
		
		XCTAssertFalse(digit2! == digit4!)
	}
	
	func testCanNotAddTwoDifferentDigits() {
		let addResult = digit2! + digit4!
		XCTAssertTrue(addResult == nil)
	}
	
	func testCanAddTwoSameDigits() {
		let otherDigit2 = Digit(column: 1, row: 1, digitType: .Two)
		let addResult = digit2! + otherDigit2
		XCTAssertTrue(addResult?.digitType == .Four)
	}
	
	func testAddFunctionHasLimitaionOf4096() {
		let digit4096_1 = Digit(column: 1, row: 0, digitType: .FourThousandNinetySix)
		let digit4096_2 = Digit(column: 1, row: 1, digitType: .FourThousandNinetySix)
		let addResult = digit4096_1 + digit4096_2
		XCTAssertTrue(addResult == nil)
	}
	
	func testAddedResultWillHaveTheSameColAndRowInfoAsTheFirstDigit() {
		let otherDigit2 = Digit(column: 1, row: 1, digitType: .Two)
		let addResult = digit2! + otherDigit2
		XCTAssertTrue(addResult?.column == digit2!.column && addResult?.row == digit2!.row)
	}
	
	func testCanOnlyAddBetweenNeighbours() {
		let otherDigit2 = Digit(column: 1, row: 2, digitType: .Two)
		let addResult = digit2! + otherDigit2
		XCTAssertTrue(addResult == nil)
	}

}
