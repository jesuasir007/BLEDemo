//
//  Constants.swift
//  BLEDemo
//
//  Created by Roman Baitaliuk on 26/05/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct Constants {
    static let minRSSI = -90.0
    static let maxRSSI = -30.0
    static let RSSIMeasurement = "dBm"
    static let timeIntervals = "sec"
    static let chartEmptyDataText = "No data to display"
    static let averageRSSIText = "Average RSSI: "
    static let numberOfLastRSSIValuesToDisplay = 15
    static let cellsButtonText: [String] = ["Connect", "Services & Characteristics", "Steps"]
    static let cellIdentifier = "Cell"
    static let testData: Data = Data()

    static let testTimeIntervals = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    static let testRSSIValues = [-30.0, -34.0, -56.0, -35.0, -34.0, -32.0, -56.0, -67.0, -34.0, -45.0, -54.0]
}

public var Mi_Band_Service: CBUUID = CBUUID(string: "FEE0")
public var Heart_Rate_Service: CBUUID = CBUUID(string: "180D")
public var Alert_Service: CBUUID = CBUUID(string: "1802")

public var Alert_Characteristic: CBUUID = CBUUID(string: "2A06")
public var Steps_Characteristic: CBUUID = CBUUID(string: "FF06")

struct AlertMode {
    static let off: UInt8 = 0x0
    static let mild: UInt8 = 0x1
    static let high: UInt8 = 0x2
}
