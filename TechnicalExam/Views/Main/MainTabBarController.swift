//
//  MainTabBarController.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import UIKit

class MainTabBarController: BaseTabBarController {
    static let notificationForToolTip = Notification.Name("NotificationForToolTip")

    private var bounceAnimation: CAKeyframeAnimation = {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.2, 0.95, 1.02, 1.0]
        bounceAnimation.duration = TimeInterval(0.3)
        bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
        return bounceAnimation
    }()

    enum TabItem: CaseIterable, Hashable {
        case home

        var title: String {
            switch self {
            case .home: "Home"
            }
        }

        var icon: UIImage {
            switch self {
            case .home: .tabHomeUnselected
            }
        }

        var selectedIcon: UIImage {
            switch self {
            case .home: .tabHomeSelected
            }
        }

        var viewController: UIViewController {
            let viewController: UIViewController = {
                switch self {
                case .home: BaseNavigationController(rootViewController: HomeViewController())
            
                }
            }()
            viewController.tabBarItem = UITabBarItem(title: title, image: icon, selectedImage: selectedIcon)
            viewController.view.layoutIfNeeded()
            return viewController
        }
    }

    override func setupLayout() {
        let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = .black
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().tintColor = .white
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }

        setViewControllers(TabItem.allCases.map(\.viewController), animated: false)
    }

    override func setupBindings() {
    
    }

    override func setupActions() {
        delegate = self
        selectedIndex = 0
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let buttons = tabBar.subviews.filter { $0.className == "UITabBarButton" }
        guard let index = tabBar.items?.firstIndex(of: item),
              let imageView = buttons[index].subviews.compactMap({ $0 as? UIImageView }).first,
              let label = buttons[index].subviews.compactMap({ $0 as? UILabel }).first
        else { return }
        imageView.layer.add(bounceAnimation, forKey: nil)
        label.layer.add(bounceAnimation, forKey: nil)
    }
}

// MARK: - UITabBarControllerDelegate
extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController,
        animationControllerForTransitionFrom fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let fromIndex = viewControllers?.firstIndex(of: fromVC),
              let toIndex = viewControllers?.firstIndex(of: toVC)
        else { return nil }

        return MainTabTransition(fromVC: fromVC, fromIndex: fromIndex,
                                 toVC: toVC, toIndex: toIndex)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        guard let index = tabBarController.viewControllers?.firstIndex(of: viewController)
        else { return true }

        for viewController in tabBarController.viewControllers ?? [] {
            let targetViewController: BaseViewController?
            if let navigationController = viewController as? UINavigationController {
                targetViewController = navigationController.viewControllers.last as? BaseViewController
            } else {
                targetViewController = viewController as? BaseViewController
            }
            guard let shouldChangeHandler = targetViewController?.shouldChangeTabHandler else { continue }
            shouldChangeHandler { [weak self] shouldChange in
                guard shouldChange, let self else { return }
                if selectedIndex == index, let navigationController = viewController as? UINavigationController {
                    navigationController.popToRootViewController(animated: true)
                } else {
                    selectedIndex = index
                }
            }
            return false
        }

        return index != 1
    }
}
