//
//  WinScreenController.swift
//  TheButtonV2
//
//  Created by Zac Holland on 6/3/17.
//  Copyright © 2017 Diericx. All rights reserved.
//

import Foundation
import PubNub
import AVFoundation
import Gzip
import CloudKit

class WinScreenController: UIViewController, PNObjectEventListener, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var potAmountLabel: UILabel!
    @IBOutlet weak var maskTarget: UIImageView!
    @IBOutlet weak var photoDisplayView: UIView!
    
    var countDown = 4;
    
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var timer = Timer()
    let maskView = UIImageView()
    
    var potCountUpTimer: Timer!
    var potCountUpTimerWaitTime = 0.3
    var currentPotCount = 0
    
    var delegate:GameController?
    
    //Making sure we are always subscribed when a user tabs out
    private var notification: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If you arent the winner, start counting up the pot amount
        if (!GameController.winner) {
            //start pot timer
            potCountUpTimer = Timer.scheduledTimer(timeInterval: potCountUpTimerWaitTime, target: self, selector: #selector(potCountUp), userInfo: nil, repeats: true)
        }

        //set up pubnub for this scene
        PubnubHandler.addListener(listener: self)
        
        //add listener when we tab out
        notification = NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) {
            [unowned self] notification in
            //PubnubHandler.addListener(listener: self)
        }
        
        //show or hide labels and camera view depending on if you are winner
        if GameController.winner {
            winnerLabel.isHidden = true
            potAmountLabel.isHidden = true
        } else {
            cameraView.isHidden = true
        }
        
        //Display who won
        winnerLabel.text = GameController.winnerName + " Won!";
        
        //add mask for capturing image
        self.maskView.image = UIImage(named: "mask")
        self.imageView.mask = self.maskView
        
        //rotate winner image to account 
        imageView.transform = imageView.transform.rotated(by: CGFloat(Double.pi/4))
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        maskView.frame = maskTarget.bounds
    }
    
    //remove status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func potCountUp() {
        potCountUpTimer.invalidate()
        if (currentPotCount >= GameController.gs.pot) {
            return
        }
        currentPotCount += 1
        potAmountLabel.text = "$" + String(currentPotCount)
        potCountUpTimerWaitTime *= 0.8
        potCountUpTimer = Timer.scheduledTimer(timeInterval: potCountUpTimerWaitTime, target: self, selector: #selector(potCountUp), userInfo: nil, repeats: false)
        
    }
    
    func capturePhoto() {
        
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        self.sessionOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
    func resizeImage(image: UIImage, scale: CGFloat) -> UIImage {
        let size = image.size
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            print(dataImage.count)

            //update image on main thread
            DispatchQueue.main.async {
                // Update UI
                let img: UIImage = UIImage(data: dataImage)!
                let flippedImage = UIImage(cgImage: img.cgImage!, scale: img.scale, orientation: .leftMirrored)
                self.imageView.image = flippedImage;
                
                //rotate image
                var angle =  CGFloat(-Double.pi/4)
                var tr = CGAffineTransform.identity.rotated(by: angle)
                self.imageView.transform = tr
                
                //capture image
                UIGraphicsBeginImageContext(self.photoDisplayView.frame.size)
                self.photoDisplayView.layer.render(in: UIGraphicsGetCurrentContext()!)
                let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                var uncompressedData = UIImagePNGRepresentation(croppedImage!)
                let compressedData = croppedImage?.jpeg(.low)
                
                self.imageView.image = croppedImage
                
                //undo rotation image
                angle =  CGFloat(Double.pi/4)
                tr = CGAffineTransform.identity.rotated(by: angle)
                self.imageView.transform = tr
                
//                var croppedData = UIImagePNGRepresentation(croppedImage!)
//                let croppedImage: UIImage = UIImage(data: croppedData!, scale: CGFloat(1))!
//                let compressedData = img.jpeg(.lowest)
//                print("compressed size: " + String(compressedData!.count) )
                
                
                CKHandler.UpdateWinImg(data: uncompressedData!, onComplete: { (record) in
                    PubnubHandler.sendMessage(packet: "{\"action\": \"image\", \"recordName\":\"" + record.recordID.recordName + "\"}")
                })
                
                GameController.winnerImg = self.imageView.image
            }

            
            
            
//            //create record for image
//            let newRecord:CKRecord = CKRecord(recordType: "Image")
//            newRecord.setValue(compressedData, forKey: "Image")
//            
//            let modifyRecordsOperation = CKModifyRecordsOperation(
//                recordsToSave: [newRecord],
//                recordIDsToDelete: nil)
//            
//            modifyRecordsOperation.timeoutIntervalForRequest = 10
//            modifyRecordsOperation.timeoutIntervalForResource = 10
//            
//            CKHandler.publicDB.save(newRecord) { (record, error) -> Void in
//                guard let record = record else {
//                    print("Error saving record: ", error)
//                    return
//                }
////                print("Successfully saved record: ", record)
//                PubnubHandler.sendMessage(packet: "{\"action\": \"image\", \"recordName\":\"" + record.recordID.recordName + "\"}")
//            }
            
            cameraView.isHidden = true
        }
        
    }
    
    func updateCountDown() {
        countDown -= 1;
        self.countDownLabel.text = String(countDown);
        if (countDown == 0) {
            
            if GameController.winner {
                //capture photo
                let settings = AVCapturePhotoSettings()
                let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
                let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                     kCVPixelBufferWidthKey as String: 160,
                                     kCVPixelBufferHeightKey as String: 160,
                                     ]
                settings.previewPhotoFormat = previewFormat
                self.sessionOutput.capturePhoto(with: settings, delegate: self)
                
                //reset variables
                GameController.winner = false
                winnerLabel.isHidden = false
                potAmountLabel.isHidden = false
                maskTarget.isHidden = true
                countDown = 10
                self.countDownLabel.text = String(countDown);
                
                //start pot timer
                potCountUpTimer = Timer.scheduledTimer(timeInterval: potCountUpTimerWaitTime, target: self, selector: #selector(potCountUp), userInfo: nil, repeats: true)
            } else {
                timer.invalidate()
              
                GameController.gs.resetGameState()
                guard let d = self.delegate else {
                    return
                }
                d.resetGameToMatchState()
                
                dismiss(animated: true, completion: {
                    print("Modal dismiss completed")
//                    GameController.gs = GameState()
//                    self.delegate?.resetGameToMatchState()
                })
                
            }

        }
        
    }
    
    // Handle new message from one of channels on which client has been subscribed.
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        //parse message
        let dictionary: AnyObject = message.data.message as AnyObject;
        let action: String = dictionary["action"] as! String;
        if (action == "image") {
            let recordName: String = dictionary["recordName"] as! String
            
            var recordID: CKRecordID = CKRecordID(recordName: recordName)
            CKHandler.GetRecordById(
                recordID: recordID,
                onComplete: { (record: CKRecord) in
                    var data: Data = record["Image"] as! Data;
                    //print(data.count)
                    
                    // Update UI on main thread
                    DispatchQueue.main.async {
                        let img: UIImage = UIImage(data: data)!
//                        let flippedImage = UIImage(cgImage: img.cgImage!, scale: img.scale, orientation: .leftMirrored)
                        
                        //Mask image
                        self.imageView.image = img;
                        
                        GameController.winnerImg = self.imageView.image
                    }
                }
            )
        } else if (action == "button-image") {
            let recordName: String = dictionary["recordName"] as! String;
            CKHandler.GetLatestWinnerButton(
                recordName: recordName,
                onComplete: { (record: CKRecord) in
//                    let data: Data = record["Image"] as! Data;
//                    GameController.winnerImg = UIImage(data: data)
                }
            )
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        self.countDown = 15
        self.countDownLabel.text = String(countDown);
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCountDown), userInfo: nil, repeats: true)
            
        if GameController.winner {
            self.countDown = 4
            
            let deviceSession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInDuoCamera,.builtInTelephotoCamera,.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified)
            
            for device in (deviceSession?.devices)! {
                if device.position == AVCaptureDevicePosition.front {
                    do {
                        let input = try AVCaptureDeviceInput(device: device)
                        
                        if captureSession.canAddInput(input) {
                            captureSession.addInput(input);
                            
                            if captureSession.canAddOutput(sessionOutput) {
                                captureSession.addOutput(sessionOutput)
                                
                                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                                previewLayer.connection.videoOrientation = .portrait
                                
                                cameraView.layer.addSublayer(previewLayer)
                                //cameraView.addSubview(button)
                                
                                previewLayer.position = CGPoint(x: self.cameraView.frame.width/2, y: self.cameraView.frame.height/2)
                                previewLayer.bounds = cameraView.frame
                                
                                captureSession.startRunning()
                            }
                        }
                        
                    } catch let avError {
                        print(avError);
                    } 
                }
                
            }
        }
        
    }

}
