//
//  Emoji.swift
//  TheButtonV2
//
//  Created by Zac Holland on 7/9/17.
//  Copyright © 2017 Diericx. All rights reserved.
//

import Foundation

class Emoji {
    public static var emojis: [String] = [
        //Tier 1
        "✌🏼",
        "👮🏾‍♀️",
        "👱🏼‍♀️",
        "👱🏼",
        "👴🏿",
        "👩🏽‍🎤",
        "👩🏾‍🍳",
        "🤙🏿",
        "🤘🏼",
        
        //Tier 2
        "🤖",
        "🦁",
        "🐧",
        "🐺",
        "🐠",
        "🐬",
        "🦑",
        "🦍",
        "🍑",
        "🍔",
        "🌮",
        "🍆",
        "🍓",
        "🥑",
        "🐿",
        "🐡",
        "🥝",
        "🐍",
        "🐥",
        "🐸",
        "🐨"
        
        //Tier 3
        
    ]
    
    public static var tiers: [Int] = [
        //Tier 1
        3,
        //Tier 2
        3,
        3,
        3
    ]
    
    //Returns current emoji inventory
    static func myInventory() -> [String: Int] {
        return LocalDataHandler.getEmojiInvArray()
    }
    
    static func howManyDoIOwn(emojiInput: String) -> Int {
        var eInventory = LocalDataHandler.getEmojiInvArray()
        guard let count = eInventory[emojiInput] else {
            return 0
        }
        return count
    }
    
    //check if I already own an emoji
    static func doIOwn(emojiInput: String) -> Bool {
        var eInventory = LocalDataHandler.getEmojiInvArray()
        guard let value = eInventory[emojiInput] else {
            return false
        }
        return true
    }
    
    //attempt to add emoji to inventory
    //FALSE if emoji is already in inventory TRUE if emoji was succesfully added
    static func addToMyInventory(emojiInput: String) -> Bool {
        var emojis = myInventory()
        if (doIOwn(emojiInput: emojiInput)) {
            print("already own")
            emojis[emojiInput]! += 1
            LocalDataHandler.setEmojiInvArray(status: emojis)
            return false
        }
        //add emoji to inventory
        emojis[emojiInput] = 0
        LocalDataHandler.setEmojiInvArray(status: emojis)
        return true
    }
    
}
