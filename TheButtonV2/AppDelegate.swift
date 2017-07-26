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
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    typealias GetUserDataCallback = (_ record : CKRecord)  -> Void
    
    override init() {
        super.init()
        //Set up pubnub
        PubnubHandler.instance = PubnubHandler()
        PubnubHandler.subscribeToGlobal()
        //Emoji Tree Setup
        Emoji.instance = Emoji()
        //DEBUG
        //TODO: Remove this
//        LocalDataHandler.setNameSizeUpgradeStatus(status: 0)
//        LocalDataHandler.setNameSpeedUpgradeStatus(status: 0)
        LocalDataHandler.setCoins(coins: 5000)
        LocalDataHandler.setLevel(value: 0)
        LocalDataHandler.setTaps(value: 0)
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Initialize and configure PubNub client instance
        PubnubHandler.subscribeToGlobal()

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
        PubnubHandler.unsubFromAll()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("Will enter foreground")
        PubnubHandler.subscribeToGlobal()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("Will become active")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("Terminating")
        PubnubHandler.unsubFromAll()
    }


}

