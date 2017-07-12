//
//  ProfileController.swift
//  TheButtonV2
//
//  Created by Zac Holland on 6/20/17.
//  Copyright © 2017 Diericx. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import CloudKit

class ProfileController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emojiCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        
        //set username text field if it isnt nil
        if (LocalDataHandler.getUsername() != nil) {
            usernameTextField.text = LocalDataHandler.getUsername()!
        }
        
        updateUsernameChangeView()
//        createEmojiButtons()

        //make sure emoji collection view's controller is this view. 
        //Functions implemented below
        self.emojiCollectionView.delegate = self
        self.emojiCollectionView.dataSource = self
    }
    
    //remove status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func emojiButtonAction(sender: UIButton!) {
        print("Button tapped")
    }
    
    func updateUsernameChangeView() {
        if (LocalDataHandler.getNameChangeStatus()! == false && LocalDataHandler.getUsername() != nil) {
            usernameTextField.isEnabled = false;
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 10
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    func dist(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat {
        return ((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)).squareRoot()
    }
    
    
    func returnToGameScreen() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Emoji.emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = emojiCollectionView.dequeueReusableCell(withReuseIdentifier: "emoji_collection_cell", for: indexPath) as! EmojiCollectionViewCell
        cell.emojiButton.setTitle(Emoji.emojis[indexPath.row], for: .normal)
        return cell
    }
    
    @IBAction func onSaveButtonPress(_ sender: Any) {
        if (usernameTextField.text != "") {
            //change name
            if (LocalDataHandler.getNameChangeStatus()! == true || LocalDataHandler.getUsername() == nil) {
                print("Saving username!")
                LocalDataHandler.setUsername(username: usernameTextField.text!)
                LocalDataHandler.setNameChangeStatus(status: false)
            }
        } else {
            let alertController = UIAlertController(title: "Oh no!", message: "Your username can't be blank.", preferredStyle: .alert)

            let OKAction = UIAlertAction(title: "Okay", style: .default) { (action:UIAlertAction!) in
                //Call another alert here
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion:nil)

        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}






