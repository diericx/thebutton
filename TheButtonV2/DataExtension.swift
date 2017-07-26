//
//  DataExtension.swift
//  TheButtonV2
//
//  Created by Zac Holland on 6/3/17.
//  Copyright © 2017 Diericx. All rights reserved.
//
import Foundation
import Compression
import CoreGraphics
import UIKit

extension Data {
    static func compress(_ data: Data) -> Data {
        
        let sourceBuffer = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        let sourceBufferSize = (data as NSData).length
        
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: sourceBufferSize)
        let destinationBufferSize = sourceBufferSize*2
        
        let status = compression_encode_buffer(destinationBuffer, destinationBufferSize, sourceBuffer, sourceBufferSize, nil, COMPRESSION_LZMA)
        
        if status == 0 {
            print("Error with status: \(status)")
        }
        print("Original size: \(sourceBufferSize) | Compressed size: \(status)")
        return Data(bytesNoCopy: UnsafeMutablePointer<UInt8>(destinationBuffer), count: status, deallocator: .free)
    }
}


public extension Double {
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random:Double {
        get {
            return Double(arc4random()) / 0xFFFFFFFF
        }
    }
    /**
     Create a random number Double
     
     - parameter min: Double
     - parameter max: Double
     
     - returns: Double
     */
    public static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}

public extension Int {
    public static func random(min: Int, max: Int) -> Int {
        assert(min < max)
        return Int(arc4random_uniform(UInt32(max - min + 1))) + min
    }
}

public extension Float {
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random:Float {
        get {
            return Float(arc4random()) / 0xFFFFFFFF
        }
    }
    /**
     Create a random num Float
     
     - parameter min: Float
     - parameter max: Float
     
     - returns: Float
     */
    public static func random(min min: Float, max: Float) -> Float {
        return Float.random * (max - min) + min
    }
}
public extension CGFloat {
    /// Randomly returns either 1.0 or -1.0.
    public static var randomSign:CGFloat {
        get {
            return (arc4random_uniform(2) == 0) ? 1.0 : -1.0
        }
    }
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random:CGFloat {
        get {
            return CGFloat(Float.random)
        }
    }
    /**
     Create a random num CGFloat
     
     - parameter min: CGFloat
     - parameter max: CGFloat
     
     - returns: CGFloat random number
     */
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random * (max - min) + min
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in PNG format
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the PNG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    var png: Data? { return UIImagePNGRepresentation(self) }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}

extension UIView {
    
    /// Create snapshot
    ///
    /// - parameter rect: The `CGRect` of the portion of the view to return. If `nil` (or omitted),
    ///                   return snapshot of the whole view.
    ///
    /// - returns: Returns `UIImage` of the specified portion of the view.
    
    func snapshot(of rect: CGRect? = nil) -> UIImage? {
        // snapshot entire view
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let wholeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // if no `rect` provided, return image of whole view
        
        guard let image = wholeImage, let rect = rect else { return wholeImage }
        
        // otherwise, grab specified `rect` of image
        
        let scale = image.scale
        let scaledRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
    
}

extension CGContext {
    func drawFlipped(image: CGImage, rect: CGRect) {
        saveGState()
        translateBy(x: 0, y: rect.height)
        scaleBy(x: 1, y: -1)
        draw(image, in: rect)
        restoreGState()
    }
}

extension Array where Element:UILabel {
    func findByTag(tag: Int) -> UILabel? {
        for label in self {
            if label.tag == tag {
                return label
            }
        }
        return nil
    }
}

public class Node<T> {
    // 2
    var value: T
    var next: Node<T>?
    weak var previous: Node<T>?
    
    // 3
    init(value: T) {
        self.value = value
    }
}

public class LinkedList<T> {
    // 2. Change the head and tail variables to be constrained to type T
    fileprivate var head: Node<T>?
    private var tail: Node<T>?
    
    public var isEmpty: Bool {
        return head == nil
    }
    
    // 3. Change the return type to be a node constrained to type T
    public var first: Node<T>? {
        return head
    }
    
    // 4. Change the return type to be a node constrained to type T
    public var last: Node<T>? {
        return tail
    }
    
    // 5. Update the append function to take in a value of type T
    public func append(value: T) {
        let newNode = Node(value: value)
        if let tailNode = tail {
            newNode.previous = tailNode
            tailNode.next = newNode
        } else {
            head = newNode
        }
        tail = newNode
    }
    
    // 6. Update the nodeAt function to return a node constrained to type T
    public func nodeAt(index: Int) -> Node<T>? {
        if index >= 0 {
            var node = head
            var i = index
            while node != nil {
                if i == 0 { return node }
                i -= 1
                node = node!.next
            }
        }
        return nil
    }
    
    public func removeAll() {
        head = nil
        tail = nil
    }
    
    // 7. Update the parameter of the remove function to take a node of type T. Update the return value to type T.
    public func remove(node: Node<T>) -> T {
        let prev = node.previous
        let next = node.next
        
        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        next?.previous = prev
        
        if next == nil {
            tail = prev
        }
        
        node.previous = nil
        node.next = nil
        
        return node.value
    }
}

public struct Queue<T> {
    
    // 2
    fileprivate var list = LinkedList<T>()
    
    public var isEmpty: Bool {
        return list.isEmpty
    }
    
    // 3
    public mutating func enqueue(_ element: T) {
        list.append(value: element)
    }
    
    // 4
    public mutating func dequeue() -> T? {
        guard !list.isEmpty, let element = list.first else { return nil }
        
        list.remove(node: element)
        
        return element.value
    }
    
    // 5
    public func peek() -> T? {
        return list.first?.value
    }
}
