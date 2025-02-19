//
//  SceneDelegate.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .light
        let rootVC = SplashViewController()
        window.rootViewController = rootVC
        UIViewController.rootViewController = rootVC
        self.window = window

        // Initializing App
       
        window.makeKeyAndVisible()
        _ = IndicatorController.shared
    }
}
