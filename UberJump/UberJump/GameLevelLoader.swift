//
//  GameLevelLoader.swift
//  UberJump
//
//  Created by Peter Huang on 8/21/15.
//  Copyright (c) 2015 HDQ. All rights reserved.
//

import UIKit

struct LevelConstants {
    static let StartLevel = 1
    static let EndLevel = 99
}

class GameLevelLoader: NSObject {
    
    func loadLevel(level: Int) -> GameLevel? {
        if let levelPlist = getPlistFilePathForLevel(level) {
            var gameLevel = GameLevel()
            
            if let levelData = NSDictionary(contentsOfFile: levelPlist) {
                fillDataForGameLevel(gameLevel, FromLevelData: levelData)
            }
            
            return gameLevel
        }
        else {
            return nil
        }
    }
    
    private func getPlistFilePathForLevel(level: Int) -> String? {
        return NSBundle.mainBundle().pathForResource(levelFileName(level), ofType: "plist")
    }
    
    private func levelFileName(level: Int) -> String {
        return String(format: "Level_%02d", level % (LevelConstants.EndLevel + 1))
    }
    
    private func fillDataForGameLevel(gameLevel: GameLevel, FromLevelData levelData: NSDictionary) {
        fillTargetForGameLevel(gameLevel, FromLevelData: levelData)
        fillGameObjectsForGameLevel(gameLevel, FromLevelData: levelData)
    }
    
    private func fillTargetForGameLevel(gameLevel: GameLevel, FromLevelData levelData: NSDictionary) {
        gameLevel.endLevelY = levelData["EndY"]!.integerValue!
    }
    
    private func fillGameObjectsForGameLevel(gameLevel: GameLevel, FromLevelData levelData: NSDictionary) {
        fillPlatformsForGameLevel(gameLevel, FromLevelData: levelData)
        fillStarsForGameLevel(gameLevel, FromLevelData: levelData)
    }
    
    private func fillPlatformsForGameLevel(gameLevel: GameLevel, FromLevelData levelData: NSDictionary) {
        let platforms = levelData["Platforms"] as! NSDictionary
        let platformPatterns = platforms["Patterns"] as! NSDictionary
        let platformPositions = platforms["Positions"] as! [NSDictionary]
        
        for platformPosition in platformPositions {
            let patternX = platformPosition["x"]?.floatValue
            let patternY = platformPosition["y"]?.floatValue
            let pattern = platformPosition["pattern"] as! NSString
            
            let platformPattern = platformPatterns[pattern] as! [NSDictionary]
            for platformPoint in platformPattern {
                let x = platformPoint["x"]?.floatValue
                let y = platformPoint["y"]?.floatValue
                let type = PlatformType(rawValue: platformPoint["type"]!.integerValue)
                let positionX = CGFloat(x! + patternX!)
                let positionY = CGFloat(y! + patternY!)
                
                let platformNode = PlatformNode()
                platformNode.position = CGPoint(x: positionX, y: positionY)
                platformNode.platformType = type!
                
                gameLevel.platforms.append(platformNode)
            }
        }
    }
    
    private func fillStarsForGameLevel(gameLevel: GameLevel, FromLevelData levelData: NSDictionary) {
        let stars = levelData["Stars"] as! NSDictionary
        let starPatterns = stars["Patterns"] as! NSDictionary
        let starPositions = stars["Positions"] as! [NSDictionary]
        
        for starPosition in starPositions {
            let patternX = starPosition["x"]?.floatValue
            let patternY = starPosition["y"]?.floatValue
            let pattern = starPosition["pattern"] as! NSString
            
            let starPattern = starPatterns[pattern] as! [NSDictionary]
            for starPoint in starPattern {
                let x = starPoint["x"]?.floatValue
                let y = starPoint["y"]?.floatValue
                let type = StarType(rawValue: starPoint["type"]!.integerValue)
                let positionX = CGFloat(x! + patternX!)
                let positionY = CGFloat(y! + patternY!)
                
                let starNode = StarNode()
                starNode.position = CGPoint(x: positionX, y: positionY)
                starNode.starType = type!
                
                gameLevel.stars.append(starNode)
            }
        }
    }

}
