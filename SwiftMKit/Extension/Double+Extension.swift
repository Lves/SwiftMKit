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
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: locale)
        formatter.currencySymbol = ""
        return formatter.stringFromNumber(self) ?? "\(self)"
    }
    func formatCurrencyWithoutDot(locale: String = "en_US") -> String {
        var value = self.formatCurrency(locale)
        if value.contains(".") {
            value = value.componentsSeparatedByString(".").first ?? value
        }
        return value
    }
}