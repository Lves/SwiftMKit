//
//  Int+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/27/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

public extension Double {
    
    // MARK: Format
    func formatCurrency(locale: String = "en_US") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = Locale(identifier: locale)
        formatter.currencySymbol = ""
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    func formatCurrencyWithoutDot(locale: String = "en_US") -> String {
        var value = self.formatCurrency(locale: locale)
        if value.contains(".") {
            value = value.components(separatedBy: ".").first ?? value
        }
        return value
    }
    
    func formatDecimals(decimals : Int = 0) -> String {
        return String(format: "%.\(decimals)f", self)
    }
}


precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ** : PowerPrecedence

extension Double {
    
    /// EZSE: Converts Double to String
    public var toString: String { return String(self) }
    
    /// EZSE: Converts Double to Int
    public var toInt: Int { return Int(self) }
    
    /// EZSE: Creating the exponent operator
    static public func ** (lhs: Double, rhs: Double) -> Double {
        return pow(lhs, rhs)
    }
}

// MARK: - Deprecated 1.8
extension Double {
    
    /// EZSE: Absolute value of Double.
    public var abs: Double {
        if self > 0 {
            return self
        } else {
            return -self
        }
    }
    
}
