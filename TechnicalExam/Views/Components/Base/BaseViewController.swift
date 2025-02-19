//
//  BaseViewController.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import Combine
import SuperEasyLayout
import UIKit

protocol ViewControllerKeyboardAppear: AnyObject {
    func willShowKeyboard(frame: CGRect, duration: TimeInterval, curve: UIView.AnimationCurve)
    func willHideKeyboard(frame: CGRect, duration: TimeInterval, curve: UIView.AnimationCurve)
}

class BaseViewController: UIViewController {
    var needToSendLog: Bool { true }
    var canPopWithSwipe: Bool { true }
    var appWillResignActiveHandler: ((Notification) -> Void)? { didSet {
        objectProtocols.append(
            NotificationCenter.default.addObserver(
                forName: UIApplication.willResignActiveNotification,
                object: nil,
                queue: .main,
                using: { [weak self] in self?.appWillResignActiveHandler?($0) }
            )
        )
    } }

    var appDidBecomeActiveHandler: ((Notification) -> Void)? { didSet {
        objectProtocols.append(
            NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main,
                using: { [weak self] in self?.appDidBecomeActiveHandler?($0) }
            )
        )
    } }

    var appWillEnterForegroundHandler: ((Notification) -> Void)? { didSet {
        objectProtocols.append(
            NotificationCenter.default.addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil,
                queue: .main,
                using: { [weak self] in self?.appWillEnterForegroundHandler?($0) }
            )
        )
    } }

    override var preferredStatusBarStyle: UIStatusBarStyle { .default }
    override var prefersStatusBarHidden: Bool { false }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }

    lazy var observers = [NSKeyValueObservation]()
    lazy var objectProtocols = [NSObjectProtocol]()
    lazy var cancellables = Set<AnyCancellable>()
    private lazy var fadeInAnimator = FadeInAnimator()
    var shouldPopViewControllerHandler: ((@escaping (Bool) -> Void) -> Void)?
    var shouldChangeTabHandler: ((@escaping (Bool) -> Void) -> Void)?

    weak var keyboardAppear: ViewControllerKeyboardAppear? { didSet {
        objectProtocols.append(contentsOf: [
            NotificationCenter.default.addObserver(
                forName: UIApplication.keyboardWillShowNotification,
                object: nil,
                queue: .main,
                using: { [weak self] in self?.notificationForWillShowKeyboard($0) }
            ),
            NotificationCenter.default.addObserver(
                forName: UIApplication.keyboardWillHideNotification,
                object: nil,
                queue: .main,
                using: { [weak self] in self?.notificationForWillHideKeyboard($0) }
            )
        ])
    } }

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

    

    func presentWhileFadeIn(_ presentViewController: UIViewController,
                            style: UIModalPresentationStyle,
                            completion: (() -> Void)? = nil) {
        presentViewController.modalPresentationStyle = style
        presentViewController.transitioningDelegate = fadeInAnimator
        present(presentViewController, animated: true, completion: completion)
    }
}

// MARK: - Notifications
extension BaseViewController {
    private func notificationForWillShowKeyboard(_ notification: Notification) {
        guard
            let delegate = keyboardAppear,
            let userInfo = notification.userInfo,
            let endFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let durationNumber = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
            let curveNumber = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
            let curve = UIView.AnimationCurve(rawValue: curveNumber.intValue)
        else {
            return
        }
        let endFrame = endFrameValue.cgRectValue
        let duration = durationNumber.doubleValue

        delegate.willShowKeyboard(frame: endFrame, duration: duration, curve: curve)
    }

    private func notificationForWillHideKeyboard(_ notification: Notification) {
        guard
            let delegate = keyboardAppear,
            let userInfo = notification.userInfo,
            let endFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let durationNumber = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
            let curveNumber = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
            let curve = UIView.AnimationCurve(rawValue: curveNumber.intValue)
        else {
            return
        }
        let endFrame = endFrameValue.cgRectValue
        let duration = durationNumber.doubleValue

        delegate.willHideKeyboard(frame: endFrame, duration: duration, curve: curve)
    }
}

extension UIView.AnimationCurve {
    var animationOptions: UIView.AnimationOptions {
        switch self {
        case .easeIn: return [.curveEaseIn]
        case .easeOut: return [.curveEaseOut]
        case .easeInOut: return [.curveEaseInOut]
        case .linear: return [.curveLinear]
        @unknown default: return []
        }
    }
}
