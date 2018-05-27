//
//  Service.swift
//  BLEDemo
//
//  Created by Roman Baitaliuk on 27/05/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation

class Service {

    public var uuid: String
    public var characteristic: [Characteristic] = []

    public init(uuid: String) {
        self.uuid = uuid
    }
}

class Characteristic {

    public var uuid: String

    public init(uuid: String) {
        self.uuid = uuid
    }
}
