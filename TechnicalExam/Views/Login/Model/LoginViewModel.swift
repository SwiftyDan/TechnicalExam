//
//  LoginViewModel.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import Foundation
import Combine

final class LoginViewModel {
    private lazy var cancellables = Set<AnyCancellable>()
    
    enum InputType {
        case userName
        case password
    }
    
    @Published var userName: String?
    @Published var password: String?
    @Published var canTransfer = true
    @Published var userNameError: String?
    @Published var passwordError: String?
    @Published var focusedInput: InputType?
    
    init() {
        $userName.combineLatest($password, $focusedInput)
            .sink { [weak self] username, password, focusedInput in
                guard let self else { return }

                let isValidatedUsername: Bool
                let isValidatedPassword: Bool

                if let username {
                    isValidatedUsername = validate(email: username)
                    userNameError = isValidatedUsername ? nil : "Please Input Valid Email"
                } else {
                    isValidatedUsername = false
                    userNameError = nil
                }
                if let password {
                    isValidatedPassword = validatePassword(password: password)
    
                } else {
                    isValidatedPassword = false
                    passwordError = nil
                }

                canTransfer = isValidatedUsername && isValidatedPassword
            }
        .store(in: &cancellables)
    }
    private func validate(password: String) -> Bool {
        password.count > 0
    }
    private func validate(email: String) -> Bool {
        email.count > 0 && email.isValidEmail()
    }
    private func validatePassword(password: String) -> Bool {
        do {
            try password.validatePassword()
            passwordError = nil
            return true
        } catch let error as PasswordError {
            switch error {
            case .eightCharacters:
                passwordError = "Needs at least eight characters"
            case .oneUppercase:
                passwordError = "Needs at least one uppercase"
            case .oneLowercase:
                passwordError = "Needs at least one lowercase"
            case .oneDecimalDigit:
                passwordError = "Needs at least one number"
            }
            return false
        } catch {
            passwordError = error.localizedDescription
             
        }
        return false
    }
    func login() async throws {
        let defaultUserName = "User@yahoo.co"
        let defaultPassword = "P@ssword1"
        guard let userName, let password, userName == defaultUserName && password == defaultPassword else {
            
            throw NetworkError.invalidUserName }
        AppConstant.shared.userName = userName
        AppConstant.shared.password = password
    }
}


enum PasswordError: String, Error {
    case eightCharacters
    case oneUppercase
    case oneLowercase
    case oneDecimalDigit
}
