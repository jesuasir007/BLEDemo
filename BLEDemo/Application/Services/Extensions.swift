//
//  Extensions.swift
//  BLEDemo
//
//  Created by Roman Baitaliuk on 26/05/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation

extension String {
    
    /// Getting GATT characteristic name
    func characteristicName() -> String {
        switch self {
        case "2A37":
            return "Heart Rate Measurement"
        case "2A39":
            return "Heart Rate Control Point"
        case "2A06":
            return "Alert Level"
        default:
            return self
        }
    }
    
    /// Getting GATT service name
    func serviceName() -> String {
        switch self {
        case "1800":
            return "Generic Access"
        case "1811":
            return "Alert Notification Service"
        case "1815":
            return "Automation IO"
        case "180F":
            return "Battery Service"
        case "1810":
            return "Blood Pressure"
        case "181B":
            return "Body Composition"
        case "181E":
            return "Bond Management Service"
        case "181F":
            return "Continuous Glucose Monitoring"
        case "1805":
            return "Current Time Service"
        case "1818":
            return "Cycling Power"
        case "1816":
            return "Cycling Speed and Cadence"
        case "180A":
            return "Device Information"
        case "181A":
            return "Environmental Sensing"
        case "1826":
            return "Fitness Machine"
        case "1801":
            return "Generic Attribute"
        case "1808":
            return "Glucose"
        case "1809":
            return "Health Thermometer"
        case "180D":
            return "Heart Rate"
        case "1823":
            return "HTTP Proxy"
        case "1812":
            return "Human Interface Device"
        case "1802":
            return "Immediate Alert"
        case "1821":
            return "Indoor Positioning"
        case "1820":
            return "Internet Protocol Support Service"
        case "1803":
            return "Link Loss"
        case "1819":
            return "Location and Navigation"
        case "1827":
            return "Mesh Provisioning Service"
        case "1828":
            return "Mesh Proxy Service"
        case "1807":
            return "Next DST Change Service"
        case "1825":
            return "Object Transfer Service"
        case "180E":
            return "Phone Alert Status Service"
        case "1822":
            return "Pulse Oximeter Service"
        case "1829":
            return "Reconnection Configuration"
        case "1806":
            return "Reference Time Update Service"
        case "1814":
            return "Running Speed and Cadence"
        case "1813":
            return "Scan Parameters"
        case "1824":
            return "Transport Discovery"
        case "1804":
            return "Tx Power"
        case "181C":
            return "User Data"
        case "181D":
            return "Weight Scale"
        default:
            return self
        }
    }
}

extension Data {
    
    func chunkedHexEncodedString() -> String {
        let bytes = self.bytes()
        let chunkSize = 4
        return stride(from: 0, to: bytes.count, by: chunkSize)
            .map {
                Array(bytes[$0..<Swift.min($0 + chunkSize, bytes.count)])
                    .map { String(format: "%02hhx", $0) }
                    .joined()
            }
            .joined(separator: " ")
    }
    
    func bytes() -> [UInt8] {
        return self.map({ $0 })
    }
}

extension Date {

    /// Formatting device captured RSSI timestamps to string format for chart view
    func seconds() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ss"
        return dateFormatter.string(from: self)
    }
}

extension Double {

    /// Rounds the double to decimal places value
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    func roundUp(toNearest: Double) -> Double {
        return ceil(self / toNearest) * toNearest
    }
}

extension Array where Element: Numeric {

    /// Returns the total sum of all elements in the array
    var total: Element { return reduce(0, +) }
}

extension Array where Element: BinaryInteger {

    /// Returns the average of all elements in the array
    var average: Double {
        return isEmpty ? 0 : Double(Int(total)) / Double(count)
    }
}

extension Array where Element: FloatingPoint {
    
    /// Returns the average of all elements in the array
    var average: Element {
        return isEmpty ? 0 : total / Element(count)
    }
}
