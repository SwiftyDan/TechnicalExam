//
//  UIViewControllerHelpers.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import SafariServices
import UIKit

extension UIViewController {
    @frozen enum ModalResult<Success> {
        case success(Success)
        case cancel
    }

    static var rootViewController: UIViewController!

    func addSubviews(_ views: [UIView]) {
        view.addSubviews(views)
    }

    func openSafari(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .formSheet
        safariVC.dismissButtonStyle = .close
        safariVC.preferredControlTintColor = UIColor(named: "backgroud")
        present(safariVC, animated: true)
    }

    func dismissAsync(animated: Bool) async {
        await withCheckedContinuation { [weak self] continuation in
            self?.dismiss(animated: animated) {
                continuation.resume()
            }
        }
    }

    func dismissAllModal(animated: Bool = true, completionHandler: (() -> Void)? = nil) {
        guard let presentedViewController else {
            completionHandler?()
            return
        }
        if let snapshotView = presentedViewController
            .view.snapshotView(afterScreenUpdates: false) {
            presentedViewController.view.addSubview(snapshotView)
            presentedViewController.modalTransitionStyle = .coverVertical
        }
        if !isBeingDismissed {
            dismiss(animated: animated, completion: completionHandler)
        } else {
            completionHandler?()
        }
    }

    func getTopViewController() -> UIViewController {
        switch self {
        case is UINavigationController:
            let navigationController = self as? UINavigationController
            return navigationController!.viewControllers.last.unsafelyUnwrapped.getTopViewController()
        default:
            break
        }
        if let modalViewController = presentedViewController {
            switch modalViewController {
            case is UIAlertController:
                return self
            default:
                return modalViewController.getTopViewController()
            }
        }
        return self
    }

    func setNavigationBarDefaultStyle(backgroundColor: UIColor = .systemBackground) {
        let appearance = UINavigationBarAppearance()
        appearance.setBackIndicatorImage(.backArrow, transitionMaskImage: .backArrow)
        appearance.backgroundColor = backgroundColor
        appearance.shadowColor = .clear

        setNavigationBarAppearance(appearance)
        navigationController?.navigationBar.tintColor = .black

        navigationItem.backButtonTitle = ""
    }

    func setNavigationBarAppearance(_ appearance: UINavigationBarAppearance) {
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
}
