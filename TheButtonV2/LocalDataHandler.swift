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
    
    //gives the reward for acheiving a certain level
    static func coinRewardFunc(level: Int) -> Int {
        return (5*level*level) + 10
    }
    
    //gives the tap goal for a certain level
    static func levelTapGoalFunc(level: Int) -> Int {
            return (level*level) + 5
    }
    
    static func tapsToGetToLevel(level: Int) -> Int {
        if level < 0 {
            return 0
        }
        
        var sum = 0
        for i in 0...level {
            sum += levelTapGoalFunc(level: i)
        }
        return sum
    }
    
    static func setCoins(coins: Int) {
        defaults.set(coins, forKey: "coins")
    }
    
    static func setUsername(username: String) {
        print("Setting Name to: " + username);
        defaults.set(username, forKey: "username")
    }
    
    static func setLevel(value: Int) {
        defaults.set(value, forKey: "level")
    }
    
    static func setWinImgId(id: String) {
        defaults.set(id, forKey: "winImg")
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
    
    static func setEmojiInvArray(status: [String: Int]) {
        defaults.set(status, forKey: "emojiArray")
    }
    
    static func setTaps(value: Int) {
        defaults.set(value, forKey: "taps")
    }
    
    static func setEquippedEmoji(value: String) {
        defaults.set(value, forKey: "equippedEmoji")
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
    
    static func getWinImgId() -> String? {
        let imgId = defaults.string(forKey: "buttonImgId")
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
    
    static func getEmojiInvArray() -> [String: Int] {
        guard let status = defaults.value(forKey: "emojiArray") else {
            let emojiArray: [String: Int] = [String: Int]()
            setEmojiInvArray(status: emojiArray)
            return emojiArray
        }
        return status as! [String: Int]
    }
    
    static func getTaps() -> Int {
        guard let taps = defaults.value(forKey: "taps") else {
            setTaps(value: 0)
            return 0
        }
        return taps as! Int
    }
    
    static func getLevel() -> Int {
        guard let level = defaults.value(forKey: "level") else {
            setLevel(value: 0)
            return 0
        }
        return level as! Int
    }
    
    static func getEquippedEmoji() -> String {
        guard let emoji = defaults.value(forKey: "equippedEmoji") else {
            setEquippedEmoji(value: "")
            return ""
        }
        return emoji as! String
    }
    
    
}
