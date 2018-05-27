//
//  Constants.swift
//  BLEDemo
//
//  Created by Roman Baitaliuk on 26/05/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation

public struct Constants {
    static let minRSSI = -90.0
    static let maxRSSI = -30.0
    static let RSSIMeasurement = "dBm"
    static let timeIntervals = "sec"
    static let chartEmptyDataText = "No data to display"
    static let averageRSSIText = "Average RSSI: "
    static let numberOfLastRSSIValuesToDisplay = 15
    static let cellsButtonText: [String] = ["Connect", "Send", "Services & Characteristics"]
    static let cellIdentifier = "Cell"

    static let testTimeIntervals = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    static let testRSSIValues = [-30.0, -34.0, -56.0, -35.0, -34.0, -32.0, -56.0, -67.0, -34.0, -45.0, -54.0]
}
