//
//  PebbleHelper.swift
//  gesture
//
//  Created by Maksym Pikhteryev on 2015-09-19.
//  Copyright (c) 2015 seapig. All rights reserved.
//

import Foundation

protocol PebbleHelperDelegate {
    func pebbleHelper(pebbleHelper: PebbleHelper, receivedMessage: Dictionary<NSObject, AnyObject>)
}

class PebbleHelper: NSObject, PBPebbleCentralDelegate {
    
    class var instance : PebbleHelper {
        struct Static {
            static let instance : PebbleHelper = PebbleHelper()
        }
        return Static.instance
    }
    
    var watch: PBWatch?
    var delegate: PebbleHelperDelegate?
    var parts = Array<String>()
    var keys = Array<Int>()
    var dictionary = Dictionary<Int, String>()
    
    //Set the app UUID
    var UUID: String? {
        didSet {
            let myAppUUID = NSUUID(UUIDString: self.UUID!)
            var myAppUUIDbytes: UInt8 = 0
            myAppUUID?.getUUIDBytes(&myAppUUIDbytes)
            PBPebbleCentral.defaultCentral().appUUID = NSData(bytes: &myAppUUIDbytes, length: 16)
            if (self.watch != nil) {
                self.watch?.appMessagesAddReceiveUpdateHandler({ (watch, msgDictionary) -> Bool in
                    print("Message received")
                    self.delegate?.pebbleHelper(self, receivedMessage: msgDictionary)
                    return true
                })
            }
        }
        
    }
    
    override init() {
        super.init()
        PBPebbleCentral.defaultCentral().delegate = self
        self.watch = PBPebbleCentral.defaultCentral().lastConnectedWatch()
        if (self.watch != nil) {
            print("Pebble connected: \(self.watch!.name)")
        }
        
    }
    
    func pebbleCentral(central: PBPebbleCentral!, watchDidConnect watch: PBWatch!, isNew: Bool) {
        print("Pebble connected: \(watch.name)")
    }
    
    func pebbleCentral(central: PBPebbleCentral!, watchDidDisconnect watch: PBWatch!) {
        print("Pebble disconnected: \(watch.name)")
        if (self.watch == watch) {
            self.watch = nil
        }
    }
    
    func launchApp(completionHandler: (error: NSError?) -> Void) {
        self.watch?.appMessagesLaunch({ (watch, error) -> Void in
            completionHandler(error: error)
        })
    }
    
    func killApp(completionHandler: (error: NSError?) -> Void) {
        self.watch?.appMessagesKill({ (watch, error) -> Void in
            completionHandler(error: error)
        })
    }
    
    func checkCompatibility(completionHandler: (isAppMessagesSupported: Bool) -> Void) {
        self.watch?.appMessagesGetIsSupported({ (watch, isSupported) -> Void in
            completionHandler(isAppMessagesSupported: isSupported)
        })
    }
    
    func printInfo() {
        if (self.watch != nil) {
            print("Pebble name: \(self.watch!.name)")
            print("Pebble serial number: \(self.watch!.serialNumber)")
            self.watch?.getVersionInfo({ (watch, versionInfo) -> Void in
                print("Pebble firmware os version: \(versionInfo.runningFirmwareMetadata.version.os)")
                print("Pebble firmware major version: \(versionInfo.runningFirmwareMetadata.version.major)")
                print("Pebble firmware minor version: \(versionInfo.runningFirmwareMetadata.version.minor)")
                print("Pebble firmware suffix version: \(versionInfo.runningFirmwareMetadata.version.suffix)")
                }, onTimeout: { (watch) -> Void in
                    print("Timed out trying to get version info from Pebble.")
            })
        }
    }
    
//    func sendDictionary(dictionary: Dictionary<Int, String>, completionHandler: (error: NSError?) -> Void) {
//        if dictionary.isEmpty {
//            return
//        }
//        self.dictionary = dictionary
//        keys = dictionary.keys.array
//        keys.sort { $0 < $1 }
//        sendLine { (error) -> Void in
//            completionHandler(error: error)
//        }
//    }
    
//    private func sendLine(completionHandler: (error: NSError?) -> Void) {
//        let key = keys[0]
//        sendMessage(dictionary[keys[0]]!, key: keys[0]) { (error) -> Void in
//            self.keys.removeAtIndex(0)
//            if (self.keys.isEmpty) {
//                completionHandler(error: nil)
//            } else {
//                self.sendLine(completionHandler)
//            }
//            
//        }
//    }
    
//    func sendMessage(message: String, key: Int, completionHandler: (error: NSError?) -> Void) {
//        
//        let maxLength = 12
//        parts.removeAll(keepCapacity: false)
//        var msg = message
//        do {
//            var part = ""
//            if (msg. > maxLength) {
//                parts.append(msg.substringTo(maxLength))
//                msg = msg.substringFrom(maxLength)
//            } else {
//                parts.append(msg)
//                msg = ""
//            }
//        } while !msg.isEmpty
//        
//        sendToWatch(key, completionHandler: completionHandler)
//    }
    
    private func sendToWatch(key: Int, completionHandler: (error: NSError?) -> Void) {
        let msgDictionary = [0: key, 1: parts[0]]
        self.watch?.appMessagesPushUpdate(msgDictionary as [NSObject : AnyObject], onSent: { (watch, msgDictionary, error) -> Void in
            self.parts.removeAtIndex(0)
            if (self.parts.count > 0) {
                self.sendToWatch(key, completionHandler: completionHandler)
            } else {
                completionHandler(error: error)
            }
        })
    }
}