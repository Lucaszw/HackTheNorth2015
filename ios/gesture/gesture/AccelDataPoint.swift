//
//  File.swift
//  gesture
//
//  Created by Maksym Pikhteryev on 2015-09-19.
//  Copyright (c) 2015 seapig. All rights reserved.
//

struct AccelDataPoint {
    
    var x : Int
    var y : Int
    var z : Int
    var didVibrate : Bool
    var timestamp : NSTimeInterval
    
    init(x: Int, y : Int, z : Int, didVibrate : Bool, timestamp : NSTimeInterval) {
        self.x = x;
        self.y = y;
        self.z = z;
        self.didVibrate = didVibrate;
        self.timestamp = timestamp;
    }
}