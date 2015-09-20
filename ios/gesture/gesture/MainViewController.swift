//
//  MainViewController.swift
//  gesture
//
//  Created by Maksym Pikhteryev on 2015-09-19.
//  Copyright (c) 2015 seapig. All rights reserved.
//

import UIKit

import AudioToolbox


class MainViewController: UIViewController, FBSDKLoginButtonDelegate, PebbleHelperDelegate, PBDataLoggingServiceDelegate {
    
    @IBOutlet var fbLoginView : FBSDKLoginButton!
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet var fbLinkButton: UIButton!;
    
    var globalHandshakeUserId = ""
    
    let cloudAPI: CloudAPI = CloudAPI();    
    
    func setProfilePicFromFbId(fbId: String) {
        let urlString = "https://graph.facebook.com/v2.3/\(fbId)/picture?type=large&redirect=true&width=250&height=250" as String
        let imgUrl = NSURL(string: urlString)
        
        let request: NSURLRequest = NSURLRequest(URL: imgUrl!)
        let mainQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
            if error == nil {
                // Convert the downloaded data in to a UIImage object
                let image = UIImage(data: data)

                dispatch_async(dispatch_get_main_queue(), {
                    self.profilePic.image = image;
                })
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        });
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            // User is already logged in
        } else {
            fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        }
        
        var pebbleHelper = PebbleHelper.instance
        pebbleHelper.delegate = self
        pebbleHelper.UUID = "dde5b4f3-de18-42b0-8d10-6a635a31b7bd"
        
        // rounded corners
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2;
        profilePic.clipsToBounds = true;
        
        PBPebbleCentral.defaultCentral().dataLoggingService.delegate = self;

        func completionHandler(result: AnyObject) {
            
            let now = NSDate()
            
            let data = result as! NSDictionary
            // keys include: userId, timestamp
            
            let cloudHandshake = data["timestamp"] as! NSTimeInterval
            
            if (now.timeIntervalSinceReferenceDate - cloudHandshake < 15) {
                // pretty recent, so probbaly shaking hands
                
                let cloudUserId = data["userId"] as! String
                if (cloudUserId != FBSDKAccessToken.currentAccessToken().userID) {
                    // make sure not to shake your own hand
                    println("oooh a handshake!")
                    
                    setProfilePicFromFbId(cloudUserId)
                    
                    //display the deets of the person
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    
                    globalHandshakeUserId = cloudUserId
//                    fbLinkButton.superview!.bringSubviewToFront(fbLinkButton)
                } else {
                    globalHandshakeUserId = cloudUserId
                    setProfilePicFromFbId(cloudUserId)
                    println("handshake with yourself!")
//                    fbLinkButton.superview!.bringSubviewToFront(fbLinkButton)
                }
            }
            
//            println("result: \(result)")
//            println(data["userId"])
            
        }
        
        cloudAPI.startListeningToHandshakes(completionHandler)
        
    }

    @IBAction func fbLinkButtonPressed(sender: AnyObject) {
        
        println("fbLinkButton pressed \(globalHandshakeUserId)")
        
        if (globalHandshakeUserId != "") {
            let appUrl = NSURL(string: "fb://profile?app_scoped_user_id=\(globalHandshakeUserId)")!
            
            
            if UIApplication.sharedApplication().canOpenURL(appUrl) {
                UIApplication.sharedApplication().openURL(appUrl)
            } else {
                UIApplication.sharedApplication().openURL(NSURL(string: "https://www.facebook.com/app_scoped_user_id/\(globalHandshakeUserId)")!)
            }
        }
    }
    
    
    // pebble delegate methods
    
    func pebbleHelper(pebbleHelper: PebbleHelper, receivedMessage: Dictionary<NSObject, AnyObject>) {
//        println(receivedMessage[0]!)
        
        dataAnalyzer(parseMessage(receivedMessage[0]! as! String))
    }
    
    func parseMessage(input: String) -> AccelDataPoint {
        // inputs our accel format, outputs struct
        
        var splitArray = split(input) {$0 == ","}
        
        if (splitArray.count == 3 &&
            splitArray[0].toInt() != nil &&
            splitArray[1].toInt() != nil &&
            splitArray[2].toInt() != nil) {
            
            let xValue = splitArray[0].toInt()
            let yValue = splitArray[1].toInt()
            let zValue = splitArray[2].toInt()
            
            return AccelDataPoint(x: xValue!, y : yValue!, z : zValue!, didVibrate: false, timestamp: NSDate().timeIntervalSinceReferenceDate)
 
        } else {
            return AccelDataPoint(x: 0, y : 0, z : 0, didVibrate: false, timestamp: NSDate().timeIntervalSinceReferenceDate)
        }
    }
    
    var lastHandshakePeak: NSTimeInterval = 0.0;
    
    func dataAnalyzer(accelDataPoint: AccelDataPoint) {
        //
        let now = NSDate()
        
//        println("time since shake: \(now.timeIntervalSinceReferenceDate - lastHandshakePeak)")
        
        if (accelDataPoint.y < 0) {
            
            // if this is the first handshake in a while, send update to server
            if (now.timeIntervalSinceReferenceDate - lastHandshakePeak > 10) {
                // if a handshake has not occured for more than 10 seconds, we can do a new one
                
                println("sending handshake")

                //send update to server
                cloudAPI.sendHandshakeToServer(FBSDKAccessToken.currentAccessToken().userID, timestamp: accelDataPoint.timestamp)
                
                // if new peak detected, reset the reference peak
                lastHandshakePeak = now.timeIntervalSinceReferenceDate

                
            } else {
                // do nothing otherwise
                println("not enough time elapsed")
            }
            
        }
        
        
        
        
    }
    
    
//    func parseAccelData(data: String) -> AccelDataPoint {
//        
//    }
    
//    func parseAccelData(data: NSData) -> AccelDataPoint {
//        
//        var range = NSRange(location: 0,length: 0)
//        
//        // x accelerometer
//        range.location += range.length;
//        range.length = 2;
//        var xBytes = data.subdataWithRange(range)
//        var x = Int16()
//        xBytes.getBytes(&x, length: 2)
//        x = Int16(bigEndian: x)
//
//        // y accelerometer
//        range.location += range.length;
//        range.length = 2;
//        var yBytes = data.subdataWithRange(range)
//        var y = Int16()
//        yBytes.getBytes(&y, length: 2)
//        y = Int16(bigEndian: y)
//        
//        // z accelerometer
//        range.location += range.length;
//        range.length = 2;
//        var zBytes = data.subdataWithRange(range)
//        var z = Int16()
//        xBytes.getBytes(&z, length: 2)
//        z = Int16(bigEndian: z)
//        
//        // whether pebble vibrated
//        range.location += range.length;
//        range.length = 1;
//        var vibBytes = data.subdataWithRange(range)
//        var didVibrate = Int16()
//        vibBytes.getBytes(&didVibrate, length: 1)
//        didVibrate = Int16(bigEndian: didVibrate)
//        
//        // timestamp
//        range.location += range.length;
//        range.length = 8;
//        var timestampBytes = data.subdataWithRange(range)
//        var timestamp = UInt64()
//        timestampBytes.getBytes(&timestamp, length: 2)
//        timestamp = UInt64(bigEndian: timestamp)
//        
//        return AccelDataPoint(x: x, y: y, z: z, didVibrate: didVibrate, timestamp: timestamp)
//    }
    
//    func dataLoggingService(service: PBDataLoggingService!, hasByteArrays bytes: UnsafePointer<UInt8>, numberOfItems: UInt16, forDataLoggingSession session: PBDataLoggingSessionMetadata!) -> Bool {
//        
//        let numItems = Int(numberOfItems)
//        
////        let data = NSData(bytes: bytes, length: 15)
//        
//        var pointer = bytes
//        
//        if (numItems < 1) {
//            println("wtf less than 1?!")
//            return true
//        }
//        
//        for i in 0...numItems-1 {
////            println("entry \(bytes.memory.value)")
//            
//            if(bytes.memory == 0x0000000000000000) {
//                continue
//            }
//            
//            let data = NSData(bytes: bytes, length: 12)
//            //        let str = NSString(data: data, encoding: NSUTF8StringEncoding)
//            
//            var output = [UInt8](count: 15, repeatedValue: 0)
//            data.getBytes(&output, length: 15)
//            
//            println("string: \(output)")
//
//            pointer = bytes.successor()
//            
////            var accelDataPoint = parseAccelData(data: bytes)
//        }
////
////        
////        println("data \(bytes)")
//
//        
////        println("num: \(numberOfItems)")
////        println("data: \(bytes)")
//        
//        return true;
//    }
//    
//    
//    func dataLoggingService(service: PBDataLoggingService!, sessionDidFinish session: PBDataLoggingSessionMetadata!) {
//        
////        println("finished data logging");
//        
//    }
    
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
    
        println("User Logged In")
        
        if ((error) != nil) {
            
            // Process error
        } else if result.isCancelled {
            // Handle cancellations
            
            // do nothing, user will still have to login
        
        } else {
        
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    println("User Logged Out")
    
        // stops user from navigating away after logging out
        //self.navigationController?.setNavigationBarHidden(true, animated: true);
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    

}
