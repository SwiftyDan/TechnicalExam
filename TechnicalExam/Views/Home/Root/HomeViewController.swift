//
//  HomeViewController.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import SuperEasyLayout
import UIKit
import Lottie

class HomeViewController: BaseViewController {
    private lazy var notificationButton = BaseBarButtonItem(title: "Logout")

    private lazy var welcomeImageView: LottieAnimationView = {
        let view = LottieAnimationView()
        let waitingAnimation = LottieAnimation.named("welcomeAnimation")
        view.animation = waitingAnimation
        view.loopMode = .repeat(.infinity)
        return view
    }()

    private lazy var centerLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 17)
        view.textColor = .black
        view.text = "Welcome User!"
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
   

    override func setupNavigation() {
        let appearance = UINavigationBarAppearance()
        appearance.setBackIndicatorImage(.backArrow, transitionMaskImage: .backArrow)
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear

        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .black

        navigationItem.backButtonTitle = ""

        navigationItem.rightBarButtonItem = notificationButton
    }


    override func setupLayout() {
        view.backgroundColor = .systemGroupedBackground
        addSubviews([
            centerLabel,
            welcomeImageView,
            advertiseImageView,
            loadingImageView
        ])
    }

    override func setupConstraints() {
        welcomeImageView.centerX == view.centerX
        welcomeImageView.width == 180
        welcomeImageView.centerY == view.centerY
        welcomeImageView.height == 180

        centerLabel.centerX == welcomeImageView.centerX
        centerLabel.bottom == welcomeImageView.top + 10

        advertiseImageView.left == view.left
        advertiseImageView.right == view.right
        advertiseImageView.top == view.topMargin
        advertiseImageView.bottom == loadingImageView.bottom - 32

        loadingImageView.centerX == view.centerX
        loadingImageView.width == 32
        loadingImageView.height == 32
        loadingImageView.bottom == view.bottomMargin - 27
    }

    override func setupActions() {
        notificationButton.tapHandlerAsync = { [weak self] _ in
            self?.showLogin()
        }
        welcomeImageView.play()
    }

    private func showLogin() {
        NotificationCenter.default.post(name: SplashViewController.notificationForLogout, object: nil)
    }
}
