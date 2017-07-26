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
import KDCircularProgress

class GameController: UIViewController, PNObjectEventListener {

    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var potLabel: UILabel!
    @IBOutlet weak var theButton: UIButton!
    @IBOutlet weak var usernameWarningLabel: UILabel!
    @IBOutlet weak var hourGlassImageView: UIImageView!
    @IBOutlet weak var timeToCollectTxt: UILabel!
    @IBOutlet weak var winnerButtonImageView: UIImageView!
    @IBOutlet var goalEmojiLabels:[UILabel]?
    @IBOutlet var currentEmojiLabels:[UILabel]?
    @IBOutlet var clouds:[UIImageView]?
    @IBOutlet weak var highlightBarImageView: UIImageView!
    @IBOutlet weak var tapAnimationsView: UIView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var progressBar: KDCircularProgress!
    @IBOutlet weak var coinsView: UIView!
    @IBOutlet weak var coinsTargetLocation: UIView!
    //instance vars
    private var notification: NSObjectProtocol?
    var username = LocalDataHandler.getUsername()
    var shouldResizeHourglass = true;
    var canCollect = false;
    var timeToCollectTimer: Timer!
    var coinSpawnTimer: Timer?
    var avplayer: AVAudioPlayer!
    var taps = 0
    var coinsToSpawn = 0
    //reset vars
    var goalEmojiLabelInitFrames: [CGRect] = []
    var currentEmojiLabelInitFrames: [CGRect] = []
    var highlightBarInitFrame: CGRect = CGRect()
    
    //static vars
    static var winner = false
    static var winnerName = ""
    static var winnerImg: UIImage?
    static let uuid = UIDevice.current.identifierForVendor!.uuidString
    static var gs = GameState()
    
    //testing gravity
    var animators = [UIDynamicAnimator!]()
    var gravityBehaviours = [UIGravityBehavior!]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PubnubHandler.instance?.client?.addListener(self)
        
        //Update wallet text
        //TODO: Make UpdateUI function
        self.updateCoinLabel()
        
        notification = NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) {
            [unowned self] notification in
            PubnubHandler.addListener(listener: self)
        }
        
        //Fix image view
        let angle =  CGFloat(Double.pi/4)
        let tr = CGAffineTransform.identity.rotated(by: angle)
        self.winnerButtonImageView.transform = tr
        
        //TODO - get this info from pubnub
        //Set GameState defaults
        //TODO - make this more interesting
//        GameController.gs.currentEmojis = [0, 0, 0, 0]
        
        //collect initial positions
        for emoji in goalEmojiLabels! {
            goalEmojiLabelInitFrames.append(emoji.frame)
        }
        for emoji in currentEmojiLabels! {
            currentEmojiLabelInitFrames.append(emoji.frame)
        }
        highlightBarInitFrame = highlightBarImageView.frame
        
        //setup clous
        for cloud in clouds! {
            animateCloud(cloud: cloud)
        }
        
        //spawn coins
        
        
        //reset positions
//        GameController.ResetGameState()
        resetGameToMatchState()
        
        //update ttc text
        updateTimeToCollectTxt()
        
        //update goal and current emojis to show what the current goal/current selected emoji is
        updateGoalEmojiLabels()
        updateCurrentEmojiLabels()
        
        //resize hourglass
        resizeHourGlass()
        //update timer text
        timeToCollectTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateTimeToCollectTxt), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        resetGameToMatchState()
        //Get current coin count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("*****VIEW DID APPEAR*****")
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
        if GameController.winnerImg != nil {
            print("Found a winner button image!")
            winnerButtonImageView.image = GameController.winnerImg
        } else {
            //Get latest winner image
            CKHandler.GetMostRecentWinImg { (record) in
                DispatchQueue.main.async {
                    let imageData = record["Image"] as! Data
                    let image = UIImage(data: imageData)
                    GameController.winnerImg = image
                    self.winnerButtonImageView.image = image
                }
            }
        }
        
        self.updateCoinLabel()
        self.updatePotLabel()
        self.updateCurrentEmojiLabels()
        self.updateGoalEmojiLabels()
        
        resetGameToMatchState()
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
    
    //updates goal emoji labels
    func updateGoalEmojiLabels() {
        for label in goalEmojiLabels! {
            label.text = Emoji.emojis[GameController.gs.goalEmojis[label.tag]]
        }
    }
    //updates all current emoji labels
    func updateCurrentEmojiLabels() {
        for label in currentEmojiLabels! {
            var newEmoji = GameController.gs.currentEmojis[label.tag]
            label.text = Emoji.emojis[GameController.gs.currentEmojis[label.tag]]
        }
    }
    
    //reset all emoji labels
    func resetGameToMatchState() {
        let tier = GameController.gs.tier
        var i = 0
        for emoji in currentEmojiLabels! {
//            print("Resetting emoji label...")
//            print(currentEmojiLabelInitFrames[i])
            emoji.frame = currentEmojiLabelInitFrames[i]
            emoji.isHidden = false
            emoji.transform = CGAffineTransform(scaleX: 1, y: 1);
            i+=1
        }
        i=0
        for emoji in goalEmojiLabels! {
            emoji.frame = goalEmojiLabelInitFrames[i]
            emoji.isHidden = false
            emoji.transform = CGAffineTransform(scaleX: 1, y: 1);
            i+=1
        }
        
        //match state
        for i in 1...4 {
            if GameController.gs.currentEmojis[i] == GameController.gs.goalEmojis[i] {
                currentEmojiLabels?.findByTag(tag: i)?.isHidden = true
            }
        }
        
        //reset highlight
        //highlightBarImageView.frame = highlightBarInitFrame
        let f = highlightBarInitFrame
        let currentLabel = self.currentEmojiLabels?.findByTag(tag: tier)
        let newSize = CGRect(x: f.origin.x, y: (currentLabel?.frame.origin.y)!, width: f.width, height: (currentLabel?.frame.height)! )
        highlightBarImageView.frame = newSize
        
        //update taps
        updateTapUI()
    }
    
    func increaseTapCount() {
        taps += 1
        //TODO - change this so you keep taps
        if taps == GameController.gs.tapsToNextLevel {
            levelUp()
        }
        LocalDataHandler.setTaps(value: taps)
        updateTapUI()
    }
    
    func updateTapUI() {
//        let pBarAngle = (Double(taps) / Double(GameController.gs.tapsToNextLevel!)) * Double(360)
        let level = LocalDataHandler.getLevel()
        let taps = LocalDataHandler.getTaps()
        let tapsToGetToLevel = LocalDataHandler.tapsToGetToLevel(level: level-1)
        let xp = taps - tapsToGetToLevel
        let goalXp = LocalDataHandler.levelTapGoalFunc(level: level)
        let pBarAngle = (Double(xp)/Double(goalXp)) * Double(360)
        progressBar.animate(toAngle: pBarAngle, duration: 0.2, completion: nil)
    }
    
    func levelUp() {
        //add to level
        var level = LocalDataHandler.getLevel()
        level += 1
        LocalDataHandler.setLevel(value: level)
        //reward coins
        coinsToSpawn += LocalDataHandler.coinRewardFunc(level: level)
        coinSpawnTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: Selector("spawnCoin"),userInfo: nil, repeats: true)
        //update tap goal
        GameController.gs.tapsToNextLevel = LocalDataHandler.tapsToGetToLevel(level: level)//LocalDataHandler.levelTapGoalFunc(level: level)
    }
    
    static func ResetGameState() {
//        GameController.gs.tier = 4
//        GameController.gs.pot = 0
//        GameController.gs.currentEmojis = [-1, 0, 0, 0, 0]
        GameController.gs = GameState()
    }
    
    //changes the current emoji, if its the correct one go on to the next tier
    func changeCurrentEmoji() {
        for label in currentEmojiLabels! {
            if label.tag == GameController.gs.tier {
                //found current emoji label
                var chance = Int.random(min: 1, max: GameState.tierChances[GameController.gs.tier])
                print("CHANCE: \(chance)")
                if (chance == 1) {
                    GameController.gs.currentEmojis[GameController.gs.tier] = GameController.gs.goalEmojis[GameController.gs.tier]
                } else {
                    GameController.gs.currentEmojis[GameController.gs.tier] = Emoji.randomEmojiInTier(t: GameController.gs.tier, not: GameController.gs.goalEmojis[GameController.gs.tier])
                }
//                var rand = Emoji.randomEmojiInTier(t: GameController.gs.tier+1)
//                while (rand == GameController.gs.currentEmojis[GameController.gs.tier]) {
//                    rand = Emoji.randomEmojiInTier(t: GameController.gs.tier+1)
//                }
                updateCurrentEmojiLabels()
                //check if tier has been won
                if GameController.gs.hasWonTier() {
                    //this tier has just changed during this call so we may need to use its previous value
                    let tier = GameController.gs.tier
                    let goalEmoji = GameController.gs.goalEmojis[tier+1]
                    let emoji = Emoji.emojis[goalEmoji]
                    if (GameController.gs.tier == 0) {
                        PubnubHandler.sendMessage(packet: "{\"action\": \"win\", \"uuid\": \"" + GameController.uuid + "\", \"name\":\"" + username! + "\" }");
                    }
                    //attempt to add emoji to inventory
                    Emoji.addToMyInventory(emojiInput: emoji)
                    //TODO - display tier winning animations with coins
                    tierWonAnimation(prev: GameController.gs.tier, cur: GameController.gs.tier+1)
                }
                
                break
            }
        }
    }
    
    //plays animation for tier change
    func tierWonAnimation(prev: Int, cur: Int) {
        let tier = GameController.gs.tier
        let currentLabel = self.currentEmojiLabels?.findByTag(tag: tier+1)
        UIView.animate(withDuration: 1.5, animations: {
            
            //targot origin/frame
            let newFrame = self.profileButton.frame
            currentLabel?.frame = newFrame
            currentLabel?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1);
        })  { (finished) in
            currentLabel?.isHidden = true
        }
        print("tier: \(tier)")
        //Animate highlight bar
        UIView.animate(withDuration: 0.5, animations: {
            guard let curGoalLabel = self.goalEmojiLabels?.findByTag(tag: tier+1) else {
                print ("ERROR - Couldnt show animation, couldn't find label")
                return
            }
            self.highlightBarImageView.frame.origin.y = curGoalLabel.frame.origin.y
            let f = self.highlightBarImageView.frame
            let newSize = CGRect(x: f.origin.x, y: f.origin.y, width: f.width, height: curGoalLabel.frame.height)
            self.highlightBarImageView.frame = newSize
        }) { (finished) in

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
    
    func animateCloud(cloud: UIImageView) {
        let time = CGFloat.random(min: 9, max: 20)
        let delay = CGFloat.random(min: 0, max: 2)
        let initFrame = cloud.frame
        
        UIView.animate(withDuration: TimeInterval(time), delay: TimeInterval(delay), options: [.curveLinear], animations: {
            //targot origin/frame
            var newFrame = cloud.frame
            newFrame.origin.x = UIScreen.main.bounds.width + 200
            cloud.frame = newFrame
        })  { (finished) in
            cloud.frame = initFrame
            cloud.frame.origin.y = CGFloat.random(min: 84, max: 400)
            self.animateCloud(cloud: cloud)
        }
    }
    
    func spawnCoin() {
        if (coinsToSpawn <= 0 && coinSpawnTimer != nil) {
            coinSpawnTimer?.invalidate()
        }
        //spawn coin
        var animator: UIDynamicAnimator!
        var gravity: UIGravityBehavior!
        let image = UIImage(named: "coinImg.png")
        var imageView = UIImageView(image: image!)
        let randX = CGFloat.random(min: 0, max: theButton.frame.width-25)
        imageView.frame = CGRect(x: theButton.frame.origin.x + randX, y: theButton.frame.origin.y + (theButton.frame.height/2), width: 25, height: 25)
        coinsView.addSubview(imageView)
        //GRAVITY ANIMATION
//        animator = UIDynamicAnimator(referenceView: view)
//        gravity = UIGravityBehavior(items: [imageView])
//        
//        let randAngle = CGFloat.random(min: CGFloat((4*Double.pi)/3), max: CGFloat((5*Double.pi)/3));
//        let instantaneousPush: UIPushBehavior = UIPushBehavior(items: [imageView], mode: UIPushBehaviorMode.instantaneous)
//        instantaneousPush.setAngle( randAngle , magnitude: 0.2);
//        animator.addBehavior(instantaneousPush)
//        animator.addBehavior(gravity)
//        
//        animators.append(animator)
//        gravityBehaviours.append(gravity)
        //REGULAR ANIMATION
        UIView.animate(withDuration: 1.2, animations: {
            //targot origin/frame
            imageView.frame = self.coinsTargetLocation.frame
        })  { (finished) in
            //remove image
            imageView.removeFromSuperview()
            //add to coins
            var coins = LocalDataHandler.getCoins()
            coins += 1
            LocalDataHandler.setCoins(coins: coins)
            self.updateCoinLabel()
        }
        
        coinsToSpawn -= 1
    }

    @IBAction func OnButtonTouchDown(_ sender: Any) {
        //shrink button
        UIView.animate(withDuration: 0.02,
                       animations: {
//                        self.progressBar.glowAmount = 1
        })
    }
    
    @IBAction func OnButtonTap(_ sender: Any) {
        print("touch up")
        UIView.animate(withDuration: 0.02) {
//            self.progressBar.glowAmount = 0
        }
        if LocalDataHandler.getCoins() > 0 {
            
            //send packet
            let nameSize = String(LocalDataHandler.getNameSizeUpgradeStatus()!*2)
            let nameSpeed = String(LocalDataHandler.getNameSpeedUpgradeStatus()!)
            print("nameSizeOnTap: " + nameSize)
            //send packet to pubnub
            PubnubHandler.sendMessage(packet: "{\"action\": \"button-press\", \"uuid\": \"" + GameController.uuid + "\", \"name\":\"" + username! + "\", \"name-size\": \"" + nameSize + "\", \"name-speed\": \"" + nameSpeed + "\" }");
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
        self.potLabel.text = "$" + String(GameController.gs.pot)
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
            print("Got a button press")
            //get user's name
            let name: String = dictionary["name"] as! String
            let nameSize: Int = Int(dictionary["name-size"] as! String)!
            let nameSpeed: Int = Int(dictionary["name-speed"] as! String)!
            let uuid: String = dictionary["uuid"] as! String
            
            //only deduct coins if the tap goes through
            if (uuid == GameController.uuid) {
                //update coins
                LocalDataHandler.setCoins(coins: LocalDataHandler.getCoins() - 1)
                
                //update coin UI
                self.updateCoinLabel()
                
                //change current emoji
                changeCurrentEmoji()
                
                //increase taps
                increaseTapCount()
            }
            
            //Get current pot and set value
            let pot: Int = dictionary["pot"] as! Int
            GameController.gs.pot = pot
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
            self.tapAnimationsView.addSubview(label)
            
            UIView.animate(withDuration: (2.0 + (Double(nameSpeed))/4), animations: {
                label.center.y -= self.view.bounds.height/2
                label.alpha = 0
            })
        } else if (action == "win") {
            let uuid = dictionary["uuid"] as! String;
            if uuid == GameController.uuid {
                GameController.winner = true
                //update local userData coin value
                LocalDataHandler.setCoins(coins: LocalDataHandler.getCoins() + GameController.gs.pot)
                //sync local data with cloud
//                appDelegate.syncUserDataWithCloud()
            }
            potLabel.text = "$0";
            GameController.winnerName = dictionary["name"] as! String;
            GameController.gs = GameState()
            resetGameToMatchState()
            performSegue(withIdentifier: "ShowWinScreenSegue", sender: self)
        }
    }

}

class GameState {
    var goalEmojis: [Int] = [-1, 3, 1, 2, 3]
    var currentEmojis: [Int] = [-1, 0, 0, 0, 0]
    var tier = 4
    var pot = 0
    var tapsToNextLevel: Int?
    //const
    static let tierChances: [Int] = [-1, 2, 2, 2, 2]
    
    init() {
        tapsToNextLevel = LocalDataHandler.levelTapGoalFunc(level: LocalDataHandler.getLevel())
        //tier 4
        goalEmojis[1] = Emoji.randomEmojiInTier(t: 1, not: -1)
        //tier 3
        goalEmojis[2] = Emoji.randomEmojiInTier(t: 2, not: -1)
        //tier 2
        goalEmojis[3] = Emoji.randomEmojiInTier(t: 3, not: -1)
        //tier 1
        goalEmojis[4] = Emoji.randomEmojiInTier(t: 4, not: -1)
        
        for i in 1...4 {
            //update current emoji
            currentEmojis[i] = Emoji.randomEmojiInTier(t: i, not: -1)
            while currentEmojis[i] == goalEmojis[i] {
                currentEmojis[i] = Emoji.randomEmojiInTier(t: i, not: -1)
            }
            
        }
    }
    
    func hasWonTier() -> Bool {
        if currentEmojis[tier] == goalEmojis[tier] {
            tier -= 1
            return true
        } else {
            return false
        }
    }
}

