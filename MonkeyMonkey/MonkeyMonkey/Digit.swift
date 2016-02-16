//
//  Digit.swift
//  MonkeyMonkey
//
//  Created by Peter Huang on 2/16/16.
//  Copyright © 2016 Peter Huang. All rights reserved.
//

import SpriteKit

enum DigitType: Int, CustomStringConvertible {
	case Invalid = 0, Two, Four, Eight, Sixteen, ThirtyTwo, SixtyFour, OneHundredTwentyEight, TwoHundredFiftySix, FiveHundredTwelve, OneThousandTwentyFour, TwoThousandFourtyEight, FourThousandNinetySix
	
	var spriteName: String {
		let spriteNames = [
			"2",
			"4",
			"8",
			"16",
			"32",
			"64",
			"128",
			"256",
			"512",
			"1024",
			"2048",
			"4096"
		]
		
		return spriteNames[rawValue - 1]
	}
	
	var description: String {
		return spriteName
	}
	
	func nextType() -> DigitType {
		return DigitType(rawValue: self.rawValue + 1)!
	}
	
	static func random() -> DigitType {
		return DigitType(rawValue: Int(arc4random_uniform(2)) + 1)!
	}
}

class Digit {
	var column: Int
	var row: Int
	let digitType: DigitType
	var sprite: SKSpriteNode?
	
	init(column: Int, row: Int, digitType: DigitType) {
		self.column = column
		self.row = row
		self.digitType = digitType
	}
	
	var description: String {
		return "Type:\(digitType) Square:(\(column),\(row))"
	}
	
	func reachMaxValue() -> Bool {
		return self.digitType == .FourThousandNinetySix
	}
	
	func isNeighbourOf(digit: Digit!) -> Bool {
		return abs(self.column - digit.column) + abs(self.row - digit.row) == 1
	}
}

func ==(lhs: Digit, rhs: Digit) -> Bool {
	return lhs.digitType.rawValue == rhs.digitType.rawValue
}

func +(lhs: Digit, rhs: Digit) -> Digit? {
	if (lhs == rhs && !lhs.reachMaxValue() && lhs.isNeighbourOf(rhs)) {
		return Digit(column: lhs.column, row: lhs.row, digitType: lhs.digitType.nextType())
	}
	return nil
}
