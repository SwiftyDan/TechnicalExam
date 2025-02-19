//
//  StringHelpers.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import UIKit

// MARK: - Check string
extension String {
    var isNumber: Bool {
        check(with: "^[0-9]+$")
    }

    var isNumberAndAlphabet: Bool {
        !isEmpty && rangeOfCharacter(from: NSCharacterSet.alphanumerics.inverted) == nil
    }
    
    var isAllNumberAndAlphabet: Bool { check(with: "^[A-Za-z0-9０-９ａ-ｚＡ-Ｚ↨]+$") }

    var isNumberAndHalfAlphabet: Bool {
        !isEmpty && range(of: "^[A-Za-z0-9↨]*$", options: .regularExpression) != nil
    }

    var isAsciiString: Bool {
        if isEmpty || unicodeScalars.contains(where: { char -> Bool in !char.isASCII }) {
            return false
        }
        return true
    }
    
    func validatePassword() throws  {
        guard count > 7
            else { throw PasswordError.eightCharacters }
        guard rangeOfCharacter(from: .uppercaseLetters) != nil
            else { throw PasswordError.oneUppercase }
        guard rangeOfCharacter(from: .lowercaseLetters) != nil
            else { throw PasswordError.oneLowercase }
        guard rangeOfCharacter(from: .decimalDigits) != nil
            else { throw PasswordError.oneDecimalDigit }
    }
    
    func isValidEmail() -> Bool {
         let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
     }
    
    func check(with regex: String) -> Bool {
        !isEmpty && range(of: regex, options: .regularExpression) != nil
    }
}

// MARK: - Get substring
extension String {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }

    subscript(index: Int) -> String {
        String(self[index] as Character)
    }

    func getIndex(offset: Int) -> String.Index {
        guard let index = index(startIndex, offsetBy: offset, limitedBy: endIndex) else {
            fatalError("String is too short.")
        }
        return index
    }

    /// string[0..<5]
    subscript(range: Range<Int>) -> Substring {
        let startIndex = getIndex(offset: range.lowerBound)
        let endIndex = getIndex(offset: range.upperBound)
        return self[startIndex ..< endIndex]
    }

    /// string[0...5]
    subscript(range: ClosedRange<Int>) -> Substring {
        let startIndex = getIndex(offset: range.lowerBound)
        let endIndex = getIndex(offset: range.upperBound)
        return self[startIndex ... endIndex]
    }

    /// string[..<5]
    subscript(range: PartialRangeUpTo<Int>) -> Substring {
        let endIndex = getIndex(offset: range.upperBound)
        return self[..<endIndex]
    }

    /// string[...5]
    subscript(range: PartialRangeThrough<Int>) -> Substring {
        let endIndex = getIndex(offset: range.upperBound)
        return self[...endIndex]
    }

    /// string[5...]
    subscript(range: PartialRangeFrom<Int>) -> Substring {
        let startIndex = getIndex(offset: range.lowerBound)
        return self[startIndex...]
    }

    /// NSRangeでsubstring
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }

    func substring(from: Int, length: Int) -> String {
        substring(from: from).substring(to: length)
    }

    func substring(from index: Int) -> String {
        if index < 0 {
            return self
        }
        return String(dropFirst(index))
    }

    func substring(to index: Int) -> String {
        if count <= index {
            return self
        }
        return String(dropLast(count - index))
    }

    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let range = self.range(of: substring, options: options,
                                     range: (ranges.last?.upperBound ?? self.startIndex) ..< self.endIndex,
                                     locale: locale) {
            ranges.append(range)
        }
        return ranges
    }
}

// MARK: - Edit string
extension String {
    func zeroPadding(length: Int) -> String {
        let zeroLength = length - count
        if zeroLength < 1 {
            return self
        }
        return "".padding(toLength: zeroLength, withPad: "0", startingAt: 0) + self
    }

    func removeHeadZero() -> String {
        guard count > 1 else { return self }
        let parts = split(separator: ".")
        return (Int(parts[0].replacingOccurrences(of: ",", with: "")) ?? 0).commaString
            + (parts.count > 1 ? "." + parts[1] : "")
    }
    
    func removeCharacters(from forbiddenChars: CharacterSet) -> String {
        let passed = self.unicodeScalars.filter { !forbiddenChars.contains($0) }
        return String(String.UnicodeScalarView(passed))
    }

    func trim(in characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        trimmingCharacters(in: characterSet)
    }

    func trimAndRemoveNonDigit() -> String {
        return self.trim().removeCharacters(from: .decimalDigits.inverted)
    }

    func masking(length: Int, char: String = "*") -> String {
        "\(dropLast(length))\(String(repeating: char, count: length))"
    }

    func maskEmail(length: Int) -> String? {
        let splittedString = split(separator: "@", maxSplits: 2)
        guard splittedString.count == 2 else { return nil }
        let account = String(splittedString[0])
        return "\(account.masking(length: min(4, account.count - 1)))@\(splittedString[1])"
    }

    func split(by length: Int) -> [String] {
        var startIndex = startIndex
        var results = [Substring]()

        while startIndex < endIndex {
            let endIndex = index(startIndex, offsetBy: length, limitedBy: endIndex) ?? endIndex
            results.append(self[startIndex ..< endIndex])
            startIndex = endIndex
        }

        return results.map { String($0) }
    }

    func count(of char: String) -> Int {
        components(separatedBy: char).count - 1
    }
}

// MARK: - Convert string
extension String {
    func getAttributedString(with font: UIFont,
                             color: UIColor? = .darkText,
                             attributes: [NSAttributedString.Key: Any]? = nil) -> NSMutableAttributedString {
        var attr: [NSAttributedString.Key: Any] = [.font: font]
        if let color {
            attr[.foregroundColor] = color
        }
        if let attributes {
            attr = attr.merging(attributes, uniquingKeysWith: { value1, _ -> Any in
                value1
            })
        }

        let attributedString = NSMutableAttributedString(string: self)

        attributedString.addAttributes(attr, range: NSRange(location: 0, length: utf16.count))

        return attributedString
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let string = self as NSString
        let boundingBox = string.boundingRect(with: constraintRect,
                                              options: .usesLineFragmentOrigin,
                                              attributes: [.font: font],
                                              context: nil)
        return roundTillHalf(boundingBox.width)
    }

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        // swiftformat:disable redundantSelf
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)
        return roundTillHalf(boundingBox.height)
    }

    private func roundTillHalf(_ value: CGFloat) -> CGFloat {
        if value - CGFloat(Int(value)) >= 0.5 {
            CGFloat(Int(value)) + 1
        } else {
            CGFloat(Int(value)) + 0.5
        }
    }

    private func convertHex(_ start: String.UnicodeScalarView,
                            index: String.UnicodeScalarIndex,
                            appendTo decimal: [UInt8]) -> [UInt8] {
        let skipChars = CharacterSet.whitespacesAndNewlines
        guard index != start.endIndex else { return decimal }
        let next1 = start.index(after: index)
        if skipChars.contains(start[index]) {
            return convertHex(start, index: next1, appendTo: decimal)
        } else {
            guard next1 != start.endIndex else { return decimal }
            let next2 = start.index(after: next1)

            let substring = String(start[index ..< next2])

            guard let value = UInt8(substring, radix: 16) else { return decimal }

            return convertHex(start, index: next2, appendTo: decimal + [value])
        }
    }
    /// - Note: "0102ab" -> 0x0102ab
    var hexData: Data {
        Data(convertHex(self.unicodeScalars, index: self.unicodeScalars.startIndex, appendTo: []))
    }

    func stripHTMLTag(_ changeBrTag: Bool = true) -> String {
        let temp = changeBrTag ? replacingOccurrences(of: "<br>", with: "\n") : self
        return temp.replacingOccurrences(of: "<[^>]+>",
                                         with: "",
                                         options: .regularExpression,
                                         range: nil)
    }

    func convertFullToHalf() -> String {
        applyingTransform(.fullwidthToHalfwidth, reverse: false) ?? self
    }

    func convertHalfToFull() -> String {
        applyingTransform(.fullwidthToHalfwidth, reverse: true) ?? self
    }

    func convertHiraganaToKatakana() -> String {
        applyingTransform(.hiraganaToKatakana, reverse: false) ?? self
    }

    var floatValue: CGFloat? {
        let numberFormatter = NumberFormatter()
        let number = numberFormatter.number(from: self)
        guard let floatValue = number?.floatValue else { return nil }
        return CGFloat(floatValue)
    }

    var intValue: Int? {
        guard let range = range(
            of: "[0-9]+", options: .regularExpression,
            range: range(of: self),
            locale: .current
        )
        else { return nil }
        return Int(self[range.lowerBound ..< range.upperBound])
    }
}

// MARK: - Encoding
extension String {
    func addingPercentEncoding() -> String? {
        let allowedCharacterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
    }

    func base64Encoded() -> String? {
        data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> Data? {
        let reminder = (4 - (self.count % 4)) % 4
        let string = self.padding(toLength: self.count + reminder,
                                  withPad: "=",
                                  startingAt: 0)
        return Data(base64Encoded: string)
    }
}

// MARK: - Decode
extension String {
    var convertToDictionary: [String: Any]? {
        guard let data = self.data(using: .utf8) else { return nil }
        do {
            let dict = try JSONSerialization.jsonObject(with: data, options: []) as?
                [String: Any] ?? nil
            return dict
        } catch _ {
            return nil
        }
    }
}

// MARK: - Localizing
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    func localizedWithArgs(_ args: CVarArg...) -> String {
        withVaList(args) {
            NSString(format: NSLocalizedString(self, comment: ""), arguments: $0) as String
        }
    }
}

// MARK: - Create values
extension String {
    static func getRandomString(length: Int) -> String {
        let baseString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890"
        return String((0 ..< length).map { _ in baseString.randomElement() ?? baseString[0] })
    }
}

//MARK: - Key  capture
extension String {
    var isBackspace: Bool {
        guard let char = string.cString(using: String.Encoding.utf8) else { return false }
        return strcmp(char, "\\b") == -92
    }
}
extension StringProtocol {
    var string: String { String(self) }
}
