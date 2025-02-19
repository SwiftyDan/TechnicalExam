//
//  UIImageHelpers.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import UIKit

extension UIImage {
    func cropImage(toRect cropRect: CGRect) -> UIImage? {
        let cropArea = CGRect(x: cropRect.origin.x * scale,
                              y: cropRect.origin.y * scale,
                              width: cropRect.size.width * scale,
                              height: cropRect.size.height * scale)

        guard let croppedImageRef: CGImage = cgImage?.cropping(to: cropArea) else {
            return nil
        }
        return UIImage(cgImage: croppedImageRef,
                       scale: scale,
                       orientation: imageOrientation)
    }

    func resize(size: CGSize, scale: CGFloat = 0.0) -> UIImage? {
        let widthRatio = size.width / self.size.width
        let heightRatio = size.height / self.size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio

        let resizedSize = CGSize(width: self.size.width * ratio,
                                 height: self.size.height * ratio)

        UIGraphicsBeginImageContextWithOptions(resizedSize, false, scale)
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }

    func flipVertical() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let imageRef = cgImage
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: 0)
        context?.scaleBy(x: 1.0, y: 1.0)
        context?.draw(imageRef!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let flipVerticalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return flipVerticalImage!
    }

    func flipHorizontal() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let imageRef = cgImage
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: size.width, y: size.height)
        context?.scaleBy(x: -1.0, y: -1.0)
        context?.draw(imageRef!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let flipHorizontalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return flipHorizontalImage!
    }
}
