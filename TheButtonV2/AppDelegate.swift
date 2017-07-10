//
//  AppDelegate.swift
//  TheButtonV2
//
//  Created by Zac Holland on 6/3/17.
//  Copyright © 2017 Diericx. All rights reserved.
//

import UIKit
import PubNub
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PNObjectEventListener {

    var window: UIWindow?
    
    var container: CKContainer
    var publicDB: CKDatabase
    var privateDB: CKDatabase
//    var userID: String
    
    typealias GetUserDataCallback = (_ record : CKRecord)  -> Void
    
    var winner = false
    var winnerName = ""
    var winnerButtonImg: UIImage?
    var pot = 0
    // Stores reference on PubNub client to make sure what it won't be released.
    var client: PubNub!
    let uuid = UIDevice.current.identifierForVendor!.uuidString
    
    override init() {
        //CLOUDKIT
        // 1
        container = CKContainer.default()
        // 2
        publicDB = container.publicCloudDatabase
        // 3
        privateDB = container.privateCloudDatabase
        
        //DEBUG
        //TODO: Remove this
//        LocalDataHandler.setNameSizeUpgradeStatus(status: 0)
//        LocalDataHandler.setNameSpeedUpgradeStatus(status: 0)
        LocalDataHandler.setCoins(coins: 5000)
    }
    
    func sendMessage(packet: String) {
        // Select last object from list of channels and send message to it.
        let targetChannel = self.client.channels().last!
        self.client.publish(packet, toChannel: targetChannel,
                                   compressed: false, withCompletion: { (publishStatus) -> Void in
                                    
                                    if !publishStatus.isError {
                                        // Message successfully published to specified channel.
                                    }
                                    else {
                                        print("ERROR SENDING MESSAGE");
                                        print(publishStatus.errorData);
                                        let alertController = UIAlertController(title: "Servers Unavailable", message: "Try checking your internet connection.", preferredStyle: .alert)
                                        
                                        let OKAction = UIAlertAction(title: "Okay", style: .default) { (action:UIAlertAction!) in
                                            //Call another alert here
                                        }
                                        alertController.addAction(OKAction)
                                        
                                        self.window?.rootViewController?.present(alertController, animated: true, completion:nil)
                                    }
        })
    }
    
    /// async gets iCloud record ID object of logged-in iCloud user
    func iCloudUserIDAsync(complete: @escaping (_ instance: CKRecordID?, _ error: NSError?) -> ()) {
        let container = CKContainer.default()
        container.fetchUserRecordID() {
            recordID, error in
            if error != nil {
                print(error!.localizedDescription)
                complete(nil, error as NSError?)
            } else {
                print("fetched ID \(recordID?.recordName)")
                complete(recordID, nil)
            }
        }
    }

//    func getUserDataRecord(callback: @escaping (_ record: CKRecord) -> ()) {
//        // call the function above in the following way:
//        // (userID is the string you are interested in!)
//        iCloudUserIDAsync { (recordID: CKRecordID?, error: NSError?) in
//            if let userID = recordID?.recordName {
//                print("received iCloudID \(userID)")
//                self.userID = userID
//                
//                //get current user record
//                var recId: CKRecordID = CKRecordID(recordName: userID)
//                self.publicDB.fetch(withRecordID: recId) { (record, error) -> Void in
//                    guard let record = record else {
//                        print("Error fetching record: ", error)
//                        return
//                    }
//                    print("Got User Record")
//                    self.userData = record
//                    callback(record)
//                }
//                
//            } else {
//                print("Fetched iCloudID was nil")
//            }
//        }
//    }
    
    //sync current userData with cloud userData
    func syncUserDataWithCloud() {
        //TODO: Sync local data with cloud
//        let myRecordName = self.userData?.recordID.recordName
//        let recordID = CKRecordID(recordName: myRecordName!)
//        
//        self.publicDB.fetch(withRecordID: recordID, completionHandler: { (record, error) in
//            if error != nil {
//                print("Error fetching record: \(error?.localizedDescription)")
//            } else {
//                // Now you have grabbed your existing record from iCloud
//                // Apply whatever changes you want
//                record?.setObject(self.userData?["coins"], forKey: "coins")
//                
//                // Save this record again
//                self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
//                    if saveError != nil {
//                        print("Error saving record: \(saveError?.localizedDescription)")
//                    } else {
//                        print("Successfully updated record!")
//                    }
//                })
//            }
//        })

    }
    
    func subscribeToGlobal() {
        let configuration = PNConfiguration(publishKey: "pub-c-9598bf00-2785-41d4-ad2f-d2362b2738d9", subscribeKey: "sub-c-8a0a7138-e751-11e6-94bb-0619f8945a4f")
        configuration.presenceHeartbeatInterval = 15
        configuration.presenceHeartbeatValue = 30
        self.client = PubNub.clientWithConfiguration(configuration)
        
        // Subscribe to demo channel with presence observation
        self.client.subscribeToChannels(["global"], withPresence: true)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Initialize and configure PubNub client instance
        subscribeToGlobal()

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("Will resign active")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("moving to background")
        self.client.unsubscribeFromAll()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("Will enter foreground")
        subscribeToGlobal()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("Will become active")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("Terminating")
        self.client.unsubscribeFromAll()
    }


}

