//
//  Double+Round.swift
//  SkyRunner
//
//  Created by Peter Huang on 8/4/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import Foundation

extension Double {
    func round(decimalPlace:Int) -> Double {
        let format = NSString(format: "%%.%if", decimalPlace)
        let string = NSString(format: format, self)
        return Double(atof(string.UTF8String))
    }
}