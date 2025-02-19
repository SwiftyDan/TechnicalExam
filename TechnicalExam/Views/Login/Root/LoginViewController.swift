//
//  LoginViewController.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import SuperEasyLayout
import UIKit

class LoginViewController: BaseViewController {
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()

    private lazy var contentView = BaseView()

    private lazy var messageLabel: UILabel = {
        let view = UILabel()
        view.font = .largeNumeral
        view.textColor = .black
        view.numberOfLines = 0
        view.textAlignment = .center
        view.lineBreakMode = .byCharWrapping
        view.text = "Login".localized
        return view
    }()

    private lazy var helpButton: BaseButton = {
        let view = BaseButton()
        view.colorStyle = .text
        view.rippleBoundsInside = true
        view.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var userNameTitleLabel: UILabel = {
        let view = UILabel()
        view.font = .body1
        view.textColor = .black
        view.text = "Username"
        return view
    }()

    private lazy var userNameFormInputView: FormInputView = {
        let view = FormInputView()
        view.keyboardType = .default
        view.hasClearButton = true
        view.borderColor = UIColor.lightGray.cgColor
        view.textFieldEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        return view
    }()

    private lazy var passwordTitleLabel: UILabel = {
        let view = UILabel()
        view.font = .body1
        view.textColor = .black
        view.text = "Password"
        return view
    }()

    private lazy var passwordFormInputView: FormInputView = {
        let view = FormInputView()
        view.keyboardType = .default
        view.secured = true
        view.hasClearButton = true
        view.borderColor = UIColor.lightGray.cgColor
        view.textFieldEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        return view
    }()

    private lazy var bottomView: BaseView = {
        let view = BaseView()
        view.backgroundColor = .systemBackground
        return view
    }()
    private weak var bottomViewBottomConstraint: NSLayoutConstraint?

    private lazy var transferButton: BaseButton = {
        let view = BaseButton()
        view.colorStyle = .primary
        view.font = .subhead
        view.text = "Login".localized
        view.layer.cornerRadius = 12
        return view
    }()

    private let viewModel = LoginViewModel()
    private var isShowedInitKeyboard = false

    override func setupNavigation() {
        navigationItem.title = "Technical Exam".localized
    }

    override func setupLayout() {
        view.backgroundColor = .systemBackground

        addSubviews([
            scrollView.addSubviews([
                contentView.addSubviews([
                    messageLabel,
                    helpButton,
                    userNameTitleLabel,
                    userNameFormInputView,
                    passwordTitleLabel,
                    passwordFormInputView,
                ])
            ]),
            bottomView.addSubviews([
                transferButton
            ])
        ])
    }

    override func setupConstraints() {
        scrollView.left == view.left
        scrollView.right == view.right
        scrollView.top == view.topMargin
        scrollView.bottom == bottomView.top

        contentView.setLayoutEqualTo(scrollView)
        contentView.width == scrollView.width

        messageLabel.left == contentView.left + 24
        messageLabel.right == contentView.right - 24
        messageLabel.top == contentView.top + 8

        helpButton.left == contentView.left + (24 - helpButton.contentEdgeInsets.left)
        helpButton.right <= contentView.right - (24 - helpButton.contentEdgeInsets.right)
        helpButton.top == messageLabel.bottom
        helpButton.height == 40

        userNameTitleLabel.left == contentView.left + 24
        userNameTitleLabel.top == helpButton.bottom + 24
        userNameTitleLabel.height == 21

        userNameFormInputView.left == contentView.left + 24
        userNameFormInputView.right == contentView.right - 24
        userNameFormInputView.top == userNameTitleLabel.bottom + 16

        passwordTitleLabel.left == contentView.left + 24
        passwordTitleLabel.top == userNameFormInputView.bottom + 12
        passwordTitleLabel.height == 21

        passwordFormInputView.left == contentView.left + 24
        passwordFormInputView.right == contentView.right - 24
        passwordFormInputView.top == passwordTitleLabel.bottom + 16
        passwordFormInputView.bottom == contentView.bottom - 16

        bottomView.left == view.left
        bottomView.right == view.right
        bottomViewBottomConstraint = bottomView.bottom == view.bottom - AppConstant.safeAreaInsets.bottom
        bottomView.height == 92

        transferButton.left == bottomView.left + 24
        transferButton.right == bottomView.right - 24
        transferButton.top == bottomView.top + 24
        transferButton.height == 44
    }

    override func setupBindings() {
        userNameFormInputView.textPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                viewModel.userName = userNameFormInputView.value
               
            }
            .store(in: &cancellables)
        
        userNameFormInputView.$hasFocus
            .sink { [weak self] hasFocus in
                guard let self else { return }
                if hasFocus {
                    viewModel.focusedInput = .userName
                } else if viewModel.focusedInput == .userName {
                    viewModel.focusedInput = nil
                }
            }
            .store(in: &cancellables)
        viewModel.$userNameError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                setErrorMessage(on: userNameFormInputView, errorMessage: $0)
            }
            .store(in: &cancellables)
        passwordFormInputView.textPublisher
            .sink { [weak self] text in
                guard let self else { return }
                viewModel.password = text
            }
            .store(in: &cancellables)
        
        passwordFormInputView.$hasFocus
            .sink { [weak self] hasFocus in
                guard let self else { return }
                if hasFocus {
                    viewModel.focusedInput = .password
                } else if viewModel.focusedInput == .password {
                    viewModel.focusedInput = nil
                }
            }
            .store(in: &cancellables)
        viewModel.$passwordError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                setErrorMessage(on: passwordFormInputView, errorMessage: $0)
            }
            .store(in: &cancellables)
        viewModel.$canTransfer
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.transferButton.isEnabled = $0
            }
            .store(in: &cancellables)
        keyboardAppear = self
    }

    override func setupActions() {
        transferButton.tapHandlerAsync = { [weak self] _ in
            self?.view.endEditing(true)
            do {
                await IndicatorController.shared.show()
                try await self?.viewModel.login() 
                await IndicatorController.shared.dismiss(type: .check)
                self?.showHome()
            } catch {
                self?.transferButton.isEnabled = true
                await IndicatorController.shared.dismiss(type: .cross)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !isShowedInitKeyboard else { return }
        isShowedInitKeyboard = true
        userNameFormInputView.becomeFirstResponder()
    }

    private func setErrorMessage(on inputView: FormInputView, errorMessage: String?) {
        inputView.errorAttributedText = errorMessage?
            .getAttributedString(with: .footnote, color: .red)
            .insertImage(.error, origin: CGPoint(x: 0, y: -4))
    }

    private func showHome() {
        NotificationCenter.default.post(name: SplashViewController.notificationForShowHome, object: nil)
    }
}

extension LoginViewController: ViewControllerKeyboardAppear {
    func willShowKeyboard(frame: CGRect, duration: TimeInterval, curve: UIView.AnimationCurve) {
        bottomViewBottomConstraint?.constant = -frame.height
        UIView.animate(withDuration: duration, delay: 0, options: curve.animationOptions) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func willHideKeyboard(frame: CGRect, duration: TimeInterval, curve: UIView.AnimationCurve) {
        bottomViewBottomConstraint?.constant = -AppConstant.safeAreaInsets.bottom
        UIView.animate(withDuration: duration, delay: 0, options: curve.animationOptions) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}
