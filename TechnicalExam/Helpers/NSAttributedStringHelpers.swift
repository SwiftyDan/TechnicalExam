//
//  NSAttributedStringHelpers.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import UIKit

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGFloat {
        let constraintSize = CGSize(width: width, height: .greatestFiniteMagnitude / 2.0)
        let boundingBox = boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, context: nil)

        return roundTillHalf(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGFloat {
        let constraintSize = CGSize(width: .greatestFiniteMagnitude / 2.0, height: height)
        let boundingBox = boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, context: nil)

        return roundTillHalf(boundingBox.width)
    }

    private func roundTillHalf(_ value: CGFloat) -> CGFloat {
        if value - CGFloat(Int(value)) >= 0.5 {
            CGFloat(Int(value)) + 1
        } else {
            CGFloat(Int(value)) + 0.5
        }
    }
 
}

extension NSMutableAttributedString {
    @discardableResult
    func setFont(with font: UIFont, range: NSRange? = nil) -> Self {
        addAttribute(NSAttributedString.Key.font,
                     value: font,
                     range: range ?? NSRange(location: 0, length: string.count))
        return self
    }

    @discardableResult
    func setKern(_ kern: CGFloat, range: NSRange? = nil) -> Self {
        addAttribute(NSAttributedString.Key.kern,
                     value: kern,
                     range: range ?? NSRange(location: 0, length: string.count))
        return self
    }

    @discardableResult
    func setForegroundColor(_ color: UIColor?, range: NSRange? = nil) -> Self {
        guard let color else { return self }
        addAttribute(NSAttributedString.Key.foregroundColor,
                     value: color,
                     range: range ?? NSRange(location: 0, length: string.count))
        return self
    }

    @discardableResult
    func setParagraphStyle(_ style: NSParagraphStyle, range: NSRange? = nil) -> Self {
        addAttribute(NSAttributedString.Key.paragraphStyle,
                     value: style,
                     range: range ?? NSRange(location: 0, length: string.count))
        return self
    }

    @discardableResult
    func setBaselineOffsetStyle(_ value: Double, range: NSRange? = nil) -> Self {
        addAttribute(NSAttributedString.Key.baselineOffset,
                     value: value,
                     range: range ?? NSRange(location: 0, length: string.count))
        return self
    }

    @discardableResult
    func setUnderlineStyle(_ style: NSUnderlineStyle, range: NSRange? = nil) -> Self {
        addAttribute(NSAttributedString.Key.underlineStyle,
                     value: style.rawValue,
                     range: range ?? NSRange(location: 0, length: string.count))
        return self
    }

    @discardableResult
    func setStrokeColor(_ color: UIColor, range: NSRange? = nil) -> Self {
        addAttribute(NSAttributedString.Key.strokeColor,
                     value: color,
                     range: range ?? NSRange(location: 0, length: string.count))
        return self
    }

    @discardableResult
    func insertImage(_ image: UIImage?, position: Int = 0,
                     origin: CGPoint? = nil, size: CGSize? = nil,
                     color: UIColor? = nil) -> Self {
        let attachment = NSTextAttachment()
        attachment.image = image
        let imageFrame = CGRect(origin: origin ?? .zero,
                                size: size ?? image?.size ?? .zero)
        attachment.bounds = imageFrame
        let attributedImage = NSMutableAttributedString(attachment: attachment)
        guard let color else {
            insert(attributedImage, at: position)
            return self
        }
        attributedImage.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: 1))
        insert(attributedImage, at: position)
        return self
    }
}

extension NSMutableParagraphStyle {
    @discardableResult
    func setLineSpacing(_ lineSpacing: CGFloat) -> Self {
        self.lineSpacing = lineSpacing
        return self
    }

    @discardableResult
    func setLineHeight(_ lineHeight: CGFloat) -> Self {
        minimumLineHeight = lineHeight
        maximumLineHeight = lineHeight
        return self
    }

    @discardableResult
    func setLineBreakMode(_ lineBreakMode: NSLineBreakMode) -> Self {
        self.lineBreakMode = lineBreakMode
        return self
    }

    @discardableResult
    func setAlignment(_ alignment: NSTextAlignment) -> Self {
        self.alignment = alignment
        return self
    }
}

func + (lValue: NSMutableAttributedString, rValue: NSAttributedString) -> NSMutableAttributedString {
    lValue.append(rValue)
    return lValue
}

private let swizzling: (AnyClass, Selector, Selector) -> Void = { forClass, originalSelector, swizzledSelector in
    guard let originalMethod = class_getInstanceMethod(forClass, originalSelector),
          let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector) else {
        return
    }
    method_exchangeImplementations(originalMethod, swizzledMethod)
}

extension NSAttributedString.Key {
    static var customUnderline = NSAttributedString.Key("customUnderline")
}

extension NSLayoutManager {
    // MARK: - Properties

    // swiftlint:disable line_length
    static let initSwizzling: Void = {
        let originalSelector = #selector(drawUnderline(forGlyphRange:underlineType:baselineOffset:lineFragmentRect:lineFragmentGlyphRange:containerOrigin:))
        let swizzledSelector = #selector(swizzled_drawUnderline(forGlyphRange:underlineType:baselineOffset:lineFragmentRect:lineFragmentGlyphRange:containerOrigin:))
        swizzling(NSLayoutManager.self, originalSelector, swizzledSelector)
    }()

    // MARK: - Functions

    // swiftlint:disable function_parameter_count
    @objc
    func swizzled_drawUnderline(forGlyphRange glyphRange: NSRange,
                                underlineType underlineVal: NSUnderlineStyle,
                                baselineOffset: CGFloat,
                                lineFragmentRect lineRect: CGRect,
                                lineFragmentGlyphRange lineGlyphRange: NSRange,
                                containerOrigin: CGPoint) {
        guard needCustomizeUnderline(underlineType: underlineVal) else {
            swizzled_drawUnderline(forGlyphRange: glyphRange,
                                   underlineType: underlineVal,
                                   baselineOffset: baselineOffset,
                                   lineFragmentRect: lineRect,
                                   lineFragmentGlyphRange: lineGlyphRange,
                                   containerOrigin: containerOrigin)
            return
        }

        let fontHeight = getFontHeight(in: glyphRange) ?? lineRect.height
        let attributes = textStorage?.attributes(at: 0, effectiveRange: nil)
        let space: CGFloat = attributes?[.customUnderline] as? CGFloat ?? 0.0
        let heightOffset = fontHeight / 2.0 + space
        drawStrikethrough(forGlyphRange: glyphRange,
                          strikethroughType: underlineVal,
                          baselineOffset: baselineOffset,
                          lineFragmentRect: lineRect,
                          lineFragmentGlyphRange: lineGlyphRange,
                          containerOrigin: CGPoint(x: containerOrigin.x,
                                                   y: heightOffset))
    }

    // MARK: - Private functions

    private func needCustomizeUnderline(underlineType underlineVal: NSUnderlineStyle) -> Bool {
        guard underlineVal == NSUnderlineStyle.single else {
            return false
        }
        let attributes = textStorage?.attributes(at: 0, effectiveRange: nil)
        guard let isCustomUnderline = attributes?.keys.contains(.customUnderline), isCustomUnderline else {
            return false
        }
        return true
    }

    private func getFontHeight(in glyphRange: NSRange) -> CGFloat? {
        let location = characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil).location
        guard let font = textStorage?.attribute(.font, at: location, effectiveRange: nil) as? UIFont else {
            return nil
        }
        return font.capHeight
    }
}
