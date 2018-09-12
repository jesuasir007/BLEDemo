//
//  Device.swift
//  BLEDemo
//
//  Created by Roman Baitaliuk on 26/05/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation
import CoreBluetooth

class Device: Equatable {
    
    static func ==(lhs: Device, rhs: Device) -> Bool {
        return lhs.name == rhs.name
    }

    public var name: String
    public var rssiValues: [(date: Date, rssi: Double)] = []
    public var isConnected: Bool = false
    public var uuid: String
    public var services: [Service] = []
    public var peripheral: CBPeripheral
    
    public init(uuid: String, name: String, peripheral: CBPeripheral) {
        self.name = name
        self.uuid = uuid
        self.peripheral = peripheral
    }
    
    /// Adding RSSI value with timestamp
    public func add(_ RSSIvalue: NSNumber) {
        let rssi = Double(truncating: RSSIvalue)
        self.rssiValues.append((date: Date(), rssi: rssi))

        // Take only pre defined last elements
        self.rssiValues = Array(self.rssiValues.suffix(Constants.numberOfLastRSSIValuesToDisplay))
    }
    
    /// Start vibrating with certain level
    public func vibrate(level: UInt8) {
        
        // Searching for alert characteristic
        if let alertCharacteristic = self.services.first(where: { $0.service.uuid == Alert_Service })?.characteristic.first(where: { $0.characteristic.uuid == Alert_Characteristic }) {
            
            self.peripheral.writeValue(Data(bytes: [level]), for: alertCharacteristic.characteristic, type: .withoutResponse)
        }
    }
}
