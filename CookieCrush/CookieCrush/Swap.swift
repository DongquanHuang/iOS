//
//  Swap.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/11/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import Foundation

struct Swap {
    let cookieA: Cookie
    let cookieB: Cookie
    
    init(cookieA: Cookie, cookieB: Cookie) {
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    
    var description: String {
        return "swap \(cookieA) with \(cookieB)"
    }
}