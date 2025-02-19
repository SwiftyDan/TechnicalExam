//
//  MainTabTransition.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import UIKit

final class MainTabTransition: NSObject, UIViewControllerAnimatedTransitioning {
    let transitionDuration: TimeInterval = 0.3
    let fromVC: UIViewController
    let toVC: UIViewController
    let fromIndex: Int
    let toIndex: Int

    init(fromVC: UIViewController, fromIndex: Int, toVC: UIViewController, toIndex: Int) {
        self.fromVC = fromVC
        self.fromIndex = fromIndex
        self.toVC = toVC
        self.toIndex = toIndex
    }

    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = fromVC.view,
              let toView = toVC.view
        else {
            transitionContext.completeTransition(false)
            return
        }

        let diff: CGFloat = 30.0
        let fromTransform = CGAffineTransform(translationX: toIndex > fromIndex ? -diff : diff, y: 0.0)
        let toTransform = CGAffineTransform(translationX: toIndex > fromIndex ? diff : -diff, y: 0.0)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                transitionContext.completeTransition(false)
                return
            }
            transitionContext.containerView.addSubview(toView)
            toView.transform = toTransform
            toView.alpha = 0.0
            toView.layoutIfNeeded()
            UIView.animateKeyframes(withDuration: self.transitionDuration, delay: 0.0, options: []) {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
                    fromView.transform = fromTransform
                    fromView.alpha = 0.0
                }
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
                    toView.transform = .identity
                    toView.alpha = 1.0
                }
            } completion: { success in
                fromView.transform = .identity
                fromView.alpha = 1.0
                fromView.removeFromSuperview()
                transitionContext.completeTransition(success)
            }
        }
    }
}
