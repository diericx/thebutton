//
//  IAPViewController.swift
//  TheButtonV2
//
//  Created by Zac Holland on 8/28/17.
//  Copyright © 2017 Diericx. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit

var sharedSecret = "b588f003142a4c63b5f3e169dd463c42"

enum RegisteredPurchase : String {
    case sCoinPack = "SmallCoinPack"
    case mCoinPack = "MediumCoinPack"
    case lCoinPack = "LargellCoinPack"
    case hCoinPack = "HugeCoinPack"
    case gCoinPack = "GiantCoinPack"
}

class IAPViewController: UIViewController {
    
    static let bundleID = "com.diericx.TheButtonV3"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    static func getInfo(purchase: RegisteredPurchase) {
        NetworkActivityManager.NetworkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([bundleID + "." + purchase.rawValue]) {
            (result) in
            
            NetworkActivityManager.NetworkOperationFinished()
            //Add an alert
        }
    }
    
    static func purchase(purchase: RegisteredPurchase) {
        NetworkActivityManager.NetworkOperationStarted()
        SwiftyStoreKit.purchaseProduct(bundleID + "." + purchase.rawValue) {
            (result) in
            
            NetworkActivityManager.NetworkOperationFinished()
            
        }
    }
    
    static func restorePurcahses() {
        NetworkActivityManager.NetworkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true) { (result) in
            NetworkActivityManager.NetworkOperationFinished()
        }
    }
    
    static func verifyReceipt() {
        NetworkActivityManager.NetworkOperationStarted()
        SwiftyStoreKit.verifyReceipt(password: sharedSecret) {
            (result) in
            NetworkActivityManager.NetworkOperationFinished()
            
        }
    }
    
    static func verifyPurchase() {
        NetworkActivityManager.NetworkOperationStarted()
        SwiftyStoreKit.verifyReceipt(password: sharedSecret) {
            (result) in
            NetworkActivityManager.NetworkOperationFinished()
            
        }
    }
    
    static func refreshReceipt() {
        SwiftyStoreKit.refreshReceipt {
            (result) in
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//handles the network loading spiral in top left of screen
class NetworkActivityManager: NSObject {
    private static var loadingCount = 0
    
    class func NetworkOperationStarted() {
        if loadingCount == 0 {
            //spiral in top left corner when loading network
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        loadingCount += 1
    }
    
    class func NetworkOperationFinished() {
        if loadingCount > 0 {
            loadingCount -= 1
        }
        
        if loadingCount == 0 {
            //spiral in top left corner when loading network
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
}
