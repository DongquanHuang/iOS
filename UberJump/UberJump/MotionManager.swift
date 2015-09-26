//
//  MotionManager.swift
//  UberJump
//
//  Created by Peter Huang on 15/8/22.
//  Copyright (c) 2015年 HDQ. All rights reserved.
//

import UIKit
import CoreMotion

class MotionManager: NSObject {
    
    struct CoreMotionConstants {
        static let UpdateInterval: NSTimeInterval = 0.2
    }
    
    var xAcceleration:CGFloat = 0.0
    let motionManager = CMMotionManager()
    
    func start() {
        motionManager.accelerometerUpdateInterval = CoreMotionConstants.UpdateInterval
        
        // Could not be tested by UT since simulator does not have CoreMotion capability
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handleAccelerometerData)
    }
    
    func handleAccelerometerData(data: CMAccelerometerData?, WithError error: NSError?) {
        if let acceleration = data?.acceleration {
            self.xAcceleration = (CGFloat(acceleration.x) * 0.75) + (self.xAcceleration * 0.25)
        }
    }

}
