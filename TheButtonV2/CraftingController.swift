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
    
    @IBOutlet weak var craftedEmojiLabel: UILabel!
    @IBOutlet weak var successRaysImage: UIImageView!
    @IBOutlet weak var emojiCollectionView: UICollectionView!
    @IBOutlet var slots: [UIButton]?
    var selectedEmoji = ""
    var slot1 = ""
    var slot2 = ""
    var slot3 = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make sure emoji collection view's controller is this view.
        //Functions implemented below
        self.emojiCollectionView.delegate = self
        self.emojiCollectionView.dataSource = self
        //set it to clear background
        self.emojiCollectionView.backgroundColor = UIColor.clear;
        self.emojiCollectionView.backgroundView?.backgroundColor = UIColor.clear;
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UIView.animate(withDuration: 1.5, delay: 0, options: [.repeat, .curveLinear], animations: {
            self.successRaysImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        })  { (finished) in
            UIView.animate(withDuration: 1.5, delay: 0, options: [.curveLinear], animations: {
                self.successRaysImage.transform = CGAffineTransform(rotationAngle: CGFloat(2*Double.pi))
            })  { (finished) in
                
            }
        }
        
    }
    
    //remove status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touch = touches.first
        let location = touch?.location(in: emojiCollectionView)
        print(location)
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
        
//        GESTURE
        cell.isUserInteractionEnabled = true
        
        cell.emojiButton.addTarget(self, action: "emojiButtonUp:", for: .touchUpInside)
//        cell.emojiButton.addTarget(self, action: "emojiButtonDrag:", for: .touchDragEnter)

        return cell
    }
    
    func emojiButtonDrag(_ sender: AnyObject?) {
        
    }
    
    func emojiButtonUp(_ sender: AnyObject?) {
        print("emoji Button up inside..")
        var emoji = Emoji.emojis[(sender?.tag)!]
        //if Emoji.doIOwn(emojiInput: emoji) {
            selectedEmoji = Emoji.emojis[(sender?.tag)!]
        //} else {
        //    selectedEmoji = "";
        //}
    }
    
    @IBAction func slotUpInside(_ sender: UIButton!) {
        print("Slot up inside..")
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
        var recipe = [String: Int]()
        
        //initialize each recipe slot
        recipe[slot1] = 0
        recipe[slot2] = 0
        recipe[slot3] = 0
        
        recipe[slot1] = recipe[slot1]! + 1
        recipe[slot2] = recipe[slot2]! + 1
        recipe[slot3] = recipe[slot3]! + 1
                
        guard let recipeResult = Emoji.isRecipeValid(recipeInput: recipe) else {
            return
        }
        
        //Show animation
        successRaysImage.isHidden = false
        craftedEmojiLabel.text = recipeResult
        
//        //TODO - change inventory items
        Emoji.addToMyInventory(emojiInput: recipeResult)
//        Emoji.removeFromMyInventory(emojiInput: Emoji.emojis[recipe[slot1]!] )
//        Emoji.removeFromMyInventory(emojiInput: Emoji.emojis[recipe[slot2]!] )
//        Emoji.removeFromMyInventory(emojiInput: Emoji.emojis[recipe[slot3]!] )
//        
//        for slot in slots! {
//            slot.setTitle("", for: .normal)
//        }
//        
//        //TODO: Change 5 to emoji index and update all affected emoji
        let s1Index = Emoji.getIndexForEmoji(emoji: slot1)
        let s2Index = Emoji.getIndexForEmoji(emoji: slot2)
        let s3Index = Emoji.getIndexForEmoji(emoji: slot3)
        let resultIndex = Emoji.getIndexForEmoji(emoji: recipeResult)
        
        self.emojiCollectionView!.reloadItems(at: [
            IndexPath(row: s1Index, section: 0),
            IndexPath(row: s2Index, section: 0),
            IndexPath(row: s3Index, section: 0),
            IndexPath(row: resultIndex, section: 0)
            ])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}






