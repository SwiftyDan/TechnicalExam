//
//  BaseNavigationBar.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import SuperEasyLayout
import UIKit

class BaseNavigationBar: UINavigationBar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        setupLayout()
        setupConstraints()
        setupBindings()
        setupActions()
    }

    func setupLayout() {}
    func setupConstraints() {}
    func setupBindings() {}
    func setupActions() {}

    override func layoutSubviews() {
        super.layoutSubviews()

        subviews.filter { $0.className == "_UINavigationBarContentView" }.forEach { subview in
            let margins = subview.layoutMargins
            var frame = subview.frame
            frame.origin.x = -margins.left
            frame.size.width += (margins.left + margins.right - 8.0)
            subview.frame = frame

            guard let backButton = subview.subviews.filter({ $0.className == "_UIButtonBarButton" }).first
            else { return }
            setBackButtonConstraints(backButton, superview: subview)
        }
    }

    private func setBackButtonConstraints(_ backButton: UIView, superview: UIView) {
        guard let targetConstraint = backButton.constraints.filter({ $0.identifier == "Mask_Leading_Leading" }).first,
              targetConstraint.isActive,
              backButton.constraints.filter({ $0.identifier == "NewBackButtonLeftConstraint" }).isEmpty
        else { return }

        targetConstraint.isActive = false
        let constraint = backButton.left ! .required == superview.left + 16
        backButton.width ! .required == 44
        constraint.identifier = "NewBackButtonLeftConstraint"
    }
}
