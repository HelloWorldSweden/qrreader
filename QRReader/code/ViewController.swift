//
//  ViewController.swift
//  QRReader
//
//  Created by David Wolters on 5/25/17.
//  Copyright © 2017 David Wolters. All rights reserved.
//

import UIKit
import AVFoundation


enum RequestType : String
{
    case GET = "GET"
    case POST = "POST"
    case DELETE = "DELETE"
}


class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate  {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var responseView: UIView!
    
    
    var changed = false
    

    
    var captureSession      :AVCaptureSession?
    var videoPreviewLayer   :AVCaptureVideoPreviewLayer?
    
    var defaultResponseColor = UIColor(displayP3Red: 90.0/255.0, green: 152.0/255.0, blue: 1.0, alpha: 1.0)
    var successResponseColor = UIColor(displayP3Red: 0.0, green: 0.7, blue: 0.3, alpha: 1.0)
    var loggedOutResponseColor = UIColor(displayP3Red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
    
    
    var errorColor = UIColor(displayP3Red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)

    var lastReadQR = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //let captureDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do
        {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession = AVCaptureSession()
            
            captureSession?.addInput(input)
            
            let captureMetatdataOutput = AVCaptureMetadataOutput()
            
            captureSession?.addOutput(captureMetatdataOutput)
            
            captureMetatdataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetatdataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            
            view.layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.startRunning()
            
        } catch
        {
            print(error)
            return
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate Methods
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
      
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            
            if metadataObj.stringValue != nil {
                
                if (lastReadQR != metadataObj.stringValue)
                {
                    lastReadQR = metadataObj.stringValue!
                    
                    
                    
                    loginUser(metadataObj.stringValue!) { loggedIn, error in
                        self.updateView(loggedIn: loggedIn, error: error)
                    }
                    
                    
                    
                }
            }
        }
    }
    
    func updateView(loggedIn : Bool, error : String?)
    {
        print("We are alive!")
        var loggedInText = loggedIn ? "Logged in!" : "Logged out!"
        var bgColor = loggedIn ? self.successResponseColor : self.loggedOutResponseColor
        if let _ = error
        {
            bgColor = self.errorColor
            loggedInText = error!
        }
        
        DispatchQueue.main.async {
            self.videoPreviewLayer?.isHidden = true
            
            self.messageLabel.text = loggedInText
            
            self.responseView.backgroundColor = bgColor
        }
       
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.lastReadQR = ""
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.videoPreviewLayer!.isHidden = false
            
        })
    }
    
    func loginUser(_ str : String, completionHandler : @escaping (Bool, String?) -> Void)
    {
        let qrData  = str.components(separatedBy: "&")
        let cardID  = qrData[0]
        
        var active = false
        var requestError : String? = nil
        
        
        // Make a request to get the label of the current card. /
        Request.make(request: .GET, to: Constants.Trello.URLS.getLabels(cardID: cardID)) { getData in
            print("GET: \(self.stringFrom(data: getData))")
            
            do
            {
                // Get the JSON response. //
                let json = try JSONSerialization.jsonObject(with: getData, options : []) as? [[String : Any]]
                
                // Make sure that we have a name. //
                guard let name = json![0]["name"] as? String else
                {
                    requestError = ("[ERROR] Could not fetch data: \"name\" from response.")
                    return
                }
                
                // Make sure that we have an ID for the label. //
                guard let labelID = json![0]["id"] as? String else
                {
                    requestError = ("[ERROR] Could not fetch data: \"id\" from response.")
                    return
                }
                
                // Set active to if the name is active or not. //
                active = (name == "active")
                
                
                // Delete the previous label. //
                let deleteParameters = ["idLabel" : labelID, "key" : Constants.Trello.API_KEY, "token" : Constants.Trello.API_TOKEN]
                
                Request.make(request: .DELETE, to: Constants.Trello.URLS.deleteLabels(cardID: cardID, labelID: labelID), with: deleteParameters) { deleteData in
                    print("DELETE: \(self.stringFrom(data: deleteData))")
                    // Add the new label. //
                    let newLabelColor  = (active) ? "red" : "green"
                    
                    let newLabelName = (active) ? "inactive" : "active"
                    let addParameters = [ "color" : newLabelColor
                                        , "name" : newLabelName
                                        , "key" : Constants.Trello.API_KEY
                                        , "token" : Constants.Trello.API_TOKEN ]
                    Request.make(request: .POST, to: Constants.Trello.URLS.setLabel(cardID: cardID), with: addParameters) { postData in
                        print("POST: \(self.stringFrom(data: postData))")
                        print("Success!")
                        
                        self.updateView(loggedIn: !active, error: requestError)
                        

                    }
                    
                }
                
                
                
            }
            catch
            {
                requestError = ("[ERROR] Whilst casting JSON: \(error.localizedDescription)")
            }
        }
        
    }

    
    func stringFrom(data : Data) -> NSString
    {
        return NSString(data: data, encoding: String.Encoding.ascii.rawValue)!
    }

  
 


}

