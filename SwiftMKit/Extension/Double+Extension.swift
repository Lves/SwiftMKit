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
    func formatCurrency(_ locale: String = "en_US") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = Locale(identifier: locale)
        formatter.currencySymbol = ""
        return formatter.string(from: NSNumber(self)) ?? "\(self)"
    }
    func formatCurrencyWithoutDot(_ locale: String = "en_US") -> String {
        var value = self.formatCurrency(locale)
        if value.contains(".") {
            value = value.components(separatedBy: ".").first ?? value
        }
        return value
    }
}
