//
//  FormInputView.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//
//

import Combine
import SuperEasyLayout
import UIKit

class FormInputView: BaseView {
    private lazy var clearButton: BaseButton = {
        let view = BaseButton(image: .clear)
        view.colorStyle = .text
        return view
    }()

    enum InputRestrictionType {
        typealias MaxLength = Int
        case onlyNumber(MaxLength? = nil)
        case onlyNumberWithTrimming(MaxLength? = nil)

        var maxLength: Int? {
            switch self {
            case .onlyNumber(let maxLegnth): return maxLegnth
            case .onlyNumberWithTrimming(let maxLength): return maxLength
            }
        }

        func isValid(string: String) -> Bool {
            switch self {
            case .onlyNumber:
                return string.isNumber
            case .onlyNumberWithTrimming(let maxLength):
                let temp = string.removeCharacters(from: .whitespacesAndNewlines)
                return temp.isNumber && temp.count <= (maxLength ?? Int.max)
            }
        }
    }

    var placeholderFont: UIFont = .preferredFont(forTextStyle: .caption1)
    var placeholderColor: UIColor? = .tertiaryLabel
    var placeholder: String? {
        get { textField.attributedPlaceholder?.string }
        set {
            guard let newValue else {
                textField.attributedPlaceholder = nil
                return
            }
            textField.attributedPlaceholder = newValue
                .getAttributedString(with: placeholderFont, color: placeholderColor)
        }
    }

    var font: UIFont? {
        get { textField.font }
        set { textField.font = newValue }
    }

    var textFieldColor: UIColor? {
        get { textField.textColor }
        set { textField.textColor = newValue }
    }

    var textFieldTintColor: UIColor? {
        get { textField.tintColor }
        set { textField.tintColor = newValue }
    }

    var textFieldInputView: UIView? {
        get { textField.inputView }
        set { textField.inputView = newValue }
    }

    var textFieldInputAccessoryView: UIView? {
        get { textField.inputAccessoryView }
        set { textField.inputAccessoryView = newValue }
    }

    var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }

    var returnKeyType: UIReturnKeyType {
        get { textField.returnKeyType }
        set { textField.returnKeyType = newValue }
    }

    var autocapitalizationType: UITextAutocapitalizationType {
        get { textField.autocapitalizationType }
        set { textField.autocapitalizationType = newValue }
    }

    var autocorrectionType: UITextAutocorrectionType {
        get { textField.autocorrectionType }
        set { textField.autocorrectionType = newValue }
    }

    var hasClearButton: Bool = false { didSet {
        guard hasClearButton else { return }
        rightView = clearButton
        clearButton.tapHandler = { [weak self] _ in
            guard let self else { return }
            guard textField.delegate?.textFieldShouldClear?(textField) ?? true else { return }
            value = nil
        }
    } }

    var value: String? {
        get { return textField.text }
        set { textField.text = newValue }
    }
    
    var secured: Bool {
        get { textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }
    
    var textAlignment: NSTextAlignment {
        get { textField.textAlignment }
        set { textField.textAlignment = newValue }
    }

    var isNeedToHiddenBackground: Bool = true

    var isEnabled: Bool = true { didSet {
        if isEnabled {
            backgroundBox.isHidden = false
            textField.isEnabled = true
        } else {
            if isNeedToHiddenBackground {
                backgroundBox.isHidden = true
            }
            textField.isEnabled = false
        }
    } }

    var textFieldEdgeInsets: UIEdgeInsets = .zero { didSet {
        textFieldLeftConstraint?.constant = textFieldEdgeInsets.left
        textFieldRightConstraint?.constant = -textFieldEdgeInsets.right
        textFieldTopConstraint?.constant = textFieldEdgeInsets.top
        textFieldBottomConstraint?.constant = -textFieldEdgeInsets.bottom
    } }

    override var backgroundColor: UIColor? {
        get { backgroundBox.backgroundColor }
        set { backgroundBox.backgroundColor = newValue }
    }

    var borderColor: CGColor? {
        get { backgroundBox.layer.borderColor }
        set { backgroundBox.layer.borderColor = newValue }
    }

    var borderWidth: CGFloat {
        get { backgroundBox.layer.borderWidth }
        set { backgroundBox.layer.borderWidth = newValue }
    }

    var isBackgroundHidden: Bool {
        get { backgroundBox.isHidden }
        set { backgroundBox.isHidden = newValue }
    }

    var textColor: UIColor? {
        get { textField.textColor }
        set { textField.textColor = newValue }
    }

    override var tintColor: UIColor! {
        get { textField.tintColor }
        set { textField.tintColor = newValue }
    }

    var cornerRadius: CGFloat {
        get { backgroundBox.layer.cornerRadius }
        set { backgroundBox.layer.cornerRadius = newValue }
    }

    var leftView: UIView? {
        get { textField.leftView }
        set { textField.leftView = newValue }
    }

    var leftViewMode: UITextField.ViewMode {
        get { textField.leftViewMode }
        set { textField.leftViewMode = newValue }
    }

    var rightView: UIView? {
        get { textField.rightView }
        set { textField.rightView = newValue }
    }

    var rightViewMode: UITextField.ViewMode {
        get { textField.rightViewMode }
        set { textField.rightViewMode = newValue }
    }

    var textFieldKey: String {
        get { inputFieldKey }
        set { inputFieldKey = newValue }
    }

    var inputViewForKeyboard: UIView? {
        get { textField.inputView }
        set { textField.inputView = newValue }
    }

    var inputAccessoryViewForKeyboard: UIView? {
        get { textField.inputAccessoryView }
        set { textField.inputAccessoryView = newValue }
    }

    var inputViewCellborderWidth: CGFloat? {
        get { layer.borderWidth }
        set { layer.borderWidth = newValue ?? 0 }
    }

    var groupCount: Int {
        get { cellGroupCount }
        set { cellGroupCount = newValue }
    }

    var errorText: String? {
        get { errorLabel.text }
        set {
            errorLabel.text = newValue
            isError = newValue != nil
        }
    }

    var errorAttributedText: NSAttributedString? {
        get { errorLabel.attributedText }
        set {
            errorLabel.attributedText = newValue
            isError = newValue != nil
        }
    }

    var isError: Bool = false { didSet {
        if isError {
            backgroundBox.backgroundColor = .red.withAlphaComponent(0.1)
        } else {
            backgroundBox.backgroundColor = .clear
        }
    } }

    var isBorderHidden: Bool {
        get { borderColor == UIColor.lightGray.cgColor }
        set { borderColor = newValue ? UIColor.lightGray.cgColor : UIColor.black.cgColor }
    }

    var onBeginEdit: ((FormInputView) -> Void)?
    var onEndEdit: ((FormInputView) -> Void)?
    var onSubmit: ((FormInputView) -> Void)?
    var shouldChangeCharacters: ((Range<String.Index>, String, String) -> String?)?
    var inputRestrictionType: InputRestrictionType?
  
    @Published var hasFocus = false { didSet {
        isBorderHidden = !hasFocus
    } }
    @Published var isRestrictedInput = false

    private var inputFieldKey: String = .init()
    private var cellGroupCount: Int = 0

    lazy var textPublisher: AnyPublisher<String?, Never> = _textPublisher.eraseToAnyPublisher()
    private let _textPublisher = PassthroughSubject<String?, Never>()

    private lazy var backgroundBox: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.layer.cornerRadius = 8
        return textField
    }()
    private weak var textFieldLeftConstraint: NSLayoutConstraint?
    private weak var textFieldRightConstraint: NSLayoutConstraint?
    private weak var textFieldTopConstraint: NSLayoutConstraint?
    private weak var textFieldBottomConstraint: NSLayoutConstraint?

    private lazy var errorLabel: UILabel = {
        let view = UILabel()
        view.font = .footnote
        view.textColor = .red
        view.numberOfLines = 0
        view.lineBreakMode = .byCharWrapping
        return view
    }()

    weak var nextField: FormInputView?

    var cursorPosition: Int? { textField.cursorPosition }

    override func setupLayout() {
        borderWidth = 1
        borderColor = UIColor.clear.cgColor
        cornerRadius = 8
        backgroundColor = .gray

        addSubviews([
            backgroundBox,
            textField,
            errorLabel
        ])

        backgroundBox.left == left
        backgroundBox.right == right
        backgroundBox.top == top
        backgroundBox.height == 44

        huggingHorizontalPriority = .defaultHigh

        textFieldLeftConstraint = textField.left == backgroundBox.left + textFieldEdgeInsets.left
        textFieldRightConstraint = textField.right == backgroundBox.right - textFieldEdgeInsets.right
        textFieldTopConstraint = textField.top == backgroundBox.top + textFieldEdgeInsets.top
        textFieldBottomConstraint = textField.bottom == backgroundBox.bottom - textFieldEdgeInsets.bottom

        textField.compressionRegistanceHorizontalPriority = .defaultLow

        errorLabel.left == left + 12
        errorLabel.right <= right - 12
        errorLabel.top == backgroundBox.bottom + 8
        errorLabel.height >= 16
        errorLabel.bottom == bottom
    }

    override func setupActions() {
        textField.delegate = self
    }

    override var canBecomeFirstResponder: Bool { true }
    override var isFirstResponder: Bool { textField.isFirstResponder }
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }

    override var intrinsicContentSize: CGSize {
        guard let superview else { return super.intrinsicContentSize }
        return CGSize(width: superview.bounds.width, height: 44)
    }

    func setInputView(_ inputView: UIView) {
        textField.inputView = inputView
    }

    func insertText(_ text: String) {
        textField.insertText(text)
    }

    func deleteBackward() {
        textField.deleteBackward()
    }

    func sendTextEvent() {
        _textPublisher.send(value)
    }

    func didChangeValue(newValue: String?) {
        if hasClearButton {
            rightViewMode = (newValue?.isEmpty ?? true) ? .never : .always
        }
        _textPublisher.send(newValue)
    }
}

extension FormInputView: UITextFieldDelegate {
    func textFieldDidEndEditing(_: UITextField, reason _: UITextField.DidEndEditingReason) {
        hasFocus = false
        onSubmit?(self)
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        if let next = nextField {
            next.becomeFirstResponder()
        } else {
            resignFirstResponder()
        }
        hasFocus = false
        onSubmit?(self)
        return true
    }

    func textFieldShouldBeginEditing(_: UITextField) -> Bool {
        onBeginEdit?(self)
        hasFocus = true
        return true
    }

    func textFieldShouldEndEditing(_: UITextField) -> Bool {
        hasFocus = false
        onEndEdit?(self)
        return true
    }

    func textFieldDidEndEditing(_: UITextField) {
        hasFocus = false
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = nil
        didChangeValue(newValue: nil)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        var newReplacementString: String? = nil
        if !string.isBackspace, let inputRestrictionType {
            guard inputRestrictionType.isValid(string: string) else {
                isRestrictedInput = true
                return false
            }
            switch inputRestrictionType {
            case .onlyNumberWithTrimming:
                newReplacementString = string.removeCharacters(from: .whitespacesAndNewlines)
            default:
                break
            }
        }
      
        guard let text = textField.text,
              let range = Range(range, in: text)
        else {
            didChangeValue(newValue: string)
            return true
        }
        let newText = text.replacingCharacters(in: range, with: string)
        if let correctedString = shouldChangeCharacters?(range, string, newText) {
            textField.text = correctedString
            didChangeValue(newValue: correctedString)
            return false
        }
        guard newText.count < (inputRestrictionType?.maxLength ?? Int.max) else {
            isRestrictedInput = true
            return false
        }
        didChangeValue(newValue: newText)
        return true
    }
}
