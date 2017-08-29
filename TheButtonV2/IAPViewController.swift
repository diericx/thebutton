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
    case sCoinPack = "smallCoinPack"
    case mCoinPack = "mediumCoinPack"
    case lCoinPack = "largellCoinPack"
    case hCoinPack = "hugeCoinPack"
    case gCoinPack = "giantCoinPack"
}

class IAPViewController: UIViewController {
    
    let bundleID = "com.diericx.TheButtonV3"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func smallPackUpInside(_ sender: Any) {
        print("Purchase small pack")
        purchase(purchase: RegisteredPurchase.sCoinPack)
    }
    
    @IBAction func mediumPackUpInside(_ sender: Any) {
        purchase(purchase: RegisteredPurchase.mCoinPack)
    }
    
    @IBAction func backUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func getInfo(purchase: RegisteredPurchase) {
        NetworkActivityManager.NetworkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([bundleID + "." + purchase.rawValue]) {
            (result) in
            
            NetworkActivityManager.NetworkOperationFinished()
            
            self.showAlert(alert: self.alertForProductRetrievalInfo(result: result))
        }
    }
    
    func purchase(purchase: RegisteredPurchase) {
        NetworkActivityManager.NetworkOperationStarted()
        SwiftyStoreKit.purchaseProduct(bundleID + "." + purchase.rawValue) {
            (result) in
            
            NetworkActivityManager.NetworkOperationFinished()
            
            if case .success(let product) = result {
                
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                self.showAlert(alert: self.alertForPurcahseResult(result: result))
                
            } else if case .error(let error) = result {
                print("There was an error! \(error)")
            }
            
        }
    }
    
    func restorePurcahses() {
        NetworkActivityManager.NetworkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true) { (result) in
            
            NetworkActivityManager.NetworkOperationFinished()
            
            for product in result.restoredProducts {
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
            
            self.showAlert(alert: self.alertForRestorePurchases(result: result))
            
        }
    }
    
    func verifyReceipt() {
        NetworkActivityManager.NetworkOperationStarted()
        SwiftyStoreKit.verifyReceipt(password: sharedSecret) {
            (result) in
            
            NetworkActivityManager.NetworkOperationFinished()
            
            self.showAlert(alert: self.alertForVerifyReceipt(result: result))
            
            //if there is an error and there is no receipt data, try to get the data again
            if case .error(let error) = result {
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
        }
    }
    
    func verifyPurchase(product: RegisteredPurchase) {
        NetworkActivityManager.NetworkOperationStarted()
        SwiftyStoreKit.verifyReceipt(password: sharedSecret) {
            (result) in
            
            NetworkActivityManager.NetworkOperationFinished()
            
            switch result {
            case .success(let receipt):
                
                let productID = self.bundleID + "." + product.rawValue
                let productResult = SwiftyStoreKit.verifyPurchase(productId: productID, inReceipt: receipt)
                self.showAlert(alert: self.alertForVerifyPurchase(result: productResult))
                
            case .error(let error):
                self.showAlert(alert: self.alertForVerifyReceipt(result: result))
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
            
        }
    }
    
    func refreshReceipt() {
        SwiftyStoreKit.refreshReceipt {
            (result) in
            
            self.showAlert(alert: self.alertForRefreshReceipt(result: result))
            
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

extension IAPViewController {
    
    func alertWithTitle(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    
    func showAlert(alert: UIAlertController) {
        guard let _ = self.presentedViewController else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func alertForProductRetrievalInfo(result: RetrieveResults) -> UIAlertController {
        if let product = result.retrievedProducts.first {
            //purchase worked
            let priceString = product.localizedPrice!
            return alertWithTitle(title: product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        } else if let invalidProductID = result.invalidProductIDs.first {
            //There was an error witht he purchase id
            return alertWithTitle(title: "Could not retrieve product info", message: "Invalid product identifier \(invalidProductID)")
        } else {
            //There was an unknown error
            let errorString = result.error?.localizedDescription ?? "Unknown Error. Please Contact Support."
            return alertWithTitle(title: "Could not retrieve product info", message: errorString)
        }
        
    }
    
    func alertForPurcahseResult(result: PurchaseResult) -> UIAlertController {
        
        switch result {
        case .success(let product):
            print("Purchase Successful: \(product.productId)")
            return alertWithTitle(title: "Thank You", message: "Purchase Completed!")
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error {
            case .failed(let error):
                if (error as NSError).domain == SKErrorDomain {
                    //If there is somethign wrong with the domain of the error,
                    //then there is something wrong with the internet connection
                    return alertWithTitle(title: "Purchase Failed", message: "Check your internet connection or try again later.")
                } else {
                    return alertWithTitle(title: "Purchase Failed", message: "Unkown Error. Please Contact Support.")
                }
            case .invalidProductId(let productID):
                return alertWithTitle(title: "Purchase Failed", message: "\(productID) is not a valid product identifier.")
            case.noProductIdentifier:
                return alertWithTitle(title: "Purchase Failed", message: "Product not found.")
            case.paymentNotAllowed:
                return alertWithTitle(title: "Purchase Failed", message: "You are not allowed to make payments.")
            }
        }
        
    }
    
    func alertForRestorePurchases(result: RestoreResults) -> UIAlertController {
        
        if result.restoreFailedProducts.count > 0 {
            print("Restore Failed: \(result.restoreFailedProducts)")
            return alertWithTitle(title: "Restore Failed", message: "Unknown Error. Please Contact Support.")
        } else if result.restoredProducts.count > 0 {
            return alertWithTitle(title: "Purchases Restored!", message: "All purchases have been restored.")
        } else {
            return alertWithTitle(title: "Nothing To Restore", message: "No previous purchases were made.")
        }
        
    }
    
    func alertForVerifyReceipt(result: VerifyReceiptResult) -> UIAlertController {
        
        switch result {
        case .success(let receipt):
            return alertWithTitle(title: "Receipt Verified", message: "Receipt Verified Remotely")
        case .error(let error):
            switch error {
            case .noReceiptData:
                return alertWithTitle(title: "Receipt Verification", message: "No rceipt data found. Application will try to get a new one. Try Again.")
            default:
                return alertWithTitle(title: "Receipt Verification", message: "Receipt verification failed")
            }
        }
        
    }
    
    func alertForVerifySubscription(result: VerifySubscriptionResult) -> UIAlertController {
        switch result {
        case .purchased(let expiryDate):
            return alertWithTitle(title: "Product is Purchased", message: "Product will be valid until \(expiryDate)")
        case .notPurchased:
            return alertWithTitle(title: "Not Purchased", message: "this product has never been purchased")
        case .expired(let expiryDate):
            return alertWithTitle(title: "Product Expired", message: "Product is expired sunce \(expiryDate)")
        }
    }
    
    func alertForVerifyPurchase(result: VerifyPurchaseResult) -> UIAlertController {
        switch result {
        case .purchased:
            return alertWithTitle(title: "Product is Purchased", message: "")
        case .notPurchased:
            return alertWithTitle(title: "Product is Not Purchased", message: "")
        }
    }
    
    func alertForRefreshReceipt(result: RefreshReceiptResult) -> UIAlertController {
        switch result {
        case .success(let receiptData):
            return alertWithTitle(title: "Receipt Refreshed", message: "Receipt refreshed successfully")
        case .error(let error):
            return alertWithTitle(title: "Receipt Refresh Failed", message: "")
        }
    }
}
