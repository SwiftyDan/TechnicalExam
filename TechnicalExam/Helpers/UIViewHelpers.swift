//
//  UIViewHelpers.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import SuperEasyLayout
import UIKit

extension UIView {
    @discardableResult
    func addSubviews(_ views: [UIView]) -> UIView {
        views.forEach { addSubview($0) }
        return self
    }

    @discardableResult
    func removeSubviews(where handler: ((UIView) -> Bool)? = nil) -> UIView {
        subviews.forEach { if handler?($0) ?? false { $0.removeFromSuperview() } }
        return self
    }

    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }

    func getSnapshot(from rect: CGRect? = nil, expectSize: CGSize? = nil) -> UIView? {
        guard let image = getSnapShotImage(expectSize: expectSize) else {
            return nil
        }
        guard let rect else { return UIImageView(image: image) }

        let imageView = UIImageView(frame: rect)
        imageView.image = image.cropImage(toRect: rect)
        imageView.clipsToBounds = true
        return imageView
    }

    private func getSnapShotImage(expectSize: CGSize? = nil) -> UIImage? {
        if let expectSize {
            UIGraphicsBeginImageContextWithOptions(expectSize, false, UIScreen.main.scale)
        } else if bounds.height == 0 || bounds.width == 0 {
            return nil
        } else {
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshot
    }

    func addShadow(color: UIColor? = .black,
                   alpha: CGFloat = 1,
                   offsetX: CGFloat = 0,
                   offsetY: CGFloat = 0,
                   blur: CGFloat = 0,
                   spread: CGFloat = 0) {
        addShadow(
            color: color,
            alpha: alpha,
            offset: CGSize(width: offsetX, height: offsetY),
            blur: blur,
            spread: spread
        )
    }

    func addShadow(color: UIColor? = .black,
                   alpha: CGFloat = 1,
                   offset: CGSize = .zero,
                   blur: CGFloat = 0,
                   spread: CGFloat = 0) {
        layer.shadowColor = color?.cgColor
        layer.shadowOpacity = Float(alpha)
        layer.shadowOffset = offset
        layer.shadowRadius = blur / 2
        if spread == 0 {
            layer.shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }

    func removeShadow() {
        layer.shadowColor = nil
        layer.shadowOpacity = 0
        layer.shadowOffset = .zero
        layer.shadowRadius = 0
        layer.shadowPath = nil
    }

    func setLayoutEqualTo(_ view: UIView, inset: CGFloat) {
        top == view.top + inset
        left == view.left + inset
        right == view.right - inset
        bottom == view.bottom - inset
    }

    func setLayoutEqualTo(_ view: UIView, margins: UIEdgeInsets = .zero) {
        top == view.top + margins.top
        left == view.left + margins.left
        right == view.right - margins.right
        bottom == view.bottom - margins.bottom
    }

    func getHeightUsingWidth(_ ratio: CGFloat = 9/16 , inset: CGFloat = 0) -> CGFloat {
        let desiredWidth = self.frame.width - inset
        return (ratio * desiredWidth)
    }
    
    func makeCornerRadiusHole(rect: CGRect, cornerRadius: CGFloat, fillColor: CGColor) {
        makeCornerRadiiHole(
            rect: rect,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius),
            fillColor: fillColor
        )
    }
    
    func makeCornerRadiiHole(rect: CGRect, cornerRadii: CGSize, fillColor: CGColor) {
        let entireViewPath = UIBezierPath(rect: bounds)
        let roundedRectPath = UIBezierPath(roundedRect: rect,
                                           byRoundingCorners: .allCorners,
                                           cornerRadii: cornerRadii)
        
        entireViewPath.append(roundedRectPath)
        entireViewPath.usesEvenOddFillRule = true

        let maskLayer = CAShapeLayer()
        maskLayer.path = entireViewPath.cgPath
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        maskLayer.fillColor = fillColor
        layer.mask = maskLayer
    }
}
