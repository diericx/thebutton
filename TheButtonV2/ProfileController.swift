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
    
    var selectedEmoji = ""
    
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
        //set it to clear background
        self.emojiCollectionView.backgroundColor = UIColor.clear;
        self.emojiCollectionView.backgroundView?.backgroundColor = UIColor.clear;
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
        //get cell
        let cell = emojiCollectionView.dequeueReusableCell(withReuseIdentifier: "emoji_collection_cell", for: indexPath) as! EmojiCollectionViewCell
        //edit button
        cell.emojiButton.setTitle(Emoji.emojis[indexPath.row], for: .normal)
        cell.emojiButton.alpha = 0.5;
        if Emoji.doIOwn(emojiInput: Emoji.emojis[indexPath.row]) {
            cell.emojiButton.alpha = 1;
        }
        cell.emojiButton.tag = indexPath.row
        //edit amount text
        let count = Emoji.howManyDoIOwn(emojiInput: Emoji.emojis[indexPath.row])
        if count == 0 {
            cell.amountText.text = ""
        } else {
            cell.amountText.text = "x" + String(count)
        }
        cell.emojiButton.addTarget(self, action: "emojiButtonUp:", for: .touchUpInside)

        return cell
    }
    
    func emojiButtonUp(_ sender: AnyObject?) {
        var emoji = Emoji.emojis[(sender?.tag)!]
        if Emoji.doIOwn(emojiInput: emoji) {
            selectedEmoji = Emoji.emojis[(sender?.tag)!]
        } else {
            selectedEmoji = "";
        }
    }
    
    @IBAction func slotUpInside(_ sender: UIButton!) {
        if selectedEmoji != "" {
            sender.setTitle(selectedEmoji, for: .normal)
        }
        
    }
    
    @IBAction func onSaveButtonPress(_ sender: Any) {
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}






