//
//  SceneDelegate.swift
//  Cloudyyy_App
//
//  Created by user@5 on 05/11/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: - App Launch
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Tab bar appearance is configured per-instance in each TabBarController
        // to support dark Liquid Glass. Do NOT set UITabBar.appearance() here.

        // ----------------------------------------------------

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // Launch / onboarding
        let launchVC = LaunchAnimationViewController()
        let nav = UINavigationController(rootViewController: launchVC)
        nav.isNavigationBarHidden = true

        window.rootViewController = nav
        window.makeKeyAndVisible()
        
        // Start network monitoring
        NetworkMonitor.shared.startMonitoring()
    }

    // MARK: - Scene lifecycle
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

// MARK: - Root Switching
extension SceneDelegate {

    /// Switches root safely to the main app tab bar
    func switchToMainApp(role: UserRole) {

        // 1. Initialize Controller based on role
        let rootVC: UIViewController
        switch role {
        case .parent:
            rootVC = AppTabBarController()
        case .child:
            rootVC = ChildTabBarController()
        }

        // 2. Embed in navigation controller (hidden)
        let nav = UINavigationController(rootViewController: rootVC)
        nav.isNavigationBarHidden = true

        guard let window = window else { return }

        // 3. Smooth root transition
        UIView.transition(
            with: window,
            duration: 0.35,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = nav
            }
        )
    }

    func switchToAuthFlow() {
        let authVC = SelectUserViewController()
        let nav = UINavigationController(rootViewController: authVC)
        nav.isNavigationBarHidden = true

        guard let window = window else { return }

        UIView.transition(
            with: window,
            duration: 0.35,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = nav
            }
        )
    }
}
