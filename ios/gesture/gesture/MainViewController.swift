//
//  MainViewController.swift
//  gesture
//
//  Created by Maksym Pikhteryev on 2015-09-19.
//  Copyright (c) 2015 seapig. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, FBSDKLoginButtonDelegate, PebbleHelperDelegate {
    
    @IBOutlet var statusLabel: UILabel!;
    
    @IBOutlet var fbLoginView : FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabel.text = ConnectionAPI.status;
        
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            // User is already logged in
        } else {
            fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        }
        
        
        let pebbleHelper = PebbleHelper.instance
        pebbleHelper.delegate = self
        pebbleHelper.UUID = "dde5b4f3-de18-42b0-8d10-6a635a31b7bd"
        
        // device data
        pebbleHelper.printInfo()
        
//        while(true) {
            // data loop
//            pebbleHelper.
            
//        }
    
        
    }
    
    // pebble delegate methods
    
    func pebbleHelper(pebbleHelper: PebbleHelper, receivedMessage: Dictionary<NSObject, AnyObject>) {
        print(receivedMessage)
        
        
        
    }
    
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
    
        print("User Logged In")
        
        if ((error) != nil) {
            // Process error
        } else if result.isCancelled {
            // Handle cancellations
            
            // do nothing, user will still have to login
        
        } else {
        
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    print("User Logged Out")
    
        // stops user from navigating away after logging out
        //self.navigationController?.setNavigationBarHidden(true, animated: true);
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    

}
