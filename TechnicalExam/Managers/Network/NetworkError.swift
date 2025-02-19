//
//  NetworkError.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import UIKit

enum NetworkError: Error, CustomDebugStringConvertible, Equatable, LocalizedError {
    typealias Code = String
    typealias Message = String

    static func == (lValue: NetworkError, rValue: NetworkError) -> Bool {
        lValue.code == rValue.code
    }

    case canceled
    case timeout
    case offline
    case invalidRequest
    case invalidUserName
    case invalidResponse
    case accountNotFound
    case noAttendance
    case systemError(Error)
    case appServerError(ErrorEntity)
    case custom(String, String)

    init?(_ error: Error?) {
        guard let error else { return nil }

        if let temp = error as? NetworkError { self = temp; return }

        switch error._code {
        case NSURLErrorNotConnectedToInternet,
             NSURLErrorDataNotAllowed,
             NSURLErrorNetworkConnectionLost:
            self = .offline; return
        case NSURLErrorTimedOut:
            self = .timeout; return
        default:
            self = .systemError(error); return
        }
    }

    init(appServerResponse responseBody: Data?) {
        guard let data = responseBody else { self = .invalidResponse; return }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let errorInfo = try? decoder.decode(ErrorEntity.self, from: data)
        else { self = .invalidResponse; return }
        self = .appServerError(errorInfo)
    }

    var code: String {
        switch self {
        case .timeout:
            String(NSURLErrorTimedOut)
        case .offline:
            String(NSURLErrorNotConnectedToInternet)
        case .systemError(let error):
            "\(error._code)"
        case .canceled:
            "0"
        case .invalidRequest:
            "invalid_request"
        case .invalidResponse:
            "invalid_response"
        case .appServerError(let errorInfo):
            switch errorInfo.type {
            case .invalidToken: "Your account has been logout".localized
            case .tokenExpired: "networkErrorInvalidPinCode".localized
            case .authExpired: "Your account has been logout".localized
            case .invalidSchedule: "An error occurred in the current transaction. You can\'t execute queries until the end of the \'atomic\' block."
            default: errorInfo.error?.message ?? ""
            }
        case .custom(let code, _):
            "Custom Error:\(code)"
        case .invalidUserName:
            "Invalid username or password"
        case .noAttendance:
            "No attendance."
        case .accountNotFound:
            "Account not found"
        }
    }

    var message: String {
        switch self {
        case .systemError(let error):
            #if DEBUG
            if case DecodingError.typeMismatch(_, let context) = error {
                error.localizedDescription + " " + context.codingPath.description
            } else {
                error.localizedDescription
            }
            #else
            error.localizedDescription
            #endif
        case .canceled:
            "Network operation canceled."
        case .invalidRequest:
            "networkErrorInvalidRequest".localized
        case .invalidResponse:
            "networkErrorInvalidResponse".localized
        case .timeout:
            "networkErrorTimeOut".localized
        case .offline:
            "networkErrorOffline".localized
        case .appServerError(let errorInfo):
            switch errorInfo.type {
            case .invalidToken: "Your account has been logout".localized
            case .tokenExpired: "networkErrorInvalidPinCode".localized
            case .authExpired: "Your account has been logout".localized
            case .invalidSchedule: "An error occurred in the current transaction. You can\'t execute queries until the end of the \'atomic\' block."
            default: errorInfo.error?.message ?? ""
            }
        case .custom(_, let message):
            message
        case .invalidUserName:
            "Invalid username or password"
        case .noAttendance:
            "No attendance."
        case .accountNotFound:
            "Account not found"
        }
    }

    var debugDescription: String {
        "Network error -> Code:\(code) Message:\(message)"
    }

    var errorDescription: String? {
        message
    }

    enum ActionType {
        case close
        case reentry
        case goToLogin

        var title: String {
            switch self {
            case .close: "Close"
            case .reentry: "commonReentry".localized
            case .goToLogin: "networkErrorActionGoToLogin".localized
            }
        }
    }

    var actions: [ActionType] {
        switch appServerErrorType {
        case .tokenExpired, .authExpired: [.goToLogin]
        default: [.close]
        }
    }

    var needToShowAlert: Bool {
        switch self {
        case .timeout, .offline: true
        case .appServerError(let errorInfo):
            errorInfo.needToShowAlert
        default: false
        }
    }

    var needToLogout: Bool {
        switch appServerErrorType {
        case .invalidToken: return true
        default: return false
        }
    }

    var appServerErrorType: ServerErrorType? {
        guard case .appServerError(let errorEntity) = self else { return nil }
        return errorEntity.type
    }
}
