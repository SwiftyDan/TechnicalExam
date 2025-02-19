//
//  SplashViewModel.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import Foundation

final class SplashViewModel {
    enum State {
        typealias DisplayDuration = Int
        case needToLogin
        case showHome
    }

    @Published var appState: State?

    func checkAppState() async throws {
        guard AppConstant.shared.userName == "User@yahoo.co" && AppConstant.shared.password == "P@ssword1"
        else { appState = .needToLogin; return }
        appState = .showHome
    }

    func clearData() throws {
        AppConstant.clearAllConstants()
    }
}
