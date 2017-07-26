//
//  Tree.swift
//  TheButtonV2
//
//  Created by Zac Holland on 7/13/17.
//  Copyright © 2017 Diericx. All rights reserved.
//

import Foundation

class Emoji {
    
    var json: [String: AnyObject]?
    static var instance: Emoji?
    public static var recipes: [String: [String: Int]] = [:]
    public static var emojis: [String] = []
    public static var tiers: [Int] = []
    
    init() {
        do {
            if let file = Bundle.main.url(forResource: "emojiTree", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let j = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = j as? [String: AnyObject] {
                    // json is a dictionary
                    json = object
                } else if let object = j as? [AnyObject] {
                    // json is an array
                    print(object)
                } else {
                    print("***Emoji JSON is invalid***")
                }
            } else {
                print("***No Emoji JSON file***")
            }
        } catch {
            print(error.localizedDescription)
        }
        //set root rank to 1
        json?["tier"] = 1 as AnyObject
        //convert tree to dictionary and array
        Emoji.treeToArray(n: json!)
    }
    
    //convert tree to dictionary and array
    static func treeToArray(n: [String: AnyObject]) {
        var currentTier = 0
        var i = 0
        var q = Queue<[String: AnyObject]>()
        q.enqueue(n)
        while let v = q.dequeue() {
            //get name
            let nEmoji = v["name"] as? String
            var tier = v["tier"] as? Int
            
            //update tiers array
            if tier != currentTier {
                tiers.append(i)
                print("Tier Changed at: \(nEmoji!) with index: \(i)")
                currentTier += 1
            }
            //update emojis array
            emojis.append(nEmoji!)
            i+=1
            
            //attempt to get children
            guard var children = v["children"] as? [[String: AnyObject]] else {
                continue
            }
            //add children to queue and create recipe
            var recipe = [String: Int]()
            for index in 0..<children.count {
                guard var node = children[index] as? [String: AnyObject] else {
                    print("Couldnt convert child: \(n) to dictionary!")
                    continue
                }
                //create new entry in recipe from child node
                let nChildEmoji = node["name"] as? String
                recipe[nChildEmoji!] = 1
                node["tier"] = (tier! as Int + 1) as AnyObject
                //queue up child node
                q.enqueue(node)
            }
            //update recipes dictionary
            Emoji.recipes[nEmoji!] = recipe
        }
        
    }
    
    //get random emoji in tier
    static func randomEmojiInTier(t: Int, not: Int) -> Int {
        let min = Emoji.tiers[t]
        var max = 0
        if t+1 > Emoji.tiers.count-1 {
            max = Emoji.emojis.count-1
        } else {
            max = Emoji.tiers[t+1]
        }
        var rand = Int.random(min: min, max: max)
        while rand == not {
            rand = Int.random(min: min, max: max)
        }
        return rand
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
    
    static func isRecipeValid(recipeInput: [String: Int]) -> String? {
        for (key, value) in recipes {
            if recipeInput == value {
                return key
            }
        }
        return nil
    }
    
//    static func isRecipeValid(recipeInput: [String: Int], n: [String: AnyObject]) -> String? {
//        //get node's emoji
//        let nEmoji = n["name"] as? String
//        //attempt to get children
//        guard let children = n["children"] as? [[String: AnyObject]] else {
//            return nil
//        }
//        //check current recip
//        var recipe = [String: Int]()
//        for n in children {
//            let eEmoji = n["name"] as? String
//            recipe[eEmoji!] = 1
//        }
//        
//        if recipe == recipeInput {
//            //if they match, return true
//            return nEmoji
//        } else {
//            //if not, keep looking
//            for n in children {
//                guard let node = n as? [String: AnyObject] else {
//                    print("Couldnt convert child: \(n) to dictionary!")
//                    continue
//                }
//                let childValue = isRecipeValid(recipeInput: recipeInput, n: node)
//                if (childValue != nil) {
//                    return childValue
//                }
//            }
//        }
//        return nil
//    }
    
//    func findRecipe(emoji: String, n: [String: AnyObject]) -> [String: Int]? {
//        //get node's emoji
//        let nEmoji = n["name"] as? String
//        //attempt to get children
//        guard let children = n["children"] as? [[String: AnyObject]] else {
//            return nil
//        }
//        if (nEmoji == emoji && children.count > 0) {
//            //if its the emoji, return its recipe
//            var recipe = [String: Int]()
//            for n in children {
//                let eEmoji = n["name"] as? String
//                recipe[eEmoji!] = 1
//            }
//            return recipe
//        } else {
//            //if not, keep looking
//            for n in children {
//                guard let node = n as? [String: AnyObject] else {
//                    print("Couldnt convert child: \(n) to dictionary!")
//                    continue
//                }
//                let childValue = findRecipe(emoji: emoji, n: node)
//                if (childValue != nil) {
//                    return childValue
//                }
//            }
//        }
//        return nil
//    }
}
