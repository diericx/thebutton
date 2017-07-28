//
//  PubnubHandler.swift
//  TheButtonV2
//
//  Created by Zac Holland on 7/9/17.
//  Copyright © 2017 Diericx. All rights reserved.
//

import Foundation
import PubNub

class PubnubHandler {
    
    var client: PubNub?
    static var instance: PubnubHandler?
    static let uuid = UIDevice.current.identifierForVendor!.uuidString
    
    init() {
        //instance = PubnubHandler()
    }
    
    static func subscribeToGlobal() {
        guard let instance = self.instance else {
            print("ERROR - Cannot subscribe: Instance not set!")
            return
        }
        
        let configuration = PNConfiguration(publishKey: "pub-c-9598bf00-2785-41d4-ad2f-d2362b2738d9", subscribeKey: "sub-c-8a0a7138-e751-11e6-94bb-0619f8945a4f")
        configuration.uuid = uuid
        configuration.presenceHeartbeatInterval = 15
        configuration.presenceHeartbeatValue = 30
        instance.client = PubNub.clientWithConfiguration(configuration)
        
        // Subscribe to demo channel with presence observation
        instance.client?.subscribeToChannels(["global"], withPresence: true)
    }
    
    static func unsubFromAll() {
        guard let instance = self.instance else {
            print("ERROR - Cannot send message: Instance not set!")
            return
        }
        guard let client = self.instance?.client else {
            
            return
        }
        client.unsubscribeFromAll()
    }
    
    static func addListener(listener: PNObjectEventListener) {
        guard let instance = self.instance else {
            print("ERROR - Cannot add listener: Instance not set!")
            return
        }
        guard let client = self.instance?.client else {
            
            return
        }
        client.addListener(listener)
    }
    
    static func sendMessage(packet: String) {
        guard let instance = self.instance else {
            print("ERROR - Cannot send message: Instance not set!")
            return
        }
        guard let client = self.instance?.client else {
            
            return
        }
        
        // Select last object from list of channels and send message to it.
        let targetChannel = client.channels().last!
        client.publish(packet, toChannel: targetChannel,
                            compressed: false, withCompletion: { (publishStatus) -> Void in
                                
                                if !publishStatus.isError {
                                    // Message successfully published to specified channel.
                                }
                                else {
                                    print("ERROR - SENDING MESSAGE FAILED");
                                    print(publishStatus.errorData);
                                    let alertController = UIAlertController(title: "Servers Unavailable", message: "Try checking your internet connection.", preferredStyle: .alert)
                                    
                                    let OKAction = UIAlertAction(title: "Okay", style: .default) { (action:UIAlertAction!) in
                                        //Call another alert here
                                    }
                                    alertController.addAction(OKAction)
                                    
                                    UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion:nil)
                                }
        })
    }
    
}
