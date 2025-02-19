//
//  AppColors.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import UIKit

enum ColorStyle: Hashable {
    typealias Main = UIColor
    typealias Disabled = UIColor
    typealias Ripple = UIColor
    typealias Text = UIColor
    typealias DisabledText = UIColor

    case primary
    case secondary
    case tertiary
    case accent
    case text
    case textSecondary
    case disabled
    case custom(Main, Disabled, Ripple, Text, DisabledText)

    var backgroundColor: UIColor {
        switch self {
        case .primary: .black
        case .secondary: .blue
        case .tertiary: .white
        case .accent: .gray
        case .text, .textSecondary: .clear
        case .disabled: .systemBlue
        case .custom(let main, _, _, _, _): main
        }
    }

    var disabledBackgroundColor: UIColor {
        switch self {
        case .primary, .accent, .secondary: .gray
        case .tertiary: .white
        case .text, .textSecondary: .clear
        case .custom(_, let disabled, _, _, _): disabled
        case .disabled: .gray
        }
    }

    var rippleColor: UIColor {
        switch self {
        case .primary: .gray
        case .secondary: .gray
        case .tertiary: .gray
        case .accent: .gray
        case .text, .textSecondary: .gray
        case .custom(_, _, let ripple, _, _): ripple
        case .disabled: .clear
        }
    }

    var textColor: UIColor {
        switch self {
        case .primary, .accent, .disabled: .white
        case .secondary: .black
        case .tertiary: .black
        case .text: .black
        case .textSecondary: .gray
        case .custom(_, _, _, let text, _): text
        }
    }

    var disabledTextColor: UIColor {
        switch self {
        case .primary, .secondary, .accent, .disabled: .white
        case .tertiary: .black
        case .text, .textSecondary: .black
        case .custom(_, _, _, _, let disabledText): disabledText
        }
    }
}
