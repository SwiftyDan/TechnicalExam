//
//  IntHelpers.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import UIKit

func range<T>(value: T, min minValue: T, max maxValue: T) -> T where T: Comparable {
    max(minValue, min(value, maxValue))
}

extension Int {
    init?(safe value: Any?) {
        if let intValue = value as? Int {
            self = intValue
            return
        } else if let strValue = value as? String {
            if let intValue = Int(strValue) {
                self = intValue
                return
            }
            if let doubleValue = Double(strValue), doubleValue < Double(Int.max) {
                self = Int(doubleValue)
                return
            }
            if let halfWidthString = strValue.applyingTransform(.fullwidthToHalfwidth, reverse: false),
               let intValue = Int(halfWidthString) {
                self = intValue
                return
            }
        }
        return nil
    }

    var commaString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }

    var commaStringFormat: String {
        let string = commaString
        return string.replacingOccurrences(of: "[0-9]",
                                           with: "#",
                                           options: [.regularExpression])
    }

    func zeroPadding(disits: Int) -> String {
        String(format: "%0\(disits)d", self)
    }

    var toDate: Date {
        let year = self / 10000
        let month = (self % 10000) / 100
        let day = self % 100
        return Date(year: year, month: month, day: day)
    }

    var rounded: Int {
        guard self > 9 else {
            return self < 5 ? 5 : 10
        }
        let numberStr = String(self)
        let base = (pow(10, numberStr.count - 1) as NSDecimalNumber).intValue
        let subbase = (pow(10, numberStr.count - 2) as NSDecimalNumber).intValue
        let firstNumber = self / base
        let subNumber = (self / subbase) % 10
        if subNumber < 5 {
            return firstNumber * base + 5 * subbase
        }
        return (firstNumber + 1) * base
    }

    var roundDowned: Int {
        guard self > 9 else {
            return self < 6 ? 0 : 5
        }
        let numberStr = String(self)
        let base = (pow(10, numberStr.count - 1) as NSDecimalNumber).intValue
        let subbase = (pow(10, numberStr.count - 2) as NSDecimalNumber).intValue
        let firstNumber = self / base
        let subNumber = (self / subbase) % 10
        if subNumber < 6 {
            return firstNumber * base
        }
        return firstNumber * base + 5 * subbase
    }

    var length: Int {
        String(self).count
    }
}

extension Int64 {
    init?(safe value: Any?) {
        if let intValue = value as? Int64 {
            self = intValue
            return
        } else if let strValue = value as? String {
            if let intValue = Int64(strValue) {
                self = intValue
                return
            }
            if let doubleValue = Double(strValue) {
                self = Int64(doubleValue)
                return
            }
            if let halfWidthString = strValue.applyingTransform(.fullwidthToHalfwidth, reverse: false),
               let intValue = Int64(halfWidthString) {
                self = intValue
                return
            }
        }
        return nil
    }

    var commaString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal

        let isNegative = self < 0

        guard let result = numberFormatter.string(from: NSNumber(value: abs(self))) else {
            return "0"
        }
        return (isNegative ? "-" : "") + result
    }

    func zeroPadding(disits: Int) -> String {
        String(format: "%0\(disits)d", self)
    }
}
