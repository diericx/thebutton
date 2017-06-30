//
//  ShopController.swift
//  TheButtonV2
//
//  Created by Zac Holland on 6/21/17.
//  Copyright © 2017 Diericx. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class GoldShopController: UIViewController {
    
    @IBOutlet weak var nameSizeProgressImageView: UIImageView!
    @IBOutlet weak var nameSpeedProgressImageView: UIImageView!
    @IBOutlet weak var nameSizeCostLabel: UILabel!
    @IBOutlet weak var nameSpeedCostLabel: UILabel!
    @IBOutlet weak var nameChangeButton: UIButton!
    @IBOutlet weak var nameSizeButton: UIButton!
    @IBOutlet weak var nameSpeedButton: UIButton!
    
    var nameSizeCosts: [Int] = [1000, 10000, 100000, 500000, 1000000, 2000000, 5000000, 10000000, 100000000, 200000000, 0]
    var nameSpeedCosts: [Int] = [1000, 10000, 100000, 500000, 1000000, 2000000, 5000000, 10000000, 100000000, 200000000, 0]
    var nameChangeCost = 1000000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateNameSizeView()
        updateNameSpeedView()
        updateNameChangeView()
        
    }
    
    func updateNameSizeView() {
        let status = LocalDataHandler.getNameSizeUpgradeStatus()!
        let strImageName : String = "frame\(status+1).png"
        let image  = UIImage(named:strImageName)
        self.nameSizeProgressImageView.image = image
        var cost = String(nameSizeCosts[status])
        if (cost == "0") {
            cost = "Complete!"
            self.nameSizeButton.isEnabled = false
        }
        self.nameSizeCostLabel.text = cost
        
    }
    
    func updateNameSpeedView() {
        let status = LocalDataHandler.getNameSpeedUpgradeStatus()!
        let strImageName = "frame\(status+1).png"
        let image  = UIImage(named:strImageName)
        self.nameSpeedProgressImageView.image = image
        var cost = String(nameSpeedCosts[status])
        if (cost == "0") {
            cost = "Complete!"
            self.nameSpeedButton.isEnabled = false
        }
        self.nameSpeedCostLabel.text = cost
    }
    
    func updateNameChangeView() {
        let status = LocalDataHandler.getNameChangeStatus()!
        if (status == true) {
            nameChangeButton.isEnabled = false;
        } else {
            nameChangeButton.isEnabled = true;
        }
    }
    
    @IBAction func nameChangeButtonTap(_ sender: Any) {
        let coins = LocalDataHandler.getCoins()
        if (coins >= nameChangeCost) {
            //purchase item
            LocalDataHandler.setCoins(coins: coins - nameChangeCost)
            LocalDataHandler.setNameChangeStatus(status: true)
            updateNameChangeView()
        }
    }
    
    @IBAction func nameSizeButtonTap(_ sender: Any) {
        let status = LocalDataHandler.getNameSizeUpgradeStatus()!
        print(status)
        let nextUpgradeCost = nameSizeCosts[status]
        let coins = LocalDataHandler.getCoins()
        if (coins >= nextUpgradeCost) {
            LocalDataHandler.setCoins(coins: coins - nextUpgradeCost)
            LocalDataHandler.setNameSizeUpgradeStatus(status: status + 1)
            updateNameSizeView()
            //TODO: Disable Button when at max
        }
    }
    
    @IBAction func nameSpeedButtonTap(_ sender: Any) {
        let status = LocalDataHandler.getNameSpeedUpgradeStatus()!
        let nextUpgradeCost = nameSpeedCosts[status]
        let coins = LocalDataHandler.getCoins()
        if (coins >= nextUpgradeCost) {
            LocalDataHandler.setCoins(coins: coins - nextUpgradeCost)
            LocalDataHandler.setNameSpeedUpgradeStatus(status: status + 1)
            updateNameSpeedView()
            //TODO: Disable Button when at max
        }
    }
    //remove status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
