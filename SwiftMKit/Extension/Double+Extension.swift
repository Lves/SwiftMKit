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
