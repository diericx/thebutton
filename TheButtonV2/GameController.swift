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
import AVFoundation

class GameController: UIViewController, PNObjectEventListener {

    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var potLabel: UILabel!
    @IBOutlet weak var theButton: UIButton!
    @IBOutlet weak var usernameWarningLabel: UILabel!
    @IBOutlet weak var hourGlassImageView: UIImageView!
    @IBOutlet weak var timeToCollectTxt: UILabel!
    @IBOutlet weak var winnerButtonImageView: UIImageView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var notification: NSObjectProtocol?
    var username = LocalDataHandler.getUsername()
    
    var shouldResizeHourglass = true;
    var canCollect = false;
    
    var timeToCollectTimer: Timer!
    
    var avplayer: AVAudioPlayer!
    
    public static var tier = 0
    
    //testing gravity
    var animators = [UIDynamicAnimator!]()
    var gravityBehaviours = [UIGravityBehavior!]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.client.addListener(self)
        
        //Update wallet text
        //TODO: Make UpdateUI function
        self.updateCoinLabel()
        
        notification = NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) {
            [unowned self] notification in
            self.appDelegate.client.addListener(self)
        }
        
        //update ttc text
        updateTimeToCollectTxt()
        
        //resize hourglass
        resizeHourGlass()
        //update timer text
        timeToCollectTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateTimeToCollectTxt), userInfo: nil, repeats: true)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.updateCoinLabel()
        self.updatePotLabel()
        //Get current coin count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //change whether the button can be seen according to username
        username = LocalDataHandler.getUsername()
        print("Username: " + String((username == nil)))
        if username == nil || username == "" {
            theButton.isHidden = true
            usernameWarningLabel.isHidden = false
        }else {
            theButton.isHidden = false
            usernameWarningLabel.isHidden = true
        }
        
        //set winner button
        if appDelegate.winnerButtonImg != nil {
            print("Found a winner button image!")
            winnerButtonImageView.image = appDelegate.winnerButtonImg
        } else {
            print("No winner button image!")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func updateTimeToCollectTxt() {
        var lastLootCollect = LocalDataHandler.getLastLootCollectTime()
        let interval = Date().timeIntervalSince(lastLootCollect)
        print(interval)
        if interval/60/60 > 1 {
            timeToCollectTxt.text = "Collect!";
            canCollect = true;
            //TODO enable a button here
        } else {
            timeToCollectTxt.text = String(60-Int(interval/60)) + "m"
        }
    }
    
    func playSound(name: String, type: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: type) else {
            print("error")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            avplayer = try AVAudioPlayer(contentsOf: url)
            guard let avplayer = avplayer else { return }
            
            avplayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func resizeHourGlass() {
        if (shouldResizeHourglass) {
            //animate hour glass
            UIView.animate(withDuration: 1, animations: {
                self.hourGlassImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }) { (finished) in
                UIView.animate(withDuration: 1, animations: {
                    self.hourGlassImageView.transform = CGAffineTransform.identity
                }) { (finished) in
                    self.resizeHourGlass()
                }
            }
        }
    }

    @IBAction func OnButtonTouchDown(_ sender: Any) {
        //shrink button
        UIView.animate(withDuration: 0.05,
                       animations: {
                        self.theButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
    }
    
    @IBAction func OnButtonTap(_ sender: Any) {
        //reset button size
        UIView.animate(withDuration: 0.02) {
            self.theButton.transform = CGAffineTransform.identity
        }
        
        if LocalDataHandler.getCoins() > 0 {
            //spawn coin
            var animator: UIDynamicAnimator!
            var gravity: UIGravityBehavior!
            let image = UIImage(named: "coinImg.png")
            let imageView = UIImageView(image: image!)
            imageView.frame = CGRect(x: self.view.bounds.width/2, y: self.view.bounds.height/2, width: 25, height: 25)
            view.addSubview(imageView)
            animator = UIDynamicAnimator(referenceView: view)
            gravity = UIGravityBehavior(items: [imageView])
            
            let randAngle = CGFloat.random(min: CGFloat((4*Double.pi)/3), max: CGFloat((5*Double.pi)/3));
            let instantaneousPush: UIPushBehavior = UIPushBehavior(items: [imageView], mode: UIPushBehaviorMode.instantaneous)
            instantaneousPush.setAngle( randAngle , magnitude: 0.2);
            animator.addBehavior(instantaneousPush)
            animator.addBehavior(gravity)
            
            animators.append(animator)
            gravityBehaviours.append(gravity)
            
            //send packet
            let nameSize = String(LocalDataHandler.getNameSizeUpgradeStatus()!*2)
            let nameSpeed = String(LocalDataHandler.getNameSpeedUpgradeStatus()!)
            print("nameSizeOnTap: " + nameSize)
            //send packet to pubnub
            appDelegate.sendMessage(packet: "{\"action\": \"button-press\", \"uuid\": \"" + appDelegate.uuid + "\", \"name\":\"" + username! + "\", \"name-size\": \"" + nameSize + "\", \"name-speed\": \"" + nameSpeed + "\" }");
        } else {
            //TODO: warn user that they are broke
            print("Out of funds!");
        }
    }
    
    @IBAction func onCollectBtnTap(_ sender: Any) {
        if (canCollect) {
            playSound(name: "coins", type: "wav")
            var coins = LocalDataHandler.getCoins()
            LocalDataHandler.setCoins(coins: coins+100)
            self.updateCoinLabel()
            LocalDataHandler.setLastLootCollectTime(status: Date())
            self.updateTimeToCollectTxt()
            performSegue(withIdentifier: "ShowCollectionScreen", sender: self)
            canCollect = false
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
        self.walletLabel.text = String(LocalDataHandler.getCoins())
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
            let nameSize: Int = Int(dictionary["name-size"] as! String)!
            let nameSpeed: Int = Int(dictionary["name-speed"] as! String)!
            let uuid: String = dictionary["uuid"] as! String
            
            //only deduct coins if the tap goes through
            if (uuid == appDelegate.uuid) {
                //update coins
                LocalDataHandler.setCoins(coins: LocalDataHandler.getCoins() - 1)
                
                //update coin UI
                self.updateCoinLabel()
            }
            
            //Get current pot and set value
            let pot: Int = dictionary["pot"] as! Int
            appDelegate.pot = pot
            //update ui
            updatePotLabel()
            
            let randX = arc4random_uniform(UInt32(self.view.bounds.width-100))+50;
            let label = UILabel(frame: CGRect(x: Int(randX), y: 100, width: 250, height: 50))
            // you will probably want to set the font (remember to use Dynamic Type!)
            label.font = UIFont(name: "Skranji", size: CGFloat(14 + nameSize))
            // and set the text color too - remember good contrast
            label.textColor = .white
            label.shadowColor = .black
            label.shadowOffset = CGSize(width: 2, height: 3)
            // may not be necessary (e.g., if the width & height match the superview)
            // if you do need to center, CGPointMake has been deprecated, so use this
            label.center = CGPoint(x: Int(randX), y: Int(self.view.bounds.height/2) + 100 )
            // this changed in Swift 3 (much better, no?)
            label.textAlignment = .center
            label.text = name
            self.view.addSubview(label)
            
            UIView.animate(withDuration: (2.0 + (Double(nameSpeed))/4), animations: {
                label.center.y -= self.view.bounds.height/2
                label.alpha = 0
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
            potLabel.text = "$0";
            appDelegate.winnerName = dictionary["name"] as! String;
            performSegue(withIdentifier: "ShowWinScreenSegue", sender: self)
        }
    }

}

