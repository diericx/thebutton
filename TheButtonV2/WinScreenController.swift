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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var countDownLabel: UILabel!
    var countDown = 4;
    
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var timer = Timer()
    let maskView = UIImageView()
    
    //Making sure we are always subscribed when a user tabs out
    private var notification: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.client.addListener(self)
        //also add listener when we tab out
        notification = NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) {
            [unowned self] notification in
            self.appDelegate.client.addListener(self)
        }
        
        if appDelegate.winner {
            winnerLabel.isHidden = true
        } else {
            cameraView.isHidden = true
        }
        
        winnerLabel.text = appDelegate.winnerName + " Won!";
        
        self.maskView.image = UIImage(named: "mask")
        self.imageView.mask = self.maskView
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        maskView.frame = imageView.bounds
    }
    
    //remove status bar
    override var prefersStatusBarHidden: Bool {
        return true
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
            }
            
            //create record for image
            let newRecord:CKRecord = CKRecord(recordType: "Image")
            newRecord.setValue(dataImage, forKey: "Image")
            
            let modifyRecordsOperation = CKModifyRecordsOperation(
                recordsToSave: [newRecord],
                recordIDsToDelete: nil)
            
            modifyRecordsOperation.timeoutIntervalForRequest = 10
            modifyRecordsOperation.timeoutIntervalForResource = 10
            
            appDelegate.publicDB.save(newRecord) { (record, error) -> Void in
                guard let record = record else {
                    print("Error saving record: ", error)
                    return
                }
//                print("Successfully saved record: ", record)
                self.appDelegate.sendMessage(packet: "{\"action\": \"image\", \"recordName\":\"" + record.recordID.recordName + "\"}")
            }
            
            cameraView.isHidden = true
        }
        
    }
    
    func updateCountDown() {
        countDown -= 1;
        self.countDownLabel.text = String(countDown);
        if (countDown == 0) {
            
            if appDelegate.winner {
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
                appDelegate.winner = false
                winnerLabel.isHidden = false
                countDown = 10
                self.countDownLabel.text = String(countDown);
            } else {
                timer.invalidate()
                //TODO: Segue to main scene
                performSegue(withIdentifier: "ShowGameScreen", sender: self)
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
            
            var recId: CKRecordID = CKRecordID(recordName: recordName)
            appDelegate.publicDB.fetch(withRecordID: recId) { (record, error) -> Void in
                guard let record = record else {
                    print("Error fetching record: ", error)
                    return
                }
                var data: Data = record["Image"] as! Data;
                print(data.count)
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    let img: UIImage = UIImage(data: data)!
                    let flippedImage = UIImage(cgImage: img.cgImage!, scale: img.scale, orientation: .leftMirrored)
                    
                    //Mask image
                    self.imageView.image = flippedImage;
                }
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        self.countDown = 15
        self.countDownLabel.text = String(countDown);
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCountDown), userInfo: nil, repeats: true)
            
        if appDelegate.winner {
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
