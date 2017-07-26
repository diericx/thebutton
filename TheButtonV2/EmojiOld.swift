//
//  Emoji.swift
//  TheButtonV2
//
//  Created by Zac Holland on 7/9/17.
//  Copyright © 2017 Diericx. All rights reserved.
//

import Foundation

class EmojiOld {
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
    
    static var recipes: [String: [String: Int]] = ["👩🏽‍🎤": ["👮🏾‍♀️": 1, "👱🏼‍♀️": 1, "👱🏼": 1]]
    

    
//    static func isRecipeValid(recipe: [String: Int]) -> String? {
//        for (e, r) in recipes {
//            if recipe == r {
//                return e
//            }
//        }
//        return nil
//    }
    

    
}
