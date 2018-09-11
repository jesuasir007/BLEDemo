//
//  Service.swift
//  BLEDemo
//
//  Created by Roman Baitaliuk on 27/05/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation
import CoreBluetooth

class Service {

    public var uuid: String
    public var service: CBService
    public var characteristic: [Characteristic] = []

    public init(uuid: String, service: CBService) {
        self.uuid = uuid
        self.service = service
    }
}

class Characteristic {

    public var uuid: String
    public var characteristic: CBCharacteristic

    public init(uuid: String, characteristic: CBCharacteristic) {
        self.uuid = uuid
        self.characteristic = characteristic
    }
}
