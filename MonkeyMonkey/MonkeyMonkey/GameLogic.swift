//
//  GameLogic.swift
//  MonkeyMonkey
//
//  Created by Peter Huang on 2/16/16.
//  Copyright © 2016 Peter Huang. All rights reserved.
//

import Foundation

struct GameConstants {
	static let TotalColumns = 4
	static let TotalRows = 4
}

enum SwipeType: Int {
	case Unknown = 0, SwipeDown, SwipeUp, SwipeLeft, SwipeRight
}

class Game {
	
	var digits = Array2D<Digit>(columns: GameConstants.TotalColumns, rows: GameConstants.TotalRows)
	var gameOver = false
	var swipeType: SwipeType = .Unknown
	
	init() {
		startNewGame()
	}
	
	// MARK: - Public interfaces
	func startNewGame() {
		gameOver = false
		clearAllDigits()
		produceTwoRandomDigits()
	}
	
	func swipeDown() {
		swipeType = .SwipeDown
		commonSwipeActions()
	}
	
	func swipeUp() {
		swipeType = .SwipeUp
		commonSwipeActions()
	}
	
	func swipeLeft() {
		swipeType = .SwipeLeft
		commonSwipeActions()
	}
	
	func swipeRight() {
		swipeType = .SwipeRight
		commonSwipeActions()
	}
	
	func isGameOver() -> Bool {
		return gameOver
	}
	
	// MARK: - Common swipe process
	private func commonSwipeActions() {
		moveAllDigits()
		mergeNeighbourDigits()
		moveAllDigits()	//Should move all digits again, otherwise there'll be holes after merge digits
		produceRandomDigit()
		
		gameOver = checkIfGameOver()
	}
	
	// MARK: - Produce new digit
	private func produceTwoRandomDigits() {
		for _ in 0 ..< 2 {
			produceRandomDigit()
		}
	}
	
	private func produceRandomDigit() {
		if (allHolesFilled()) {
			return
		}
		
		let (randomColumn, randomRow) = findRandomPosition()
		let digit = Digit(column: randomColumn, row: randomRow, digitType: DigitType.random())
		digits[digit.column, digit.row] = digit
	}
	
	private func findRandomPosition() -> (column: Int, row: Int) {
		var column = randomColumn()
		var row = randomRow()
		
		while hasDigitAtColumn(column, andRow: row) {
			column = randomColumn()
			row = randomRow()
		}
		
		return (column, row)
	}
	
	private func randomColumn() -> Int {
		return Int(arc4random_uniform(UInt32(GameConstants.TotalColumns)))
	}
	
	private func randomRow() -> Int {
		return Int(arc4random_uniform(UInt32(GameConstants.TotalColumns)))
	}
	
	// MARK: - Game operations, move digits
	private func moveAllDigits() {
		if (swipeType == .SwipeDown) {
			moveAllDigitsDown()
		}
		else if (swipeType == .SwipeUp) {
			moveAllDigitsUp()
		}
		else if (swipeType == .SwipeLeft) {
			moveAllDigitsLeft()
		}
		else if (swipeType == .SwipeRight) {
			moveAllDigitsRight()
		}
	}
	
	private func moveAllDigitsDown() {
		for column in 0 ..< GameConstants.TotalColumns {
			for row in 0 ..< GameConstants.TotalRows {
				if let digit = digits[column, row] {
					moveDigit(digit)
				}
			}
		}
	}
	
	private func moveAllDigitsUp() {
		for column in 0 ..< GameConstants.TotalColumns {
			for var row = GameConstants.TotalRows - 1; row >= 0; row-- {
				if let digit = digits[column, row] {
					moveDigit(digit)
				}
			}
		}
	}
	
	private func moveAllDigitsLeft() {
		for row in 0 ..< GameConstants.TotalRows {
			for column in 0 ..< GameConstants.TotalColumns {
				if let digit = digits[column, row] {
					moveDigit(digit)
				}
			}
		}
	}
	
	private func moveAllDigitsRight() {
		for row in 0 ..< GameConstants.TotalRows {
			for var column = GameConstants.TotalColumns - 1; column >= 0; column-- {
				if let digit = digits[column, row] {
					moveDigit(digit)
				}
			}
		}
	}
	
	private func moveDigit(digit: Digit) {
		let (newColumn, newRow) = newPositionAfterSwipeForDigit(digit)
		removeDigit(digit)
		digit.column = newColumn
		digit.row = newRow
		addDigit(digit)
	}
	
	private func newPositionAfterSwipeForDigit(digit: Digit) -> (columm: Int, row: Int) {
		var targetColumn = -1
		var targetRow = -1
		
		let currentColumn = digit.column
		let currentRow = digit.row
		
		let otherDigitsNumber = findNeigbourDigitsNumberBasedOnSwipeType(digit)
		
		if (swipeType == .SwipeDown) {
			targetColumn = currentColumn
			targetRow = 0 + otherDigitsNumber
		}
		else if (swipeType == .SwipeUp) {
			targetColumn = currentColumn
			targetRow = GameConstants.TotalRows - 1 - otherDigitsNumber
		}
		else if (swipeType == .SwipeLeft) {
			targetColumn = 0 + otherDigitsNumber
			targetRow = currentRow
		}
		else if (swipeType == .SwipeRight) {
			targetColumn = GameConstants.TotalColumns - 1 - otherDigitsNumber
			targetRow = currentRow
		}
		
		return (targetColumn, targetRow)
	}
	
	private func findNeigbourDigitsNumberBasedOnSwipeType(digit: Digit) -> Int {
		if (swipeType == .SwipeDown) {
			return findBelowNeighbourDigitsNumber(digit)
		}
		else if (swipeType == .SwipeUp) {
			return findAboveNeighbourDigitsNumber(digit)
		}
		else if (swipeType == .SwipeLeft) {
			return findLeftNeighbourDigitsNumber(digit)
		}
		else if (swipeType == .SwipeRight) {
			return findRightNeighbourDigitsNumber(digit)
		}
		
		return 0
	}
	
	private func findBelowNeighbourDigitsNumber(digit: Digit) -> Int {
		var numbers = 0
		
		for row in 0 ..< digit.row {
			if let _ = digits[digit.column, row] {
				numbers++
			}
		}

		return numbers
	}
	
	private func findAboveNeighbourDigitsNumber(digit: Digit) -> Int {
		var numbers = 0
		
		for var row = digit.row + 1; row < GameConstants.TotalRows; row++ {
			if let _ = digits[digit.column, row] {
				numbers++
			}
		}
		
		return numbers
	}
	
	private func findLeftNeighbourDigitsNumber(digit: Digit) -> Int {
		var numbers = 0
		
		for column in 0 ..< digit.column {
			if let _ = digits[column, digit.row] {
				numbers++
			}
		}
		
		return numbers
	}
	
	private func findRightNeighbourDigitsNumber(digit: Digit) -> Int {
		var numbers = 0
		
		for var column = digit.column + 1; column < GameConstants.TotalColumns; column++ {
			if let _ = digits[column, digit.row] {
				numbers++
			}
		}
		
		return numbers
	}
	
	// MARK: - Add up neighbour digits
	private func mergeNeighbourDigits() {
		if (swipeType == .SwipeDown) {
			mergeNeighbourDigitsForSwipeDown()
		}
		else if (swipeType == .SwipeUp) {
			mergeNeighbourDigitsForSwipeUp()
		}
		else if (swipeType == .SwipeLeft) {
			mergeNeighbourDigitsForSwipeLeft()
		}
		else if (swipeType == .SwipeRight) {
			mergeNeighbourDigitsForSwipeRight()
		}
	}
	
	private func mergeNeighbourDigitsForSwipeDown() {
		for column in 0 ..< GameConstants.TotalColumns {
			for row in 0 ..< GameConstants.TotalRows {
				if let digit = digits[column, row] {
					mergeForDigit(digit)
				}
			}
		}
	}
	
	private func mergeNeighbourDigitsForSwipeUp() {
		for var column = GameConstants.TotalColumns - 1; column >= 0; column-- {
			for var row = GameConstants.TotalRows - 1; row >= 0; row-- {
				if let digit = digits[column, row] {
					mergeForDigit(digit)
				}
			}
		}
	}
	
	private func mergeNeighbourDigitsForSwipeLeft() {
		for row in 0 ..< GameConstants.TotalRows {
			for column in 0 ..< GameConstants.TotalColumns {
				if let digit = digits[column, row] {
					mergeForDigit(digit)
				}
			}
		}
	}
	
	private func mergeNeighbourDigitsForSwipeRight() {
		for row in 0 ..< GameConstants.TotalRows {
			for var column = GameConstants.TotalColumns - 1; column >= 0; column-- {
				if let digit = digits[column, row] {
					mergeForDigit(digit)
				}
			}
		}
	}
	
	private func mergeForDigit(digit: Digit) {
		if let neighbour = neighbourToMerge(digit) {
			if let mergedDigit = digit + neighbour {
				removeDigit(digit)
				removeDigit(neighbour)
				addDigit(mergedDigit)
			}
		}
	}
	
	private func neighbourToMerge(digit: Digit) -> Digit? {
		if (swipeType == .SwipeDown) {
			return findUpNeighbour(digit)
		}
		else if (swipeType == .SwipeUp) {
			return findBelowNeighbour(digit)
		}
		else if (swipeType == .SwipeLeft) {
			return findRightNeighbour(digit)
		}
		else if (swipeType == .SwipeRight) {
			return findLeftNeighbour(digit)
		}
		
		return nil
	}
	
	// MARK: - Game over checking
	private func checkIfGameOver() -> Bool {
		if (!allHolesFilled()) {
			return false
		}
		
		if (mergeAvailable()) {
			return false
		}
		
		return true
	}
	
	private func mergeAvailable() -> Bool {
		for column in 0 ..< GameConstants.TotalColumns {
			for row in 0 ..< GameConstants.TotalRows {
				if let digit = digits[column, row] {
					if (possilbeMergeExistsForDigit(digit)) {
						return true
					}
				}
			}
		}
		
		return false
	}
	
	private func possilbeMergeExistsForDigit(digit: Digit) -> Bool {
		var possilbeMergeExists = false
		
		if let left = findLeftNeighbour(digit) {
			possilbeMergeExists = digit == left
		}
		if let right = findRightNeighbour(digit) {
			possilbeMergeExists = digit == right
		}
		if let up = findUpNeighbour(digit) {
			possilbeMergeExists = digit == up
		}
		if let below = findBelowNeighbour(digit) {
			possilbeMergeExists = digit == below
		}
		
		return possilbeMergeExists
	}
	
	// MARK: - Game common operations, add and remove digit
	private func removeDigit(digit: Digit) {
		digits[digit.column, digit.row] = nil
	}
	
	private func addDigit(digit: Digit) {
		digits[digit.column, digit.row] = digit
	}
	
	private func clearAllDigits() {
		for column in 0 ..< digits.columns {
			for row in 0 ..< digits.rows {
				digits[column, row] = nil
			}
		}
	}
	
	// MARK: - Common helper methods
	private func hasDigitAtColumn(column: Int, andRow row: Int) -> Bool {
		return digits[column, row] != nil
	}
	
	private func currentNumberOfDigits() -> Int {
		var digitsNumber = 0
		
		for column in 0 ..< GameConstants.TotalColumns {
			for row in 0 ..< GameConstants.TotalRows {
				if hasDigitAtColumn(column, andRow: row) {
					digitsNumber++
				}
			}
		}
		
		return digitsNumber
	}
	
	private func allHolesFilled() -> Bool {
		return currentNumberOfDigits() == GameConstants.TotalColumns * GameConstants.TotalRows
	}
	
	private func findLeftNeighbour(digit: Digit) -> Digit? {
		var column = digit.column - 1
		while (column >= 0) {
			if let neighbour = digits[column, digit.row] {
				return neighbour
			}
			column--
		}
		
		return nil
	}
	
	private func findRightNeighbour(digit: Digit) -> Digit? {
		var column = digit.column + 1
		while (column < GameConstants.TotalColumns) {
			if let neighbour = digits[column, digit.row] {
				return neighbour
			}
			column++
		}
		
		return nil
	}
	
	private func findUpNeighbour(digit: Digit) -> Digit? {
		var row = digit.row + 1
		while (row < GameConstants.TotalRows) {
			if let neighbour = digits[digit.column, row] {
				return neighbour
			}
			row++
		}
		
		return nil
	}
	
	private func findBelowNeighbour(digit: Digit) -> Digit? {
		var row = digit.row - 1
		while (row >= 0) {
			if let neighbour = digits[digit.column, row] {
				return neighbour
			}
			row--
		}
		
		return nil
	}
	
}
