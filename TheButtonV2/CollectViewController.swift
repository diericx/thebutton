//
//  CollectViewController.swift
//  TheButtonV2
//
//  Created by Zac Holland on 6/23/17.
//  Copyright © 2017 Diericx. All rights reserved.
//

import Foundation
import UIKit

class CollectViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onDismissBtnClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //remove status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
