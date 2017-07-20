//
//  Tree.swift
//  TheButtonV2
//
//  Created by Zac Holland on 7/13/17.
//  Copyright © 2017 Diericx. All rights reserved.
//

import Foundation

class ETree {
    
    var root: Node
    
    init() {
        root = Node(value: "root")
    }
    
    func addChildToRoot(node: Node) -> Node {
        return root.addChild(node: node)
    }
    
    func printTree() {
        root.printNode(spacing: "")
    }
    
    func findRecipe(emoji: String) -> Node? {
        return root.findRecipeNode(emoji: emoji)
    }
    
    class Node {
        var value: String = ""
        var level: Int = 0
        var parent: Node? = nil
        var children: [Node] = []
        
        init(value: String, parent: Node) {
            self.value = value
            self.parent = parent
        }
        
        init(value: String) {
            self.value = value
        }
        
        func addChild(node: Node) -> Node {
            node.parent = self
            node.level = self.level + 1
            children.append(node)
            return node
        }
        
        func addSibling(node: Node) -> Node? {
            guard let p = self.parent else {
                return nil
            }
            return p.addChild(node: node)
        }
        
        func findRecipeNode(emoji: String) -> Node? {
            if children.count == 0 {
                return nil
            }
            if (value == emoji && children.count > 0) {
                return self
            } else {
                for n in children {
                    let childValue = n.findRecipeNode(emoji: emoji)
                    if (childValue != nil) {
                        return childValue
                    }
                }
            }
            return nil
        }
        
        func printNode(spacing: String) {
            print(spacing + value + "[\(self.level)]")
            let s = spacing + "  "
            for n in children {
                n.printNode(spacing: s)
            }
        }
        
    }
}
