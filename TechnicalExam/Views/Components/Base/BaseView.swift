//
//  BaseView.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import Combine
import UIKit

class BaseView: UIView {
    lazy var observers = [NSKeyValueObservation]()
    lazy var cancellables = Set<AnyCancellable>()

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
}
