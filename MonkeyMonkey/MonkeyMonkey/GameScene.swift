//
//  GameScene.swift
//  MonkeyMonkey
//
//  Created by Peter Huang on 2/24/16.
//  Copyright © 2016 Peter Huang. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
	
	//MARK: - Constants
	struct AdaptConstants {
		// 320.0: screen width for iPhone devices before iPhone6
		static let NormalPhoneWidth: CGFloat = 320.0
	}
	
	// MARK: - Variables
	lazy var scaleFactor: CGFloat! = {
		return self.size.width / AdaptConstants.NormalPhoneWidth
	}()
	
	//MARK: - Init
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(size: CGSize) {
		super.init(size: size)
		
		setAnchorPointToMiddle()
		addBackgroundNode()
	}
	
	override func addChild(node: SKNode) {
		node.setScale(scaleFactor)
		super.addChild(node)
	}
	
	private func setAnchorPointToMiddle() {
		anchorPoint = CGPoint(x: 0.5, y: 0.5)
	}
	
	private func addBackgroundNode() {
		let background = SKSpriteNode(imageNamed: "Background")
		addChild(background)
	}

}