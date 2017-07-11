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
        8,
        //Tier 2
        8,
        8,
        8
    ]
    
    //Returns current emoji inventory
    static func myInventory() -> [String] {
        return LocalDataHandler.getEmojiArray()
    }
    
    //check if I already own an emoji
    static func doIOwn(emojiInput: String) -> Bool {
        for emoji in emojis {
            if emoji == emojiInput {
                //emoji is already in inventory
                return true
            }
        }
        return false
    }
    
    //attempt to add emoji to inventory
    //FALSE if emoji is already in inventory TRUE if emoji was succesfully added
    static func addToMyInventory(emojiInput: String) -> Bool {
        var emojis = myInventory()
        if (doIOwn(emojiInput: emojiInput)) {
            return false
        }
        //add emoji to inventory
        emojis.append(emojiInput)
        return true
    }
    
}
