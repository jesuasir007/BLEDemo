//
//  AppError.swift
//  BLEDemo
//
//  Created by Roman Baitaliuk on 26/05/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation

typealias ErrorAction = () -> ()

enum AppError: Error {

    case bluetoothIsOff
    case unknown
    case notConnected

    public var message: String {
        switch self {
        case .bluetoothIsOff: return "Please turn on and try again"
        case .unknown: return "Please try again later!"
        case .notConnected: return "Please connect to the device and try again"
        }
    }

    public var title: String {
        switch self {
        case .bluetoothIsOff: return "Bluetooth is currently powered off."
        case .unknown: return "Oops! Something went wrong!"
        case .notConnected: return "Not Connected"
        }
    }

    public var buttonTitle: String {
        switch self {
        case .bluetoothIsOff: return "OK"
        case .unknown: return "OK"
        case .notConnected: return "OK"
        }
    }
}
