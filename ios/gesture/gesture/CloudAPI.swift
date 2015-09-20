//
//  CloudAPI.swift
//  gesture
//
//  Created by Maksym Pikhteryev on 2015-09-20.
//  Copyright (c) 2015 seapig. All rights reserved.
//

import Foundation

import Firebase


class CloudAPI : NSObject {
    
    
    // Create a reference to a Firebase location
    var firebaseRoot = Firebase(url:"https://scorching-heat-75.firebaseio.com")
    
    func startListeningToHandshakes(completion: (result: AnyObject) -> ()) {
        
        let url = Firebase(url:"https://scorching-heat-75.firebaseio.com/handshakes")
        
        // Retrieve new posts as they are added to the database
        url.observeEventType(.ChildAdded, withBlock: { snapshot in
//            println("added -> \(snapshot.value)")
            completion(result: snapshot.value)
        })
        
    }
    
//    func getLastHandshake() {
//        
//        let url = firebaseRoot.childByAppendingPath("handshakes")
//
//        url.queryLimitedToLast(1)
//        
//    }
    
    func sendHandshakeToServer(userId: String, timestamp: Double) {
        
        let url = firebaseRoot.childByAppendingPath("handshakes")
        
        // Write data to Firebase
//        firebaseRoot.setValue("Do you have data? You'll love Firebase.")
        
        var data = ["userId": userId , "timestamp": timestamp]
        let nurl = url.childByAutoId()
        nurl.setValue(data as [NSObject : AnyObject])
        
        
        //posts a handshake
        
//        var urlPath = "www.seapig.co/api/handshake"
//        var url: NSURL! = NSURL(string: urlPath)
//        
//        let request = NSMutableURLRequest(URL: url)
//        request.HTTPMethod = "POST"
//        
//        let postString = "{\"userId\": \"\(userId)\",\"timestamp\": \"\(timestamp)\"}"
//        
//        // config stuff
//        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
//            data, response, error in
//            
//            if error != nil {
//                println("error=\(error)")
//                return
//            }
//            
//            println("response = \(response)")
//            
//            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
//            println("responseString = \(responseString)")
//        }
//        task.resume()
        
        //end of post ride
        
        
        
    }
    
    
    
    
}