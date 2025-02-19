//
//  IndicatorController.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import Lottie
import SuperEasyLayout
import UIKit

@MainActor
class IndicatorController: NSObject {
    enum CompletionType {
        case check
        case exclamation
        case cross
        case none
    }

    var indicatorWindow: UIWindow!
    weak var mainWindow: UIWindow?
    private var indicatorViewController: IndicatorViewController!
    private(set) var isShowing = false

    static var shared = IndicatorController()

    override init() {
        super.init()
        guard let scene = UIApplication.shared.connectedScenes.first(where: { [weak self] in
            guard let scene = $0 as? UIWindowScene,
                  let keyWindow = scene.windows.first(where: { $0.isKeyWindow })
            else { return false }
            self?.mainWindow = keyWindow
            return true
        }) as? UIWindowScene else { fatalError("Could not find scene.") }

        indicatorWindow = UIWindow(windowScene: scene)
        indicatorViewController = IndicatorViewController()
        indicatorWindow.rootViewController = indicatorViewController
        indicatorWindow.windowLevel = .alert
        indicatorWindow.backgroundColor = UIColor.clear
    }

    private func showIndicator(_ completionHandler: @escaping () -> Void) {
        if isShowing {
            completionHandler()
            return
        }
        isShowing = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            indicatorWindow?.isHidden = false
            indicatorViewController.view.alpha = 0.0
            indicatorViewController.startAnimation()
            UIView.animate(withDuration: 0.5, animations: {
                self.indicatorViewController.view.alpha = 1.0
            }, completion: { _ in
                completionHandler()
            })
        }
    }

    func show() async {
        await withCheckedContinuation { continuation in
            showIndicator() { continuation.resume() }
        }
    }

    private func dismissIndicator(_ type: CompletionType = .none, completionHandler: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if !isShowing {
                completionHandler?()
                return
            }
            indicatorViewController.endAnimation(type: type) {
                UIView.animate(withDuration: 0.5, animations: { [weak self] in
                    self?.indicatorViewController.view.alpha = 0.0
                }, completion: { [weak self] _ in
                    self?.indicatorWindow?.isHidden = true
                    self?.isShowing = false
                    completionHandler?()
                })
            }
        }
    }

    func dismiss(type: CompletionType = .none) async {
        await withCheckedContinuation { continuation in
            dismissIndicator(type) { continuation.resume() }
        }
    }

    func forceHidden() {
        indicatorWindow?.isHidden = true
        isShowing = false
    }
}

class IndicatorViewController: BaseViewController {
    private lazy var baseView = BaseView()
    private lazy var indicatorView = LottieAnimationView()

    override var needToSendLog: Bool { false }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        Self.rootViewController.getTopViewController().supportedInterfaceOrientations
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        Self.rootViewController.getTopViewController().preferredInterfaceOrientationForPresentation
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        Self.rootViewController.getTopViewController().preferredStatusBarStyle
    }

    override var prefersStatusBarHidden: Bool {
        Self.rootViewController.getTopViewController().prefersStatusBarHidden
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        Self.rootViewController.getTopViewController().prefersHomeIndicatorAutoHidden
    }
    
    override func setupLayout() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        addSubviews([
            indicatorView
        ])
    }
    
    func startAnimation() {
        indicatorView.bounds = CGRect(x: 0, y: 0, width: 84, height: 84)
        indicatorView.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        
        let waitingAnimation = LottieAnimation.named("waitingAnimation")
        indicatorView.animation = waitingAnimation
        indicatorView.loopMode = .repeat(.infinity)
        indicatorView.play()
    }

    func endAnimation(type: IndicatorController.CompletionType, completionHandler: (() -> Void)? = nil) {
        switch type {
        case .check:
            indicatorView.animation = LottieAnimation.named("checkingAnimation")
            indicatorView.loopMode = .playOnce
            indicatorView.play { completed in
                completionHandler?()
            } 
        case .cross:
            indicatorView.animation = LottieAnimation.named("invalidAnimation")
            indicatorView.loopMode = .playOnce
            indicatorView.play { completed in
                completionHandler?()
            }
        default:
            completionHandler?()
        }
    }
}
