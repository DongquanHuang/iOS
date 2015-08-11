//
//  ObjectConfiguration.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/11/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import SpriteKit

class ObjectConfiguration {
    
    func level(filename: String) -> Level {
        return Level(filename: filename)
    }
    
    func gameScene(size: CGSize) -> GameScene {
        return GameScene(size: size)
    }
}