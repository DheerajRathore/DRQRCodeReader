//
//  ViewController.swift
//  QRCodeReader
//
//  Created by Dheeraj on 28/10/17.
//  Copyright © 2017 Dheeraj Rathore. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController , AVCaptureMetadataOutputObjectsDelegate {

    ///qrCodeEncodedLabel is used to display information after encoding qr/bar code.
    @IBOutlet weak var qrCodeEncodedLabel:UILabel!
    
    ///Declare AVCaptureSession object.
    var avCaptureSession:AVCaptureSession?
    
    ///Declare AVCaptureVideoPreviewLayer object.
    var avVideoPreviewLayer:AVCaptureVideoPreviewLayer?
    
    ///Declare UIView object to highlight when QRcode is scanning.
    var qrCodeIndicatorView:UIView?
    
    ///Declare AVCaptureMetadataOutput object.
    let objCaptureMetadataOutput = AVCaptureMetadataOutput()

    
    // codesAvailable contains diffrent types of codes supported by Application.
    let codesSupported = [AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.code128, AVMetadataObject.ObjectType.code39, AVMetadataObject.ObjectType.code93, AVMetadataObject.ObjectType.upce, AVMetadataObject.ObjectType.pdf417, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.aztec]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///Setup AVCaptureSession objects
        self.setUpAVCaptureSession()
        
        ///Setup preview layer and add it to view.
        self.setUpAndAddVideoPreviewLayer()
        
        ///setUpQRCodeView
        self.setUpQRIndicatorView()
    }
    
    func setUpAVCaptureSession() {
        let objCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        var error:NSError?
        let objCaptureDeviceInput: AnyObject!
        do {
            objCaptureDeviceInput = try AVCaptureDeviceInput(device: objCaptureDevice!) as AVCaptureDeviceInput
            
        } catch let error1 as NSError {
            error = error1
            objCaptureDeviceInput = nil
        }
        if (error != nil) {
            return
        }
        avCaptureSession = AVCaptureSession()
        avCaptureSession?.addInput(objCaptureDeviceInput as! AVCaptureInput)
        avCaptureSession?.addOutput(objCaptureMetadataOutput)
        objCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        objCaptureMetadataOutput.metadataObjectTypes = codesSupported //[AVMetadataObject.ObjectType.qr]
    }
    
    func setUpAndAddVideoPreviewLayer() {
        avVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession!)
        avVideoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avVideoPreviewLayer?.frame = view.layer.bounds
        self.view.layer.addSublayer(avVideoPreviewLayer!)
        avCaptureSession?.startRunning()
        self.view.bringSubview(toFront: qrCodeEncodedLabel)
    }
    
    func setUpQRIndicatorView() {
        qrCodeIndicatorView = UIView()
        qrCodeIndicatorView?.layer.borderColor = UIColor.red.cgColor
        qrCodeIndicatorView?.layer.borderWidth = 2
        self.view.addSubview(qrCodeIndicatorView!)
        self.view.bringSubview(toFront: qrCodeIndicatorView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    ///Delegate method for notifiying when QR/Bar code detected.
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection){
        
        /// If metadataObjects object cotains 0 object retrn
        if metadataObjects.count <= 0 {
            qrCodeIndicatorView?.frame = CGRect.zero
            qrCodeEncodedLabel.text = "No supported Barcode/QR code is detected"
            return
        }
        
        //fetch 0th  metadata object from the metadataObjects.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        ///Check if qrcode detect is available in codesAvailable array
        if codesSupported.contains(metadataObj.type) {
           
            let barCodeObject = avVideoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeIndicatorView?.frame = barCodeObject!.bounds
            if metadataObj.stringValue != nil {
                qrCodeEncodedLabel.text = metadataObj.stringValue
            }
        }
    }

}

