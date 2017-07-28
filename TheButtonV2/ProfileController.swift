//
//  ProfileController.swift
//  TheButtonV2
//
//  Created by Zac Holland on 7/20/17.
//  Copyright © 2017 Diericx. All rights reserved.
//


import UIKit
import Foundation
import AVFoundation

class ProfileController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var totalTapsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        
        //set username text field if it isnt nil
        if (LocalDataHandler.getUsername() != nil) {
            usernameTextField.text = LocalDataHandler.getUsername()!
        }
        
        totalTapsLabel.text = String(LocalDataHandler.getTaps())
        
        updateUsernameChangeView()
        
    }
    
    func updateUsernameChangeView() {
        if (LocalDataHandler.getNameChangeStatus()! == false && LocalDataHandler.getUsername() != nil) {
            usernameTextField.isEnabled = false;
        }
    }
    
    @IBAction func backButtonTapInside(_ sender: Any) {
        if (usernameTextField.text != "") {
            //change name
            if (LocalDataHandler.getNameChangeStatus()! == true || LocalDataHandler.getUsername() == nil) {
                LocalDataHandler.setUsername(username: usernameTextField.text!)
                LocalDataHandler.setNameChangeStatus(status: false)
            }
            dismiss(animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Oh no!", message: "Your username can't be blank.", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "Okay", style: .default) { (action:UIAlertAction!) in
                //Call another alert here
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion:nil)
            dismiss(animated: true, completion: nil)
        }
    }
    
    //remove status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
