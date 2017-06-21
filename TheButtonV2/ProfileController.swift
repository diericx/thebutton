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

class ProfileController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonMaskImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    
    var lastPoint = CGPoint.zero
    var swiped = false
    var dgs = [DrawGesture]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
    }
    
    //remove status bar
    override var prefersStatusBarHidden: Bool {
        return true
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
        UIGraphicsBeginImageContext(self.view.frame.size)
        
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        
        var context = UIGraphicsGetCurrentContext()
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y) )
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y) )
        
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(5)
        context?.setStrokeColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor)
        
        context?.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
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
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        
        if let touch = touches.first {
            
            var currentPoint = touch.location(in: self.view)
            
            if (isValidDrawTouch(p: currentPoint)) {
                currentPoint = touch.location(in: self.view)
                drawLines(fromPoint: lastPoint, toPoint: currentPoint)
//                    var dg = DrawGesture(sp: lastPoint, ep: currentPoint, c: UIGraphicsGetCurrentContext()?.colorSpace as! CGColor)
//                    dgs.append(dg)
                lastPoint = currentPoint
            }
            
            
        }
    }
    
    @IBAction func onSaveButtonPress(_ sender: Any) {
        LocalDataHandler.setUsername(username: usernameTextField.text!)
        performSegue(withIdentifier: "ShowGameScreen", sender: self)
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


struct DrawGesture {
    var startPoint: CGPoint
    var endPoint: CGPoint
    var color: CGColor
    
    init(sp: CGPoint, ep: CGPoint, c: CGColor) {
        startPoint = sp
        endPoint = ep
        color = c
    }
}






