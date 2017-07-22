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

class CraftingController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var emojiCollectionView: UICollectionView!
    @IBOutlet var slots: [UIButton]?
    var selectedEmoji = ""
    var slot1 = ""
    var slot2 = ""
    var slot3 = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        createEmojiButtons()
        
        print("Recipe: \(Emoji.isRecipeValid(recipe: ["👮🏾‍♀️": 1, "👱🏼‍♀️": 1, "👱🏼": 1]))")
        
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
            if (sender.tag == 0) {
                slot1 = selectedEmoji
            } else if (sender.tag == 1) {
                slot2 = selectedEmoji
            } else if (sender.tag == 2) {
                slot3 = selectedEmoji
            }
        }
        
    }
    
    @IBAction func onSaveButtonPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func craftButtonUpInside(_ sender: Any) {
        var recipe = [slot1: 1, slot2: 1, slot3: 1]
        guard let recipeResult = Emoji.isRecipeValid(recipe: recipe) else {
            return
        }
        Emoji.addToMyInventory(emojiInput: recipeResult)
        for slot in slots! {
            slot.setTitle("", for: .normal)
        }
        //TODO: Change 5 to emoji index
        var i = IndexPath(row: 5, section: 0)
        self.emojiCollectionView!.reloadItems(at: [i])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}






