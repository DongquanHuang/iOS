//
//  Chain.swift
//  CookieCrush
//
//  Created by Peter Huang on 8/13/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import Foundation

class Chain: Hashable, Printable {
    enum ChainType: Printable {
        case Horizontal
        case Vertical
        
        var description: String {
            switch self {
            case .Horizontal: return "Horizontal"
            case .Vertical: return "Vertical"
            }
        }
    }
    
    var chainType: ChainType
    var cookies = [Cookie]()
    
    init(chainType: ChainType) {
        self.chainType = chainType
    }
    
    func addCookie(cookie: Cookie) {
        cookies.append(cookie)
    }
    
    func firstCookie() -> Cookie {
        return cookies[0]
    }
    
    func lastCookie() -> Cookie {
        return cookies[cookies.count - 1]
    }
    
    func length() -> Int {
        return cookies.count
    }
    
    var hashValue: Int {
        return reduce(cookies, 0) { $0.hashValue ^ $1.hashValue }
    }
    
    var description: String {
        return "Chain type:\(chainType) with cookies:\(cookies)"
    }
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
    return lhs.cookies == rhs.cookies
}