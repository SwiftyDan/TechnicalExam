//
//  BaseTabController.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import Combine
import UIKit

class BaseTabBarController: UITabBarController {
    lazy var observers = [NSKeyValueObservation]()
    lazy var objectProtocols = [NSObjectProtocol]()
    lazy var cancellables = Set<AnyCancellable>()

    deinit {
        observers.removeAll()
        objectProtocols.removeAll()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupLayout()
        setupConstraints()
        setupBindings()
        setupActions()
    }

    func setupNavigation() {}
    func setupLayout() {}
    func setupConstraints() {}
    func setupBindings() {}
    func setupActions() {}
}
