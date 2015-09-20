//
//  peripheralModule.swift
//  bleModule
//
//  Created by Tony Wu on 9/19/15.
//  Copyright © 2015 Tony Wu. All rights reserved.
//

import CoreBluetooth

private(set) var isBleEnabled:Bool = false
//private(set) var isBleConnected:Bool = false

class BlePeripheralModule: NSObject,CBPeripheralManagerDelegate {
    
    //GATT Structure:
    
    //appSerivce
    //--accelDataChar
    //--fbIdChar
    var subscribedCentral: CBCentral!
    
    var appService: CBMutableService!
    let appServiceUUID = CBUUID(string: "A07A137A-683D-432B-A649-8C42FA1E676F")
    let accelDataCharUUID = CBUUID(string: "A07A56AC-683D-432B-A649-8C42FA1E676F")
    let fbIdCharUUID = CBUUID(string: "8890EF3F-D289-438E-B4FF-8E9ABE491A53")
    
    var accelDataChar: CBMutableCharacteristic!
    var fbIDChar: CBMutableCharacteristic!
    
    var peripheralManager: CBPeripheralManager!
    override init() {
        super.init()
        self.peripheralManager = CBPeripheralManager(delegate:self, queue:nil)
    }
    
    func advertiseStart() {
        
        // create an array of bytes to send
        var byteArray = [UInt8]()
        
        byteArray.append(0b00000000);
        byteArray.append(0b00000000);
        
        let manufData = NSData(bytes: byteArray,length: byteArray.count)
        let advUuid = appServiceUUID
        
        let advData:[String: AnyObject] = [
            CBAdvertisementDataManufacturerDataKey: manufData,
            CBAdvertisementDataServiceUUIDsKey:advUuid
        ]
        self.peripheralManager.startAdvertising(advData)
    }
    
    func services_characteristics_init() {
        
        //init service
        self.appService = CBMutableService(type: appServiceUUID, primary: true)
        
        //init characteristic properties and permissions
        var accelProperties = CBCharacteristicProperties()
        accelProperties.insert(.Read)
        accelProperties.insert(.Notify)
        var accelPermissions = CBAttributePermissions()
        accelPermissions.insert(.Readable)
        
        var fbIdProperties = CBCharacteristicProperties()
        fbIdProperties.insert(.Read)
        fbIdProperties.insert(.Notify)
        var fbIdPermissions = CBAttributePermissions()
        fbIdPermissions.insert(.Readable)
        
        //init characteristics
        self.accelDataChar = CBMutableCharacteristic(type: accelDataCharUUID, properties: accelProperties, value: nil, permissions: accelPermissions)
        self.fbIDChar = CBMutableCharacteristic(type: fbIdCharUUID, properties: fbIdProperties, value: nil, permissions: fbIdPermissions)
        self.appService.characteristics = [accelDataChar,fbIDChar]
        
        //Add service to GATT
        self.peripheralManager.addService(self.appService)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        self.subscribedCentral = central
    }
    
    func updateAccelCharacteristic(accelData: NSData) {
        self.peripheralManager.updateValue(accelData, forCharacteristic: accelDataChar, onSubscribedCentrals: [subscribedCentral])
    }
    
    func setFbIdCharacteristic(fbId: NSData) {
        
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            isBleEnabled = true
        }
        else if peripheral.state == CBPeripheralManagerState.PoweredOff {
            isBleEnabled = false
        }
    }
    
    
}
