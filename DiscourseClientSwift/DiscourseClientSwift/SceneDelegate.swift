//
//  SceneDelegate.swift
//  DiscourseClientSwift
//
//  Created by Jorge on 19/03/2020.
//  Copyright © 2020 Jorge. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let topicsVC = TopicsViewController()
        let usersVC = UsersViewController()
        let categoriesVC = CategoriesViewController()
        let settingsVC = SettingsViewController()

        topicsVC.tabBarItem = UITabBarItem(
                                title: "Inicio",
                                image: UIImage(named: "inicioUnselected"),
                                selectedImage: UIImage(named: "inicio"))

        usersVC.tabBarItem = UITabBarItem(
                                title: "Usuarios",
                                image: UIImage(named: "usuariosUnselected"),
                                selectedImage: UIImage(named: "usuarios"))

        categoriesVC.tabBarItem = UITabBarItem(title: "Categories", image: UIImage(systemName: "tag.fill"), tag: 1)

        settingsVC.tabBarItem = UITabBarItem(
                                title: "Ajustes",
                                image: UIImage(named: "ajustesSeleccionado"),
                                selectedImage: UIImage(named: "ajustes"))

        let topicsNavigationController = UINavigationController(rootViewController: topicsVC)
        let usersNavigationController = UINavigationController(rootViewController: usersVC)
        let categoriesNavigationController = UINavigationController(rootViewController: categoriesVC)
        let settingsNavigationController = UINavigationController(rootViewController: settingsVC)

        topicsNavigationController.navigationBar.barTintColor = .white82
        usersNavigationController.navigationBar.barTintColor = .white82
        categoriesNavigationController.navigationBar.barTintColor = .white82
        settingsNavigationController.navigationBar.barTintColor = .white82

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
                                topicsNavigationController,
                                usersNavigationController,
                                categoriesNavigationController,
                                settingsNavigationController
        ]
        tabBarController.tabBar.barTintColor = .white82
        tabBarController.tabBar.tintColor = .brownGrey

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

}

