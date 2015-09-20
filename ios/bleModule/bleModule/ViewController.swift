//
//  ViewController.swift
//  bleModule
//
//  Created by Tony Wu on 9/19/15.
//  Copyright © 2015 Tony Wu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var peripheralModule:BlePeripheralModule!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peripheralModule = BlePeripheralModule()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func AdvertisingButtonPushed(sender: UIButton) {
        self.peripheralModule.advertiseStart()
    }

}

