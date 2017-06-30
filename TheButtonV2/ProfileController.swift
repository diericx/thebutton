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

class ProfileController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonMaskImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var testImageView: UIImageView!
    @IBOutlet weak var previousDrawingImageView: UIImageView!
    
    var lastPoint = CGPoint.zero
    var swiped = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var erasing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        
        //set username text field if it isnt nil
        if (LocalDataHandler.getUsername() != nil) {
            usernameTextField.text = LocalDataHandler.getUsername()!
        }
        
        updateUsernameChangeView()
        
        //TODO - remove this
        if let image = LocalDataHandler.getButtonImg() {
            testImageView.image = UIImage(data:image)
            previousDrawingImageView.image = testImageView.image
        }
        
        UIGraphicsBeginImageContext(self.view.frame.size)

    }
    
    //remove status bar
    override var prefersStatusBarHidden: Bool {
        return true
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
        if let touch = touches.first {
            var location = touch.location(in: self.view)
            if (isValidDrawTouch(p: location)) {
                lastPoint = location
            }
            
        }
    }
    
    func drawLines(fromPoint:CGPoint, toPoint: CGPoint) {
        let color = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        
        
        
        if (!erasing) { //drawing
            
            imageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            
            let context = UIGraphicsGetCurrentContext()
            
            context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y) )
            context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y) )
            
            context?.setBlendMode(CGBlendMode.normal)
            context?.setLineCap(CGLineCap.round)
            context?.setLineWidth(5)
            context?.setStrokeColor(color.cgColor)
            
            context?.strokePath()
            
            
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        } else { //erasing
//            let context = UIGraphicsGetCurrentContext()
//            context!.beginTransparencyLayer(auxiliaryInfo: nil)
//            imageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
//            
//            context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y) )
//            context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y) )
//            context?.setBlendMode(CGBlendMode.clear)
//            context?.setLineCap(CGLineCap.round)
//            context?.setLineWidth(5)
//            context?.setStrokeColor(UIColor.clear.cgColor)
//            context?.strokePath()
//            
//            context!.endTransparencyLayer()
        }
        
        
//        context!.beginTransparencyLayer(auxiliaryInfo: nil);
        

//        UIGraphicsEndImageContext()
    }
    
    func dist(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat {
        return ((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)).squareRoot()
    }
    
    func isValidDrawTouch(p: CGPoint) -> Bool {
        let widthInPoints = buttonMaskImageView.image?.size.width
        let widthInPixels = widthInPoints! * (buttonMaskImageView.image?.scale)!
        
        let c = buttonMaskImageView.center
        if (dist(x1: c.x, y1: c.y, x2: p.x, y2: p.y) < 146) {
            return true
        }
        
        return false
    }
    
    func returnToGameScreen() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        
        if let touch = touches.first {
            
            var currentPoint = touch.location(in: self.view)
            
            if (isValidDrawTouch(p: currentPoint)) {
                currentPoint = touch.location(in: self.view)
                drawLines(fromPoint: lastPoint, toPoint: currentPoint)
                lastPoint = currentPoint
            }
            
            
        }
    }
    
    @IBAction func EraseButtonUpInside(_ sender: Any) {
        self.erasing = !self.erasing
    }
    
    @IBAction func onSaveButtonPress(_ sender: Any) {
        if (usernameTextField.text != "") {
            //change name
            if (LocalDataHandler.getNameChangeStatus()! == true || LocalDataHandler.getUsername() == nil) {
                print("Saving username!")
                LocalDataHandler.setUsername(username: usernameTextField.text!)
                LocalDataHandler.setNameChangeStatus(status: false)
            }
            
            let image = imageView.snapshot(of: buttonMaskImageView.frame)
            //save button image
            if image != nil {
                // do something with image here
                LocalDataHandler.setButtonImg(status: UIImagePNGRepresentation(image!)!)
                print("Saved image locally.")
            } else {
                //TODO - display error saving image
                print("***Error saving image locally!***")
                return
            }
            
            //save drawing strokes
            
            let imageData = LocalDataHandler.getButtonImg()!
            
            //update button image
            if let recordName = LocalDataHandler.getButtonImgId() {
                let recordId: CKRecordID = CKRecordID(recordName: recordName)
                
                //update current record with new image
                CKHandler.UpdateRecordWithRecordID(
                    recordID: recordId,
                    key: "Image",
                    value: (imageData as? CKRecordValue)!,
                    onComplete: returnToGameScreen,
                    onFetchError: {(error: Error) in
                        print("Encountered error. Uploading as new record...")
                        //if there is an error, upload it as a new record
                        let newRecord:CKRecord = CKRecord(recordType: "ButtonImage")
                        newRecord.setValue(imageData, forKey: "Image")
                        
                        CKHandler.UploadNewRecord(
                            record: newRecord,
                            onComplete: { (record: CKRecord) in
                                print("Successfully saved record!")
                                LocalDataHandler.setButtonImgId(id: record.recordID.recordName)
                                self.dismiss(animated: true, completion: nil)
                            },
                            onUploadError: { (error: Error) in
                                //TODO - Show pop up saying we couldnt upload image for some reason
                            }
                        );
                    },
                    onUpdateError: {(error: Error) in
                        //TODO - Show pop up saying we couldnt upload image for some reason
                    }
                )
            } else {
                //upload new button image and save id
                //create record for image
                let newRecord:CKRecord = CKRecord(recordType: "ButtonImage")
                newRecord.setValue(imageData, forKey: "Image")
                
                CKHandler.UploadNewRecord(
                    record: newRecord,
                    onComplete: { (record: CKRecord) in
                        print("Successfully saved record!")
                        LocalDataHandler.setButtonImgId(id: record.recordID.recordName)
                        self.dismiss(animated: true, completion: nil)
                    },
                    onUploadError: { (error: Error) in
                        //TODO - Show pop up saying we couldnt upload image for some reason
                    }
                );
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
    
    @IBAction func clearDrawingBtnPress(_ sender: Any) {
        UIGraphicsGetCurrentContext()?.restoreGState()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        
        if !swiped {
            if (isValidDrawTouch(p: lastPoint)) {
                drawLines(fromPoint: lastPoint, toPoint: lastPoint)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


class DrawGesture: NSObject, NSCoding {

    var startX: Float
    var startY: Float
    var endX: Float
    var endY: Float
    var r: Float
    var g: Float
    var b: Float
    var a: Float
    
    init(sp: CGPoint, ep: CGPoint, c: UIColor) {
        startX = Float(sp.x)
        startY = Float(sp.y)
        endX = Float(ep.x)
        endY = Float(ep.y)
        let cic = CIColor(color: c)
        r = Float(cic.red)
        g = Float(cic.green)
        b = Float(cic.blue)
        a = Float(cic.alpha)
    }
    
    init (dg: DrawGesture) {
        self.startX = dg.startX
        self.startY = dg.startY
        endX = dg.endX
        endY = dg.endY
        r = dg.r
        g = dg.g
        b = dg.b
        a = dg.a
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        
        guard let drawGesture = aDecoder.decodeObject(forKey: "drawGesture") as? DrawGesture
            else {
                return nil
        }
        self.init(dg: drawGesture)
        print(self.startX)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self, forKey: "drawGesture")
    }
}






