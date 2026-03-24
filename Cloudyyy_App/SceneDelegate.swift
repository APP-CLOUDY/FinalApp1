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

        // 🔒 LOCK TAB BAR APPEARANCE (GLOBAL – DO THIS ONCE)
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = .black   // Cloudyyy base color

        tabAppearance.stackedLayoutAppearance.normal.iconColor = .lightGray
        tabAppearance.stackedLayoutAppearance.selected.iconColor = .white
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.lightGray
        ]
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        // 🔑 IMPORTANT — lock BOTH states
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        // Optional: remove top shadow line
        UITabBar.appearance().layer.borderWidth = 0
        UITabBar.appearance().clipsToBounds = true

        // ----------------------------------------------------

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // Launch / onboarding
        let launchVC = LaunchAnimationViewController()
        let nav = UINavigationController(rootViewController: launchVC)
        nav.isNavigationBarHidden = true

        window.rootViewController = nav
        window.makeKeyAndVisible()
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

        // Save role
        UserSession.shared.role = role

        // Create ONE tab bar
        let tabBar = AppTabBarController()

        // Embed in navigation controller (hidden)
        let nav = UINavigationController(rootViewController: tabBar)
        nav.isNavigationBarHidden = true

        guard let window = window else { return }

        // Smooth root transition
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
