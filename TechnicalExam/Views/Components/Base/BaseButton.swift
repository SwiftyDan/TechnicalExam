//
//  BaseButton.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import Combine
import UIKit

class BaseButton: UIButton {
    class RippleBackView: UIView {
        private var rippleView: UIView? {
            didSet {
                oldValue?.removeFromSuperview()
            }
        }

        var isRippleAnimating = false
        var needDeleteRipple = false

        var highlightColor: UIColor? = .black.withAlphaComponent(0.3)

        deinit {
            rippleView = nil
        }

        func showRipple(on point: CGPoint? = nil) {
            let rippleView = UIView(frame: CGRect(origin: CGPoint.zero,
                                                  size: CGSize(width: 10.0, height: 10.0)))
            rippleView.backgroundColor = highlightColor
            rippleView.layer.cornerRadius = 5.0
            rippleView.alpha = 0.5
            rippleView.isUserInteractionEnabled = false
            addSubview(rippleView)
            self.rippleView = rippleView
            let scale: CGFloat
            if let point,
               let superview {
                rippleView.center = convert(point, from: superview)
                scale = bounds.width / 3.0
            } else {
                rippleView.center = CGPoint(x: bounds.midX, y: bounds.midY)
                scale = bounds.width / 3.0
            }

            isRippleAnimating = true
            UIView.animate(withDuration: 0.33, animations: {
                rippleView.transform = CGAffineTransform(scaleX: scale, y: scale)
                rippleView.alpha = 0.3
            }, completion: { [weak self] _ in
                self?.isRippleAnimating = false
                if self?.needDeleteRipple ?? false {
                    self?.dismissRipple()
                }
            })
        }

        @discardableResult
        func dismissRipple() -> Bool {
            guard let rippleView else {
                return false
            }
            UIView.animate(withDuration: 0.2, animations: {
                rippleView.alpha = 0.0
            }, completion: { [weak self] _ in
                self?.rippleView = nil
                self?.needDeleteRipple = false
            })
            return true
        }
    }

    private var rippleBackView: RippleBackView? {
        didSet {
            oldValue?.removeFromSuperview()
            rippleBackView?.highlightColor = rippleColor
        }
    }

    var rippleColor: UIColor? = .black.withAlphaComponent(0.3) {
        didSet {
            rippleBackView?.highlightColor = rippleColor
        }
    }

    private var oldIsEnabled = false
    override var isEnabled: Bool {
        didSet {
            if isProcessing { oldIsEnabled = isEnabled }
            if let color = backgroundColors[isEnabled ? .normal : .disabled] {
                backgroundColor = color
            }
            if let color = titleColors[isEnabled ? .normal : .disabled] {
                tintColor = color
            }
        }
    }

    var font: UIFont = .preferredFont(forTextStyle: .body) { didSet {
        self.text = text
    } }
    private let isProcessingLock = NSLock()
    var isProcessing = false {
        willSet { isProcessingLock.lock() }
        didSet { isProcessingLock.unlock() }
    }

    var text: String {
        get { titleLabel?.attributedText?.string ?? "" }
        set {
            titleColors.forEach { state, color in
                let attributedString = newValue.getAttributedString(with: font, color: color)
                setAttributedTitle(attributedString, for: state)
            }
        }
    }

    var attributedText: NSAttributedString? {
        get { attributedTitle(for: .normal) }
        set { setAttributedTitle(newValue, for: .normal) }
    }

    var stringKey: String {
        get { fatalError("You can't use stringKey getter") }
        set { text = newValue }
    }

    var useOnlyNormalFont = false

    var backgroundColors: [UIControl.State: UIColor?] = [
        UIControl.State.normal: .clear,
        UIControl.State.disabled: .clear
    ] {
        didSet {
            if let color = backgroundColors[state] {
                backgroundColor = color
            }
        }
    }

    var titleColors: [UIControl.State: UIColor?] = [:] {
        didSet {
            titleColors.forEach { state, color in
                guard let attributedString = attributedTitle(for: state) else { return }
                guard let color else { return }
                let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
                mutableAttributedString
                    .addAttribute(.foregroundColor,
                                  value: color,
                                  range: NSRange(location: 0, length: attributedString.string.count))
                setAttributedTitle(mutableAttributedString, for: state)
            }
        }
    }

    var colorStyle: ColorStyle = .primary { didSet {
        backgroundColors = [
            .normal: colorStyle.backgroundColor,
            .disabled: colorStyle.disabledBackgroundColor
        ]
        titleColors = [
            .normal: colorStyle.textColor,
            .disabled: colorStyle.disabledTextColor
        ]
        tintColor = colorStyle.textColor
        rippleColor = colorStyle.rippleColor
//        if case .tertiary = colorStyle {
//            addShadow(color: .kBlack, alpha: 0.2, blur: 5)
//        } else {
            removeShadow()
//        }
    } }

    var rippleFromCenter = false
    var canOnlyStartButtonBounds = true
    var rippleBoundsInside = false
    var rippleMargin: CGFloat?
    var intrinsicContentSizeOverride: CGSize?
    override var intrinsicContentSize: CGSize {
        guard let contentSize = intrinsicContentSizeOverride else {
            return super.intrinsicContentSize
        }
        return contentSize
    }

    var alignmentRectInsetsOverride: UIEdgeInsets?
    override var alignmentRectInsets: UIEdgeInsets {
        guard let overridedInsets = alignmentRectInsetsOverride else {
            return super.alignmentRectInsets
        }
        return overridedInsets
    }

    func setHidden(_ isHidden: Bool, animated: Bool = true) {
        guard self.isHidden != isHidden else {
            return
        }
        guard animated else {
            self.isHidden = isHidden
            return
        }
        alpha = isHidden ? 1.0 : 0.0
        self.isHidden = false
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.alpha = isHidden ? 0.0 : 1.0
        }, completion: { [weak self] _ in
            self?.alpha = 1.0
            self?.isHidden = isHidden
        })
    }

    override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
        if let color {
            titleColors[state] = color
        } else {
            // 未指定の場合はデフォルトを設定する
            titleColors[state] = .tertiaryLabel
        }
    }

    var tapHandler: ((BaseButton) -> Void)?
    var tapHandlerAsync: ((BaseButton) async -> Void)?
    var tapPublisher: EventPublisher { publisher(for: .touchUpInside) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    convenience init(image: UIImage?) {
        let frame = CGRect(origin: CGPoint.zero, size: image?.size ?? CGSize.zero)
        self.init(frame: frame)
        setImage(image, for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    deinit {
        rippleBackView = nil
    }

    func setup() {
        colorStyle = .primary
        addTarget(self, action: #selector(touchUpInsideButton(_:)), for: .touchUpInside)

        isEnabled = true
        isExclusiveTouch = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let backView: RippleBackView
        if let temp = rippleBackView {
            backView = temp
        } else {
            backView = RippleBackView()
            backView.isUserInteractionEnabled = false
            backView.clipsToBounds = true
            addSubview(backView)
            rippleBackView = backView
        }

        let frame: CGRect
        if !rippleBoundsInside, bounds.height < 35.0 ||
            (backgroundColors[.normal] == .clear && layer.borderWidth == 0.0) {
            let width: CGFloat = if let rippleMargin {
                bounds.width + (rippleMargin * 2)
            } else if bounds.width < 45.0 {
                44.0
            } else if backgroundColors[.normal] == .clear {
                bounds.width + 44.0
            } else {
                bounds.width + 20.0
            }
            frame = CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: 44.0))
            backView.layer.cornerRadius = frame.height / 2.0
        } else {
            frame = bounds
            backView.layer.cornerRadius = layer.cornerRadius
        }
        backView.frame = frame
        backView.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        backgroundColors[state] = color
    }

    func setCenterTextAndImage(spacing: CGFloat) {
        if #available(iOS 15, *) {
            var configuration = UIButton.Configuration.borderless()
            configuration.imagePlacement = .top
            configuration.imagePadding = spacing
            configuration.contentInsets = .zero
            self.configuration = configuration
            updateConfiguration()
        } else {
            guard let imageSize = imageView?.image?.size,
                  let text = titleLabel?.text,
                  let font = titleLabel?.font
            else { return }

            titleEdgeInsets = UIEdgeInsets(
                top: 0.0,
                left: -imageSize.width,
                bottom: -(imageSize.height + spacing),
                right: 0.0
            )

            let titleSize = text.size(withAttributes: [.font: font])
            imageEdgeInsets = UIEdgeInsets(
                top: -(titleSize.height + spacing),
                left: 0.0,
                bottom: 0.0,
                right: -titleSize.width
            )

            let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0
            contentEdgeInsets = UIEdgeInsets(
                top: edgeOffset,
                left: 0.0,
                bottom: edgeOffset,
                right: 0.0
            )
        }
    }

    func setTextFirst(spacing: CGFloat = 0.0, image: UIImage?, contentInsets: NSDirectionalEdgeInsets) {
        if #available(iOS 15, *) {
            var configuration = UIButton.Configuration.borderless()
            configuration.imagePlacement = .trailing
            configuration.imagePadding = spacing
            configuration.image = image
            configuration.contentInsets = contentInsets
            self.configuration = configuration
            updateConfiguration()
        } else {
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            imageEdgeInsets = UIEdgeInsets(top: 0.0, left: -spacing, bottom: 0.0, right: 0.0)
            titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
    }

    func setImageFirst(spacing: CGFloat = 0.0) {
        if #available(iOS 15, *) {
            var configuration = UIButton.Configuration.borderless()
            configuration.imagePlacement = .leading
            configuration.imagePadding = spacing
            self.configuration = configuration
            updateConfiguration()
        } else {
            let edge = spacing / 2
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -edge, bottom: 0, right: edge)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: edge, bottom: 0, right: -edge)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: edge, bottom: 0, right: edge)
        }
    }
}

// MARK: - Actions
extension BaseButton {
    @objc func touchUpInsideButton(_: Any) {
        guard !isProcessing else {
            return
        }
        oldIsEnabled = isEnabled
        isEnabled = false
        isProcessing = true
        if let tapHandlerAsync {
            Task {
                await tapHandlerAsync(self)
                isEnabled = oldIsEnabled
                isProcessing = false
            }
            return
        } else if let tapHandler {
            tapHandler(self)
        }
        isEnabled = oldIsEnabled
        isProcessing = false
    }
}

// MARK: - Ripple
extension BaseButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            super.touchesBegan(touches, with: event)
        }
        guard
            isEnabled,
            let touchPoint = touches.first?.location(in: self)
        else {
            return
        }
        if canOnlyStartButtonBounds && !bounds.contains(touchPoint) {
            return
        }
        if bounds.width < 60.0 || rippleFromCenter {
            rippleBackView?.showRipple()
        } else {
            rippleBackView?.showRipple(on: touchPoint)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            super.touchesEnded(touches, with: event)
        }
        if rippleBackView?.isRippleAnimating ?? false {
            rippleBackView?.needDeleteRipple = true
        } else {
            guard
                rippleBackView?.dismissRipple() ?? false,
                let touchPoint = touches.first?.location(in: self),
                bounds.contains(touchPoint)
            else {
                return
            }
        }
        if let control = superview as? UIControl {
            control.sendActions(for: .touchUpInside)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            super.touchesCancelled(touches, with: event)
        }
        if rippleBackView?.isRippleAnimating ?? false {
            rippleBackView?.needDeleteRipple = true
        } else {
            rippleBackView?.dismissRipple()
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let result = super.hitTest(point, with: event) else {
            return nil
        }
        guard rippleBackView != result else {
            return self
        }
        return result
    }
}

extension UIControl.State: Hashable {}
