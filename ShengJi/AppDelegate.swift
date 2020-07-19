//
//  AppDelegate.swift
//  ShengJi
//
//  Created by Ray Kim on 7/17/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let navigationVC = UINavigationController(rootViewController: MenuViewController())
        window?.rootViewController = navigationVC
        return true
    }
}

