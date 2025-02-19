//
//  BaseNavigationController.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import UIKit

class BaseNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override var childForStatusBarStyle: UIViewController? { viewControllers.last }
    override var childForStatusBarHidden: UIViewController? { viewControllers.last }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        viewControllers.last?.supportedInterfaceOrientations ?? .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        viewControllers.last?.preferredInterfaceOrientationForPresentation ?? .portrait
    }

    var isStatusHidden = false

    override init(rootViewController: UIViewController) {
        super.init(navigationBarClass: BaseNavigationBar.self, toolbarClass: nil)
        viewControllers = [rootViewController]
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience init(rootViewController: UIViewController,
                     navigationBarClass: AnyClass?,
                     toolbarClass: AnyClass?) {
        self.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        viewControllers = [rootViewController]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        interactivePopGestureRecognizer?.delegate = self
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        if let shouldPopHandler = (viewControllers.last as? BaseViewController)?.shouldPopViewControllerHandler {
            shouldPopHandler { shouldChange in
                guard shouldChange else { return }
                super.popViewController(animated: animated)
            }
            return nil
        }
        return super.popViewController(animated: animated)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension BaseNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        guard
            viewControllers.count > 1,
            let lastViewController = viewControllers.last
        else {
            return false
        }
        if let viewController = lastViewController as? BaseViewController {
            return viewController.canPopWithSwipe
        }
        return false
    }
}
