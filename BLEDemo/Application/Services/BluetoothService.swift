//
//  BluetoothService.swift
//  BLEDemo
//
//  Created by Roman Baitaliuk on 26/05/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BluetoothServiceDelegate: class {

    /// Called when 'CBCentralManager' changes state
    func didPowerStateUpdate(isPowerOn: Bool)

    /// Called when eather new device has been discovered or rssi value of the existing has been updated
    func didDevicesUpdate()

    // Called when 'CBCentralManager' connects or disconnects from the device
    func didConnect()
}

class BluetoothService: NSObject {
    
    // MARK: - Properties

    private var centralManager: CBCentralManager!
    private var devices: [Device] = []

    /// Keep track on 'CBPeripheral' allows us to ineract with that device
    private var peripheralDevices: [CBPeripheral] = []

    /// Help identify whether we need to save new value
    private var shouldSaveNewRSSI: Bool = true

    /// Define time interval for saving new RSSI values, default is 5.0 sec
    public var refreshInterval: TimeInterval = 5.0
    public weak var delegate: BluetoothServiceDelegate?
    
    // MARK: - Init
    
    public override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public methods
    
    /// Start scanning for peripherals
    public func startScanning() {

        guard self.isPowerOn() else {
            return
        }

        /// Start scanning for peripheral devices
        self.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    /// Stop scanning for peripherals
    public func stopScanning() {
        guard self.isPowerOn() else {
            return
        }

        self.centralManager.stopScan()
    }
    
    /// Getting all scanned peripheral devices
    public func getDevices() -> [Device] {
        return self.devices
    }

    /// Check if the power is on
    public func isPowerOn() -> Bool {
        return self.centralManager.state == .poweredOn
    }

    /// Check if 'CBCentralManager' is scanning for peripheral devices
    public func isScanning() -> Bool {
        return self.centralManager.isScanning
    }

    public func connect(to device: Device) {
        if let peripheralDevice =  self.matchDevice(device) {
            self.centralManager.connect(peripheralDevice)
        }
    }

    // MARK: - Private methods

    /// Start refreshing timer that updates 'shouldSaveNewRSSI' which saves RSSI values with defined time interval
    private func startRefresher() {
        Timer.scheduledTimer(withTimeInterval: self.refreshInterval, repeats: false, block: { timer in
            self.shouldSaveNewRSSI = true
        })
    }

    /// Matching device with peripheral by uuid
    private func matchDevice(_ device: Device) -> CBPeripheral? {
        if let peripheralDevice = (self.peripheralDevices.filter { $0.identifier.uuidString == device.id }).first {
            return peripheralDevice
        }
        return nil
    }

    /// Matching peripheral with device by uuid
    private func matchPeripheral(_ peripheral: CBPeripheral) -> Device? {
        if let device = (self.devices.filter { $0.id == peripheral.identifier.uuidString }).first {
            return device
        }
        return nil
    }
}

// MARK: - CBCentralManagerDelegate, CBPeripheralDelegate

extension BluetoothService: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.delegate?.didPowerStateUpdate(isPowerOn: central.state == .poweredOn)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        debugPrint("[CONNECT]: - \(peripheral.name!)")
        if let device = self.matchPeripheral(peripheral) {
            device.isConnected = true
            self.delegate?.didConnect()
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        debugPrint("[Disconnect]: - \(peripheral.name!)")
        if let device = self.matchPeripheral(peripheral) {
            device.isConnected = false
            self.delegate?.didConnect()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // Retrieve the peripheral name from the advertisement data using the "kCBAdvDataLocalName" key
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            debugPrint("[Peripheral Device] - \(peripheralName)")

            // If device already created we just add new RSSI value and timestamp
            if let existingDevice = self.devices.filter({ $0.name == peripheralName }).first {

                // Check if we need to save new RSSI value
                if self.shouldSaveNewRSSI {
                    existingDevice.add(RSSI)
                    self.shouldSaveNewRSSI = false
                    self.startRefresher()
                    self.delegate?.didDevicesUpdate()
                }
            } else {
                // Creating new peripheral devices and adding it to collection of discovered devices
                let device = Device(id: peripheral.identifier.uuidString, name: peripheralName)
                device.add(RSSI)
                self.devices.append(device)
                self.delegate?.didDevicesUpdate()

                self.peripheralDevices.append(peripheral)
            }
        }
    }
}
