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

    public var name: String
    public var rssiValues: [(date: Date, rssi: Double)] = []
    public var isConnected: Bool = false
    public var uuid: String
    public var services: [Service] = []
    
    public init(uuid: String, name: String) {
        self.name = name
        self.uuid = uuid
    }
    
    /// Adding RSSI value with timestamp
    public func add(_ RSSIvalue: NSNumber) {
        let rssi = Double(truncating: RSSIvalue)
        self.rssiValues.append((date: Date(), rssi: rssi))

        // Take only pre defined last elements
        self.rssiValues = Array(self.rssiValues.suffix(Constants.numberOfLastRSSIValuesToDisplay))
    }
}
