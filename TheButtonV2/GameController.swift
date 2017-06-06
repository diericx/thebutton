//
//  ViewController.swift
//  TheButtonV2
//
//  Created by Zac Holland on 6/3/17.
//  Copyright © 2017 Diericx. All rights reserved.
//

import UIKit
import PubNub
import Foundation
import CloudKit

class GameController: UIViewController, PNObjectEventListener {
    
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var potLabel: UILabel!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.client.addListener(self)
        
        //Update wallet text
        //TODO: Make UpdateUI function
        self.updateCoinLabel()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        //Get current coin count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func OnButtonTap(_ sender: Any) {
        if LocalDataHandler.getCoins() > 0 {
            
            //send packet to pubnub
            appDelegate.sendMessage(packet: "{\"action\": \"button-press\", \"uuid\": \"" + appDelegate.uuid + "\", \"name\":\"Zac\"}");
            
            //update coins
            LocalDataHandler.setCoins(coins: LocalDataHandler.getCoins() - 1)
            
            //update coin UI
            self.updateCoinLabel()
            
        } else {
            //TODO: warn user that they are broke
            print("Out of funds!");
        }
    }
    
    //When the userData is collected, set ui and variable
//    func getUserDataCallback(record: CKRecord) {
//        appDelegate.userData = record
//        print("Coins: " + String(appDelegate.userData?["coins"] as! Int))
//        DispatchQueue.main.async {
//            // qos' default value is ´DispatchQoS.QoSClass.default`
//            self.updateCoinLabel()
//        }
//        
//    }
    
    func updateCoinLabel() {
        self.walletLabel.text = "Wallet: " + String(LocalDataHandler.getCoins())
    }
    
    func updatePotLabel() {
        self.potLabel.text = "$" + String(appDelegate.pot)
    }
    
    // Handle new message from one of channels on which client has been subscribed.
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        
        // Handle new message stored in message.data.message
        if message.data.channel != message.data.subscription {
            
            // Message has been received on channel group stored in message.data.subscription.
        }
        else {
            
            // Message has been received on channel stored in message.data.channel.
        }
        
        //parse message
        let dictionary: AnyObject = message.data.message as AnyObject;
        let action: String = dictionary["action"] as! String
        if (action == "button-press") {
            //get user's name
            let name: String = dictionary["name"] as! String
            
            //Get current pot and set value
            let pot: Int = dictionary["pot"] as! Int
            print(pot)
            appDelegate.pot = pot
            //update ui
            updatePotLabel()
            
            let randX = arc4random_uniform(UInt32(self.view.bounds.width-100))+50;
            let label = UILabel(frame: CGRect(x: Int(randX), y: 100, width: 200, height: 21))
            // you will probably want to set the font (remember to use Dynamic Type!)
            label.font = UIFont.preferredFont(forTextStyle: .title1)
            // and set the text color too - remember good contrast
            label.textColor = .black
            // may not be necessary (e.g., if the width & height match the superview)
            // if you do need to center, CGPointMake has been deprecated, so use this
            label.center = CGPoint(x: Int(randX), y: Int(self.view.bounds.height/2) )
            // this changed in Swift 3 (much better, no?)
            label.textAlignment = .center
            label.text = name
            self.view.addSubview(label)
            
            UIView.animate(withDuration: 3.0, animations: {
                label.center.y -= self.view.bounds.height*1.5
            })
        } else if (action == "win") {
            let uuid = dictionary["uuid"] as! String;
            if uuid == appDelegate.uuid {
                appDelegate.winner = true
                //update local userData coin value
                LocalDataHandler.setCoins(coins: LocalDataHandler.getCoins() + appDelegate.pot)
                //sync local data with cloud
                appDelegate.syncUserDataWithCloud()
            }
            appDelegate.winnerName = dictionary["name"] as! String;
            performSegue(withIdentifier: "ShowWinScreenSegue", sender: self)
        }
    }

}

