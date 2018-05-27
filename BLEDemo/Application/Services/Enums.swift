//
//  Enums.swift
//  BLEDemo
//
//  Created by Roman Baitaliuk on 27/05/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation

enum DeviceInteraction: Int {
    case connect
    case send
    case services

    static func identifyInteraction(for selectedRow: Int) -> DeviceInteraction? {
        switch selectedRow {
        case 0:
            return .connect
        case 1:
            return .send
        case 2:
            return .services
        default:
            return nil
        }
    }
}

enum RSSISignalStrength: String {
    case amazing = "Amazing"
    case veryGood = "Very Good"
    case okay = "Okay"
    case notGood = "Not Good"
    case unusable = "Unusable"

    static func calculateSignalStrength(rssi: Double) -> RSSISignalStrength {
        switch rssi {
        case (-50.0)...(-30.0):
            return .amazing
        case (-67)...(-49):
            return .veryGood
        case (-75)...(-66):
            return .okay
        case (-85)...(-74):
            return .notGood
        default:
            return .unusable
        }
    }
}

enum DeviceConnectionStatus: String {
    case connected = "Connected"
    case disconnected = "Not Connected"
}
