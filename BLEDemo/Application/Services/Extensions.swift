//
//  Extensions.swift
//  BLEDemo
//
//  Created by Roman Baitaliuk on 26/05/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation

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
