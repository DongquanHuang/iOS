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
	
	// MARK: - Baisc game logics
	func testGameShouldHave4x4DigitsBoard() {
		XCTAssertTrue(game.digits.columns == 4 && game.digits.rows == 4)
	}
	
	func testShouldHaveTwoInitialDigitsWhenGameBegins() {
		XCTAssertTrue(currentNumberOfDigits() == 2)
	}
	
	func testStartNewGameWillResetGameOverFlag() {
		game.startNewGame()
		XCTAssertTrue(game.isGameOver() == false)
	}
	
	func testStartNewGameWillProduceTwoDigits() {
		game.startNewGame()
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
	
	func testSwipeUpWillMoveAllDigitsToTopRow() {
		clearAllDigits()
		addDigit(digit2!)
		addDigit(digit4!)
		
		game.swipeUp()
		
		XCTAssertTrue(digit2!.row == 3 && digit4!.row == 3)
	}
	
	func testSwipLeftWillMoveAllDigitsToTheLeft() {
		clearAllDigits()
		addDigit(digit2!)
		addDigit(digit4!)
		
		game.swipeLeft()
		
		XCTAssertTrue(digit2!.column == 0 && digit4!.column == 0)
	}
	
	func testSwipeDownWillAddRandomDigit() {
		clearAllDigits()
		addDigit(digit2!)
		addDigit(digit4!)
		
		game.swipeDown()
		
		XCTAssertTrue(currentNumberOfDigits() == 3)
	}
	
	func testSwipeUpWillAddRandomDigit() {
		clearAllDigits()
		addDigit(digit2!)
		addDigit(digit4!)
		
		game.swipeUp()
		
		XCTAssertTrue(currentNumberOfDigits() == 3)
	}
	
	func testSwipeLeftWillAddRandomDigit() {
		clearAllDigits()
		addDigit(digit2!)
		addDigit(digit4!)
		
		game.swipeLeft()
		
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
	
	func testSwipeUpWillAddUpNeighbourSameDigitsInSameColumn() {
		clearAllDigits()
		let firstDigit = Digit(column: 0, row: 0, digitType: .Two)
		let secondDigit = Digit(column: 0, row: 1, digitType: .Two)
		let thirdDigit = Digit(column: 0, row: 2, digitType: .Four)
		let fourthDigit = Digit(column: 0, row: 3, digitType: .Four)
		addDigit(firstDigit)
		addDigit(secondDigit)
		addDigit(thirdDigit)
		addDigit(fourthDigit)
		
		game.swipeUp()
		
		XCTAssertTrue(game.digits[0, 3]?.digitType.description == "8")
		XCTAssertTrue(game.digits[0, 2]?.digitType.description == "4")
		XCTAssertTrue(currentNumberOfDigits() == 3)
	}
	
	func testSwipeLeftWillAddUpNeighbourSameDigitsInSameColumn() {
		clearAllDigits()
		let firstDigit = Digit(column: 0, row: 0, digitType: .Two)
		let secondDigit = Digit(column: 1, row: 0, digitType: .Two)
		let thirdDigit = Digit(column: 2, row: 1, digitType: .Four)
		let fourthDigit = Digit(column: 3, row: 1, digitType: .Four)
		addDigit(firstDigit)
		addDigit(secondDigit)
		addDigit(thirdDigit)
		addDigit(fourthDigit)
		
		game.swipeLeft()
		
		XCTAssertTrue(game.digits[0, 0]?.digitType.description == "4")
		XCTAssertTrue(game.digits[0, 1]?.digitType.description == "8")
		XCTAssertTrue(currentNumberOfDigits() == 3)
	}
	
	func testSwipeDownForGameOver() {
		clearAllDigits()
		generateGameOverDigits()
		
		game.swipeDown()
		
		XCTAssertTrue(game.isGameOver() == true)
	}
	
	func testSwipeUpForGameOver() {
		clearAllDigits()
		generateGameOverDigits()
		
		game.swipeUp()
		
		XCTAssertTrue(game.isGameOver() == true)
	}
	
	func testSwipeLeftForGameOver() {
		clearAllDigits()
		generateGameOverDigits()
		
		game.swipeLeft()
		
		XCTAssertTrue(game.isGameOver() == true)
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
	
	private func generateGameOverDigits() {
		let digit1 = Digit(column: 0, row: 0, digitType: .Two)
		let digit2 = Digit(column: 0, row: 1, digitType: .Four)
		let digit3 = Digit(column: 0, row: 2, digitType: .Eight)
		let digit4 = Digit(column: 0, row: 3, digitType: .Sixteen)
		
		let digit5 = Digit(column: 1, row: 3, digitType: .Two)
		let digit6 = Digit(column: 1, row: 2, digitType: .Four)
		let digit7 = Digit(column: 1, row: 1, digitType: .Eight)
		let digit8 = Digit(column: 1, row: 0, digitType: .Sixteen)
		
		let digit9 = Digit(column: 2, row: 0, digitType: .Two)
		let digit10 = Digit(column: 2, row: 1, digitType: .Four)
		let digit11 = Digit(column: 2, row: 2, digitType: .Eight)
		let digit12 = Digit(column: 2, row: 3, digitType: .Sixteen)
		
		let digit13 = Digit(column: 3, row: 3, digitType: .Two)
		let digit14 = Digit(column: 3, row: 2, digitType: .Four)
		let digit15 = Digit(column: 3, row: 1, digitType: .Eight)
		let digit16 = Digit(column: 3, row: 0, digitType: .Sixteen)
		
		addDigit(digit1)
		addDigit(digit2)
		addDigit(digit3)
		addDigit(digit4)
		
		addDigit(digit5)
		addDigit(digit6)
		addDigit(digit7)
		addDigit(digit8)
		
		addDigit(digit9)
		addDigit(digit10)
		addDigit(digit11)
		addDigit(digit12)
		
		addDigit(digit13)
		addDigit(digit14)
		addDigit(digit15)
		addDigit(digit16)
	}

}
