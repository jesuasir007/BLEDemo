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
    func didDeviceUpdate()

    /// Called when 'CBCentralManager' connects or disconnects from the device
    func didDeviceConnectionUpdate()
    
    /// Called when steps changed
    func didStepsUpdate(steps: Int)
}

class BluetoothService: NSObject {
    
    // MARK: - Properties

    private var centralManager: CBCentralManager!
    private var devices: [Device] = []

    public weak var delegate: BluetoothServiceDelegate?
    
    // MARK: - Init
    
    public override init() {
        super.init()
        
        /** Best Practice
            Perform Bluetooth tasks on background queue */
        let backgroundQueue = DispatchQueue.global(qos: .background)
        self.centralManager = CBCentralManager(delegate: self, queue: backgroundQueue)
    }
    
    // MARK: - Public methods
    
    /// Start scanning for peripherals
    public func startScanning() {
        guard self.isPowerOn() else { return }

        /** Best Practice
            Scanning only for specific peripherals */
        
        /** Services could be specified for faster search */
        self.centralManager.scanForPeripherals(withServices: [Mi_Band_Service], options: nil)
    }
    
    /// Stop scanning for peripherals
    public func stopScanning() {
        guard self.isPowerOn() else { return }

        /** Best Practice
            Stop scanning when we don't need to */
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
        guard self.isPowerOn() else { return }

        self.centralManager.connect(device.peripheral)
    }

    // MARK: - Private methods

    /// Matching 'CBPeripheral' with 'Device' by uuid
    private func matchPeripheral(_ peripheral: CBPeripheral) -> Device? {
        return self.devices.first(where: { $0.peripheral == peripheral })
    }

    /// Matching 'CBService' with 'Service' of the device by uuid
    private func matchService(_ service: CBService, for device: Device) -> Service? {
        return device.services.first(where: { $0.service == service })
    }
}

// MARK: - CBCentralManagerDelegate, CBPeripheralDelegate

extension BluetoothService: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        DispatchQueue.main.async {
            self.delegate?.didPowerStateUpdate(isPowerOn: central.state == .poweredOn)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        debugPrint("[Connect]: - \(peripheral.name!)")
        if let device = self.matchPeripheral(peripheral) {
            device.isConnected = true
            device.peripheral.delegate = self
            device.peripheral.discoverServices(nil)
            
            DispatchQueue.main.async {
                self.delegate?.didDeviceConnectionUpdate()
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        debugPrint("[Disconnect]: - \(peripheral.name!)")
        if let device = self.matchPeripheral(peripheral) {
            device.isConnected = false
            
            DispatchQueue.main.async {
                self.delegate?.didDeviceConnectionUpdate()
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        guard let device = self.matchPeripheral(peripheral) else { return }

        for service in services {
            debugPrint("[Service]: - \(service)")
            let deviceService = Service(uuid: service.uuid.uuidString, service: service)
            device.services.append(deviceService)
            
            /** Characteristics could be specified for faster search */
//            peripheral.discoverCharacteristics([Alert_Characteristic, Steps_Characteristic], for: service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        guard let device = self.matchPeripheral(peripheral) else { return }
        guard let deviceService = self.matchService(service, for: device) else { return }

        for characteristic in characteristics {
            debugPrint("[Characteristics]: - \(service)")
            let deviceCharacteristic = Characteristic(uuid: characteristic.uuid.uuidString,
                                                      characteristic: characteristic)
            deviceService.characteristic.append(deviceCharacteristic)
            
            if characteristic.uuid.uuidString == MiCharacteristicID.steps {
                /** We can read its value and/or register for notifications,
                 *  which will be sent every time this value changes.
                 */
                peripheral.setNotifyValue(true, for: characteristic)
//                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let value = characteristic.value else { return }
        
        // Characteristic for total steps count
        if characteristic.uuid.uuidString == MiCharacteristicID.steps {
            let steps = (value as NSData).bytes.bindMemory(to: Int.self, capacity: characteristic.value!.count).pointee
            
            DispatchQueue.main.async {
                debugPrint("[Steps Count]: - steps \(steps)")
                self.delegate?.didStepsUpdate(steps: steps)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        /** Received Signal Strength Indicator (RSSI)
            is a measurement of the power present in a received radio signal */
        
        // Retrieve the peripheral name from the advertisement data using the "kCBAdvDataLocalName" key
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            debugPrint("[Peripheral Device]: - \(peripheralName)")

            // If device already created we just add new RSSI value and timestamp
            if let existingDevice = self.devices.filter({ $0.name == peripheralName }).first {
                
                // Adding RSSI value to existing device
                existingDevice.add(RSSI)
            } else {
                // Creating new peripheral devices and adding it to collection of discovered devices
                let device = Device(uuid: peripheral.identifier.uuidString,
                                    name: peripheralName,
                                    peripheral: peripheral)
                device.add(RSSI)
                self.devices.append(device)
            }
            
            DispatchQueue.main.async {
                self.delegate?.didDeviceUpdate()
            }
        }
    }
}
