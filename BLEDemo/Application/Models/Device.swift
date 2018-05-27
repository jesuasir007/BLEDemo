//
//  Device.swift
//  BLEDemo
//
//  Created by Roman Baitaliuk on 26/05/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation

class Device: Equatable {
    
    static func ==(lhs: Device, rhs: Device) -> Bool {
        return lhs.name == rhs.name
    }

    var name: String
    var rssiValues: [(date: Date, rssi: Double)] = []
    var isConnected: Bool = false
    var id: String
    
    public init(id: String, name: String) {
        self.name = name
        self.id = id
    }
    
    /// Adding RSSI value with timestamp
    public func add(_ RSSIvalue: NSNumber) {
        let rssi = Double(truncating: RSSIvalue)
        self.rssiValues.append((date: Date(), rssi: rssi))

        // Take only pre defined last elements
        self.rssiValues = Array(self.rssiValues.suffix(Constants.numberOfLastRSSIValuesToDisplay))
    }
}
