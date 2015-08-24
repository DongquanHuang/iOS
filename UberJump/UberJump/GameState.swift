//
//  GameState.swift
//  UberJump
//
//  Created by Peter Huang on 8/24/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import UIKit

class GameState: NSObject {
    
    struct GameStateConstants {
        static let HighScore = "highScore"
        static let Stars = "stars"
    }

    var score: Int = 0
    var highScore: Int = 0
    var stars: Int = 0
    
    var stateStore = NSUserDefaults.standardUserDefaults()
    
    class var sharedInstance: GameState {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: GameState? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = GameState()
        }
        return Static.instance!
    }
    
    func readState() {
        readHighScore()
        readStarNumber()
    }
    
    func saveState() {
        saveHighScore()
        saveStarNumber()
        stateStore.synchronize()
    }
    
    private func readHighScore() {
        highScore = stateStore.integerForKey(GameStateConstants.HighScore)
    }
    
    private func saveHighScore() {
        highScore = max(score, highScore)
        stateStore.setInteger(highScore, forKey: GameStateConstants.HighScore)
    }
    
    private func readStarNumber() {
        stars = stateStore.integerForKey(GameStateConstants.Stars)
    }
    
    private func saveStarNumber() {
        stateStore.setInteger(stars, forKey: GameStateConstants.Stars)
    }
}
