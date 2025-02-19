//
//  UITextFieldHelper.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import UIKit

extension UITextField {
    var cursorPosition: Int? {
        get {
            guard let selectedTextRange else { return nil }
            return offset(from: beginningOfDocument, to: selectedTextRange.start)
        }
        set {
            guard let newValue, let newPosition = position(from: beginningOfDocument, offset: newValue)
            else { return }
            selectedTextRange = textRange(from: newPosition, to: newPosition)
        }
    }
}
