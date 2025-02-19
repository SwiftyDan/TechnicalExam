//
//  ErrorEntity.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import Foundation

enum ServerErrorType: String, CaseIterable {
    case invalidToken = "An authorization token is not valid."
    case tokenExpired = "Token is invalid or expired"
    case authExpired = "Auth key expired or not found."
    case invalidSignature = "Signature has expired"
    case invalidSchedule = "An error occurred in the current transaction. You can\'t execute queries until the end of the \'atomic\' block."
}

public struct ErrorMessage: Codable, Hashable {
    var code: Int?
    var message: String
   // var details: [[String: String]]?
}
public struct ErrorMessages: Codable, Hashable {
    var message: String?
    var error: String?
    var detail: String?
    
    var type: ServerErrorType? {
        guard let code = detail else { return nil }
        return ServerErrorType(rawValue: code)
    }
    var needToShowAlert: Bool {
        switch type {
        case .invalidToken: false
        default: true
        }
    }
}



public struct ErrorEntity: Codable, Hashable {
    public var success: Bool?
    public var error: ErrorMessage?
    

    var type: ServerErrorType? {
        guard let code = error?.message else { return nil }
        return ServerErrorType(rawValue: code)
    }
    var needToShowAlert: Bool {
        switch type {
        case .invalidToken: false
        default: true
        }
    }
}
