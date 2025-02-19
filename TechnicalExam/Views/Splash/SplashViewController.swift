//
//  SplashViewController.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import SuperEasyLayout
import UIKit

@MainActor
class SplashViewController: BaseViewController {
    static let notificationForShowHome = Notification.Name("NotificationForShowHome")
    static let notificationForLogout = Notification.Name("NotificationForLogout")
    static let notificationForOpenDeepLink = Notification.Name("NotificationForOpenDeepLink")

    private lazy var centerView: BaseView = {
        let view = BaseView()
        view.backgroundColor = .black
        return view
    }()

    private lazy var centerLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 17)
        view.textColor = .black
        view.text = "ロゴ"
        return view
    }()

    private lazy var advertiseImageView: UIImageView = {
        let view = UIImageView()
        view.isHidden = true
        return view
    }()

    private lazy var loadingImageView: UIImageView = {
        let view = UIImageView(image: .loadingSmall)
        view.isHidden = true
        return view
    }()

    private let viewModel = SplashViewModel()
    private var afterOpenHomeHandlers: [(MainTabBarController) -> Void] = []

    override func setupLayout() {
        view.backgroundColor = .white

        addSubviews([
            centerView.addSubviews([
                centerLabel,
            ]),
            advertiseImageView,
            loadingImageView
        ])
    }

    override func setupConstraints() {
        centerView.centerX == view.centerX
        centerView.width == 180
        centerView.centerY == view.centerY
        centerView.height == 180

        centerLabel.centerX == centerView.centerX
        centerLabel.centerY == centerView.centerY

        advertiseImageView.left == view.left
        advertiseImageView.right == view.right
        advertiseImageView.top == view.topMargin
        advertiseImageView.bottom == loadingImageView.bottom - 32

        loadingImageView.centerX == view.centerX
        loadingImageView.width == 32
        loadingImageView.height == 32
        loadingImageView.bottom == view.bottomMargin - 27
    }

    override func setupBindings() {
        viewModel.$appState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] appState in
                guard let appState else { return }
                switch appState {
                case .needToLogin:
                    Task { [weak self] in
                        try self?.viewModel.clearData()
                        self?.showLogin()
                    }
               
                case .showHome:
                    Task { [weak self] in
                        await self?.showHome()
                    }
                }
            }
            .store(in: &cancellables)
        objectProtocols.append(contentsOf: [
            NotificationCenter.default.addObserver(
                forName: Self.notificationForShowHome,
                object: nil,
                queue: .main,
                using: { [weak self] _ in
                    Task { [weak self] in await self?.showHome() }
                }
            ),
            NotificationCenter.default.addObserver(
                forName: Self.notificationForLogout,
                object: nil,
                queue: .main,
                using: { [weak self] _ in
                    Task { [weak self] in await self?.logout() }
                }
            ),
        
        ])
    }

    override func setupActions() {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await viewModel.checkAppState()
            } catch {
               print("Error")
            }
        }
    }

    
    private func showLogin() {
        let loginViewController = LoginViewController()
        let navigationController = BaseNavigationController(rootViewController: loginViewController)
        presentWhileFadeIn(navigationController, style: .overFullScreen)
    }

    private func showHome() async {
        let mainTabViewController = MainTabBarController()
        mainTabViewController.modalPresentationStyle = .fullScreen

        let presentHome = { [weak self] in
            self?.present(mainTabViewController, animated: true) { [weak self] in
                for handler in self?.afterOpenHomeHandlers ?? [] {
                    handler(mainTabViewController)
                }
                self?.afterOpenHomeHandlers.removeAll()
            }
        }

        guard let presentedViewController else {
            presentHome()
            return
        }
        presentedViewController.dismiss(animated: true) {
            presentHome()
        }
    }

    private func hiddenAdvertisement() {
        advertiseImageView.isHidden = true
        loadingImageView.isHidden = true
    }

    private func logout() async {
        try? viewModel.clearData()
        if let presentedViewController {
            if let navigationController = presentedViewController as? UINavigationController {
                navigationController.popToRootViewController(animated: true)
            } else {
                presentedViewController.dismiss(animated: false) { [weak self] in
                    self?.showLogin()
                }
            }
        } else {
            showLogin()
        }
    }
}
