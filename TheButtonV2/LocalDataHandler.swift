//
//  LocalDataHandler.swift
//  TheButtonV2
//
//  Created by Zac Holland on 6/5/17.
//  Copyright © 2017 Diericx. All rights reserved.
//

import Foundation

class LocalDataHandler {
    
    static let defaults = UserDefaults.standard
    
    static func setCoins(coins: Int) {
        defaults.set(coins, forKey: "coins")
    }
    
    static func setUsername(username: String) {
        defaults.set(username, forKey: "username")
    }
    
    static func setButtonImgId(id: String) {
        defaults.set(id, forKey: "buttonImgId")
    }
    
    static func getCoins() -> Int {
        let coins = defaults.integer(forKey: "coins")
        //TODO: remove this
        if coins == 0 {
            setCoins(coins: 100)
        }
        return coins
    }
    
    static func getUsername() -> String? {
        let username = defaults.string(forKey: "username")
        return username
    }
    
    static func getButtonImgId() -> String? {
        let imgId = defaults.string(forKey: "buttonImgId")
        return imgId
    }
    
}
