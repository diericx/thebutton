//
//  LocalDataHandler.swift
//  TheButtonV2
//
//  Created by Zac Holland on 6/5/17.
//  Copyright © 2017 Diericx. All rights reserved.
//

import Foundation
import UIKit

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
    
    static func setNameSizeUpgradeStatus(status: Int) {
        defaults.set(status, forKey: "sizeUpgradeStatus")
    }
    
    static func setNameSpeedUpgradeStatus(status: Int) {
        defaults.set(status, forKey: "speedUpgradeStatus")
    }
    
    static func setNameChangeStatus(status: Bool) {
        defaults.set(status, forKey: "nameChangeStatus")
    }
    
    static func setColorPackIStatus(status: Bool) {
        defaults.set(status, forKey: "colorPackIStatus")
    }
    
    static func setButtonImg(status: Data) {
        defaults.set(status, forKey: "buttonImg")
    }
    
    static func setButtonDrawingStrokes(status: [Data]) {
        defaults.set(status, forKey: "buttonDrawingStrokes")
    }
    
    static func setColorPackIStatus() -> Bool? {
        let status = defaults.bool(forKey: "colorPackIStatus")
        return status
    }
    
    static func setLastLootCollectTime(status: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateString = dateFormatter.string(from:status)
        defaults.set(dateString, forKey: "lastLootCollectTime")
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
    
    static func getButtonImg() -> Data? {
        let imgId = defaults.data(forKey: "buttonImg")
        return imgId
    }
    
    static func getButtonDrawingStrokes() -> [Data]? {
        let strokes = defaults.array(forKey: "buttonDrawingStrokes")
        if strokes == nil {
            return nil
        }
        return strokes as? [Data]
    }
    
    static func getNameSizeUpgradeStatus() -> Int? {
        let status = defaults.integer(forKey: "sizeUpgradeStatus")
        return status
    }
    
    static func getNameSpeedUpgradeStatus() -> Int? {
        let status = defaults.integer(forKey: "speedUpgradeStatus")
        return status
    }
    
    static func getNameChangeStatus() -> Bool? {
        let status = defaults.bool(forKey: "nameChangeStatus")
        return status
    }
    
    static func getLastLootCollectTime() -> Date {
        let status = defaults.string(forKey: "lastLootCollectTime")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if (status == nil) {
            
            print("Date status nil")
            let calendar = Calendar.current
            let date = calendar.date(byAdding: .hour, value: -1, to: Date())
            setLastLootCollectTime(status: date!)
            
            return date!
        }
        
        let date = dateFormatter.date(from: status!)
        if (date == nil) {
            setLastLootCollectTime(status: Date())
        }
        return date!
    }
    
    
}
