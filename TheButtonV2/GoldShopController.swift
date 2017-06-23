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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        var strImageName : String = "frame\(LocalDataHandler.getNameSizeUpgradeStatus()!).png"
        var image  = UIImage(named:strImageName)
        self.nameSizeProgressImageView.image = image
        
        strImageName = "frame\(LocalDataHandler.getNameSpeedUpgradeStatus()!).png"
        image  = UIImage(named:strImageName)
        self.nameSpeedProgressImageView.image = image
        
    }
    
    //remove status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
