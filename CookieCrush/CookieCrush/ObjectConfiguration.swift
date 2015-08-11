//
//  ObjectConfiguration.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/11/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import SpriteKit

class ObjectConfiguration {
    var level = Level()
    
    func gameScene(size: CGSize) -> GameScene {
        return GameScene(size: size)
    }
}