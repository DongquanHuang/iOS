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

class Game {
	
	var digits = Array2D<Digit>(columns: GameConstants.TotalColumns, rows: GameConstants.TotalRows)
	var gameOver = false
	
	init() {
		produceTwoRandomDigits()
	}
	
	// MARK: - Public interfaces
	func swipeDown() {
		moveAllDigitsDown()
		addUpNeighbourDigitsForSwipeDown()
		
		produceRandomDigit()
		
		gameOver = checkIfGameOver()
	}
	
	func isGameOver() -> Bool {
		return gameOver
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
	private func moveAllDigitsDown() {
		for column in 0 ..< GameConstants.TotalColumns {
			for row in 0 ..< GameConstants.TotalRows {
				if let digit = digits[column, row] {
					moveDown(digit)
				}
			}
		}
	}
	
	private func moveDown(digit: Digit) {
		removeDigit(digit)
		
		let column = digit.column
		let row = findBottomEmptyRowNumberForColumn(column)
		if row < digit.row {
			digit.row = row
		}
		
		addDigit(digit)
	}
	
	private func findBottomEmptyRowNumberForColumn(column: Int) -> Int {
		var targetRow = 0
		
		for row in 0 ..< GameConstants.TotalRows {
			if hasDigitAtColumn(column, andRow: row) {
				targetRow++
			}
		}
		
		return targetRow
	}
	
	// MARK: - Add up neighbour digits
	private func addUpNeighbourDigitsForSwipeDown() {
		for column in 0 ..< GameConstants.TotalColumns {
			for row in 0 ..< GameConstants.TotalRows {
				addUpForSwipeDownForDigitAtColumn(column, row: row)
			}
		}
		
		moveAllDigitsDown()
	}
	
	private func addUpForSwipeDownForDigitAtColumn(column: Int, row: Int) {
		if row >= GameConstants.TotalRows - 1 {
			return
		}
		
		if let firstDigit = digits[column, row] {
			if let secondDigit = digits[column, row + 1] {
				if let addedDigit = firstDigit + secondDigit {
					removeDigit(firstDigit)
					removeDigit(secondDigit)
					addDigit(addedDigit)
				}
			}
		}
	}
	
	// MARK: - Game operations, add and remove digit
	private func removeDigit(digit: Digit) {
		digits[digit.column, digit.row] = nil
	}
	
	private func addDigit(digit: Digit) {
		digits[digit.column, digit.row] = digit
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
	
}
