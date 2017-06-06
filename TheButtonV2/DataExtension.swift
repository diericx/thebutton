//
//  DataExtension.swift
//  TheButtonV2
//
//  Created by Zac Holland on 6/3/17.
//  Copyright © 2017 Diericx. All rights reserved.
//
import Foundation
import Compression

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
