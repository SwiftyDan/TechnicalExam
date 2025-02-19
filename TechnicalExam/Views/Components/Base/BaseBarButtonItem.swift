//
//  BaseBarButtonItem.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import UIKit

class BaseBarButtonItem: UIBarButtonItem {
    var tapHandler: ((UIBarButtonItem) -> Void)?
    var tapHandlerAsync: ((UIBarButtonItem) async -> Void)?
    var highlightColor: UIColor? = UIColor(named: "disabled")
    private let isProcessingLock = NSLock()
    var isProcessing = false {
        willSet {
            isProcessingLock.lock()
        }
        didSet {
            isProcessingLock.unlock()
        }
    }

    private var button: UIButton?

    convenience init(barButtonSystemItem: UIBarButtonItem.SystemItem) {
        self.init(barButtonSystemItem: barButtonSystemItem,
                  target: nil,
                  action: nil)
    }

    convenience init(fixedSpaceWith space: CGFloat) {
        self.init(barButtonSystemItem: .fixedSpace)
        width = space
    }

    convenience init(image: UIImage?, isUsingImageTemplate: Bool = true) {
        guard let image else {
            fatalError("Could not get image.")
        }
        let width = [image.size.width, image.size.height, 44.0].max() ?? 44.0
        let buttonSize = CGSize(width: width, height: 44.0)
        let button = BaseButton(frame: CGRect(origin: CGPoint.zero, size: buttonSize))
        button.colorStyle = .text
        if isUsingImageTemplate {
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.intrinsicContentSizeOverride = buttonSize
        self.init(customView: button)
        button.addTarget(self, action: #selector(tappedButton(_:)), for: .touchUpInside)
        self.button = button
    }

    convenience init(title: String, margin: CGFloat? = nil) {
        let button = BaseButton()
        button.colorStyle = .text
        button.font = .body1
        button.text = title
        button.sizeToFit()
        let buttonWidth = title.getAttributedString(with: button.font).width()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.intrinsicContentSizeOverride = CGSize(width: buttonWidth + (margin ?? 10.0),
                                                     height: 44.0)
        self.init(customView: button)
        button.addTarget(self, action: #selector(tappedButton(_:)), for: .touchUpInside)
        self.button = button
    }

    override var isEnabled: Bool {
        get { super.isEnabled }
        set {
            if let button {
                button.isEnabled = newValue
            }
            super.isEnabled = newValue
            if isProcessing, newValue == false {
                isEnabledBackup = false
            }
        }
    }

    private var isEnabledBackup: Bool = true

    override var tintColor: UIColor? {
        get { button?.tintColor }
        set { button?.tintColor = newValue }
    }

    func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        button?.setTitleColor(color, for: state)
    }

    func setImage(_ image: UIImage?, for state: UIControl.State) {
        button?.setImage(image, for: state)
    }

    func addShadow(color: UIColor? = .black,
                   alpha: CGFloat = 1,
                   offset: CGSize = .zero,
                   blur: CGFloat = 0,
                   spread: CGFloat = 0) {
        button?.addShadow(color: color, alpha: alpha, offset: offset, blur: blur, spread: spread)
    }

    func addShadow(color: UIColor? = .black,
                   alpha: CGFloat = 1,
                   offsetX: CGFloat = 0,
                   offsetY: CGFloat = 0,
                   blur: CGFloat = 0,
                   spread: CGFloat = 0) {
        button?.addShadow(color: color, alpha: alpha, offsetX: offsetX, offsetY: offsetY, blur: blur, spread: spread)
    }

    @objc func tappedButton(_: UIBarButtonItem) {
        if isProcessing {
            return
        }
        isEnabled = false
        isProcessing = true
        if let tapHandlerAsync {
            Task { [weak self] in
                guard let self else { return }
                await tapHandlerAsync(self)
                isProcessing = false
                if isEnabledBackup == false {
                    isEnabledBackup = true
                } else {
                    isEnabled = true
                }
            }
            return
        }
        tapHandler?(self)
        isProcessing = false
        if isEnabledBackup == false {
            isEnabledBackup = true
        } else {
            isEnabled = true
        }
    }
}
