//
//  GameLogicTests.swift
//  MonkeyMonkey
//
//  Created by Peter Huang on 2/16/16.
//  Copyright © 2016 Peter Huang. All rights reserved.
//

import XCTest

class GameLogicTests: XCTestCase {
	
	var game = Game()
	
	var digit2: Digit?
	var digit4: Digit?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		digit2 = Digit(column: 1, row: 2, digitType: .Two)
		digit4 = Digit(column: 2, row: 3, digitType: .Four)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testGameShouldHave4x4DigitsBoard() {
		XCTAssertTrue(game.digits.columns == 4 && game.digits.rows == 4)
	}
	
	func testShouldHaveTwoInitialDigitsWhenGameBegins() {
		XCTAssertTrue(currentNumberOfDigits() == 2)
	}
	
	// MARK: - Game operation tests
	func testSwipeDownWillMoveAllDigitsToBottomRow() {
		clearAllDigits()
		addDigit(digit2!)
		addDigit(digit4!)
		
		game.swipeDown()
		
		XCTAssertTrue(digit2!.row == 0 && digit4!.row == 0)
	}
	
	func testSwipeDownWillAddRandomDigit() {
		clearAllDigits()
		addDigit(digit2!)
		addDigit(digit4!)
		
		game.swipeDown()
		
		XCTAssertTrue(currentNumberOfDigits() == 3)
	}
	
	func testSwipeDownWillAddUpNeighbourSameDigitsInSameColumn() {
		clearAllDigits()
		let firstDigit = Digit(column: 0, row: 0, digitType: .Two)
		let secondDigit = Digit(column: 0, row: 1, digitType: .Two)
		let thirdDigit = Digit(column: 0, row: 2, digitType: .Four)
		let fourthDigit = Digit(column: 0, row: 3, digitType: .Four)
		addDigit(firstDigit)
		addDigit(secondDigit)
		addDigit(thirdDigit)
		addDigit(fourthDigit)
		
		game.swipeDown()
		
		XCTAssertTrue(game.digits[0, 0]?.digitType.description == "4")
		XCTAssertTrue(game.digits[0, 1]?.digitType.description == "8")
		XCTAssertTrue(currentNumberOfDigits() == 3)
	}
	
	// MARK: - Private helper methods
	private func currentNumberOfDigits() -> Int {
		var digitsNumber = 0
		
		for column in 0 ..< 4 {
			for row in 0 ..< 4 {
				if let _ = game.digits[column, row] {
					digitsNumber++
				}
			}
		}
		
		return digitsNumber
	}
	
	private func clearAllDigits() {
		for column in 0 ..< game.digits.columns {
			for row in 0 ..< game.digits.rows {
				game.digits[column, row] = nil
			}
		}
	}
	
	private func addDigit(digit: Digit) {
		game.digits[digit.column, digit.row] = digit
	}

}
