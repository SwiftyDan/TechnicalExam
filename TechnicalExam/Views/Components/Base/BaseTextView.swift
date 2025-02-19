//
//  BaseTextView.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import Combine
import UIKit

@objc protocol BaseTextViewDelegate: NSObjectProtocol {
    @objc optional func tappedBackword(_ textView: BaseTextView)
}

class BaseTextView: UITextView {
    weak var baseTextViewDelegate: BaseTextViewDelegate?

    /// Placeholder関連
    var placeholderFont: UIFont = .preferredFont(forTextStyle: .caption1)
    var placeholderColor: UIColor? = .tertiaryLabel

    weak var nextField: BaseTextView?
    var onBeginEdit: ((BaseTextView) -> Void)?
    var onSubmited: ((BaseTextView) -> Void)?
    var onChanged: ((BaseTextView, String?) -> Void)?
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextView.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextView }
            .compactMap(\.text).eraseToAnyPublisher()
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        delegate = self
    }

    override func deleteBackward() {
        if text == "" { baseTextViewDelegate?.tappedBackword?(self) }
        super.deleteBackward()
    }

    @objc private func onChangedText() {
        onChanged?(self, text)
    }
}

extension BaseTextView: UITextViewDelegate {
    func textViewShouldBeginEditing(_: UITextView) -> Bool {
        onBeginEdit?(self)
        return true
    }
}
