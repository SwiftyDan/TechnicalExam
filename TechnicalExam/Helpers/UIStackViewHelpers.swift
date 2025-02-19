//
//  UIStackViewHelpers.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import UIKit

extension UIStackView {
    @discardableResult
    func addArrangedSubviews(_ views: [UIView]) -> UIStackView {
        views.forEach { addArrangedSubview($0) }
        return self
    }

    @discardableResult
    func removeArrangedSubviews(where handler: (() -> Bool)? = nil) -> UIStackView {
        arrangedSubviews.forEach { if handler?() ?? true { removeArrangedSubview($0) } }
        return self
    }
}
