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
            let gameLevel = GameLevel()
            
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
        
        let properties = gameObjectPositionAndTypeFromPositions(platformPositions, AndPatterns: platformPatterns)
        for property in properties {
            let platformNode = PlatformNode()
            platformNode.position = property.0
            platformNode.platformType = PlatformType(rawValue: property.1)
            
            gameLevel.platforms.append(platformNode)
        }
    }
    
    private func fillStarsForGameLevel(gameLevel: GameLevel, FromLevelData levelData: NSDictionary) {
        let stars = levelData["Stars"] as! NSDictionary
        let starPatterns = stars["Patterns"] as! NSDictionary
        let starPositions = stars["Positions"] as! [NSDictionary]
        
        let properties = gameObjectPositionAndTypeFromPositions(starPositions, AndPatterns: starPatterns)
        for property in properties {
            let starNode = StarNode()
            starNode.position = property.0
            starNode.starType = StarType(rawValue: property.1)
            
            gameLevel.stars.append(starNode)
        }
    }
    
    private func gameObjectPositionAndTypeFromPositions(positions: [NSDictionary], AndPatterns patterns: NSDictionary) -> [(CGPoint, Int)] {
        var result = [(CGPoint, Int)]()
        
        for position in positions {
            let x = position["x"]?.floatValue
            let y = position["y"]?.floatValue
            
            let pattern = position["pattern"] as! NSString
            let gameObjectPatterns = patterns[pattern] as! [NSDictionary]
            
            for gameObjectPattern in gameObjectPatterns {
                let patternX = gameObjectPattern["x"]?.floatValue
                let patternY = gameObjectPattern["y"]?.floatValue
                let positionX = CGFloat(x! + patternX!)
                let positionY = CGFloat(y! + patternY!)
                
                let type = gameObjectPattern["type"]?.integerValue
                
                let objectProperty = (CGPoint(x: positionX, y: positionY), type!)
                result.append(objectProperty)
            }
        }
        
        return result
    }

}
