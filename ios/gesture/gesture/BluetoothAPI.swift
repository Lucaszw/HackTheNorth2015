////
////  BluetoothAPI.swift
////  gesture
////
////  Created by Maksym Pikhteryev on 2015-09-19.
////  Copyright (c) 2015 seapig. All rights reserved.
////
//
//import Foundation
//
//import CoreBluetooth
//
//// class for sending out BLE pulses when a handshake is detected
//// will also be always listening for other people's pulses
//
//
//// pulse should contain the app owners fbid, the other person would then pick up the pulse and friend that id
//
//class BluetoothAPI : CBCentralManagerDelegate, CBPeripheralDelegate {
//    
//    
//    @IBOutlet var statusLabel : UILabel!;
//    
//    // BLE
//    var centralManager : CBCentralManager!
//    var sensorTagPeripheral : CBPeripheral!
//    
//    
//    func initializeBLE() {
//        
//        // Initialize central manager on load
//        centralManager = CBCentralManager(delegate: self, queue: nil)
//        
//    }
//    
//    // Check status of BLE hardware
//    func centralManagerDidUpdateState(central: CBCentralManager!) {
//        if central.state == CBCentralManagerState.PoweredOn {
//            // Scan for peripherals if BLE is turned on
//            central.scanForPeripheralsWithServices(nil, options: nil)
//            self.statusLabel.text = "Searching for BLE Devices"
//        }
//        else {
//            // Can have different conditions for all states if needed - print generic message for now
//            println("Bluetooth switched off or not initialized")
//        }
//    }
//    
//    // Check out the discovered peripherals to find Sensor Tag
//    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
//        
//        let deviceName = "SensorTag"
//        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
//        
//        if (nameOfDeviceFound == deviceName) {
//            // Update Status Label
//            self.statusLabel.text = "something found"
//            
//            // Stop scanning
//            self.centralManager.stopScan()
//            // Set as the peripheral to use and establish connection
//            self.sensorTagPeripheral = peripheral
//            self.sensorTagPeripheral.delegate = self
//            self.centralManager.connectPeripheral(peripheral, options: nil)
//        }
//        else {
//            self.statusLabel.text = "Sensor Tag NOT Found"
//        }
//    }
//    
//    // Discover services of the peripheral
//    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
//        self.statusLabel.text = "Discovering peripheral services"
//        peripheral.discoverServices(nil)
//    }
//    
//    // Check if the service discovered is a valid IR Temperature Service
//    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
//        self.statusLabel.text = "Looking at peripheral services"
//        for service in peripheral.services {
//            let thisService = service as CBService
//            if service.UUID == IRTemperatureServiceUUID {
//                // Discover characteristics of IR Temperature Service
//                peripheral.discoverCharacteristics(nil, forService: thisService)
//            }
//            // Uncomment to print list of UUIDs
//            //println(thisService.UUID)
//        }
//    }
//    
//    // Enable notification and sensor for each characteristic of valid service
//    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
//        
//        // update status label
//        self.statusLabel.text = "Enabling sensors"
//        
//        // 0x01 data byte to enable sensor
//        var enableValue = 1
//        let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
//        
//        // check the uuid of each characteristic to find config and data characteristics
//        for charateristic in service.characteristics {
//            let thisCharacteristic = charateristic as CBCharacteristic
//            // check for data characteristic
//            if thisCharacteristic.UUID == IRTemperatureDataUUID {
//                // Enable Sensor Notification
//                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
//            }
//            // check for config characteristic
//            if thisCharacteristic.UUID == IRTemperatureConfigUUID {
//                // Enable Sensor
//                self.sensorTagPeripheral.writeValue(enablyBytes, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithResponse)
//            }
//        }
//        
//    }
//    
//    // Get data values when they are updated
//    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
//        
//        self.statusLabel.text = "Connected"
//        
//        if characteristic.UUID == IRTemperatureDataUUID {
//            // Convert NSData to array of signed 16 bit values
//            let dataBytes = characteristic.value
//            let dataLength = dataBytes.length
//            var dataArray = [Int16](count: dataLength, repeatedValue: 0)
//            dataBytes.getBytes(&dataArray, length: dataLength * sizeof(Int16))
//            
//            // Element 1 of the array will be ambient temperature raw value
//            let ambientTemperature = Double(dataArray[1])/128
//            
//            // Display on the temp label
//            self.tempLabel.text = NSString(format: "%.2f", ambientTemperature)
//        }
//    }
//    
//    // If disconnected, start searching again
//    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
//        self.statusLabel.text = "Disconnected"
//        central.scanForPeripheralsWithServices(nil, options: nil)
//    }
//    
//    
//    // facebook stuff?
//    func facebookStuff(fbId: String) {
//        
//        
//        let url = "";
//        
//        
//    }
//    
//    
//}