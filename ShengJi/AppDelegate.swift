//
//  AppDelegate.swift
//  ShengJi
//
//  Created by Ray Kim on 7/17/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import PusherSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var pusher: Pusher?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let navigationVC = UINavigationController(rootViewController: MenuViewController())
        window?.rootViewController = navigationVC
        
        if let pusherKey = AppDelegate.getAPIKeys()?.pusher {
            let authEndpoint = "https://fast-garden-35127.herokuapp.com/pusher/auth"
            let options = PusherClientOptions(authMethod: .endpoint(authEndpoint: authEndpoint), host: .cluster("us2"))
            pusher = Pusher(key: pusherKey, options: options)
            pusher?.connect()
        }
        
        return true
    }
    
    static func getAPIKeys() -> APIKeys? {
        guard let path = Bundle.main.path(forResource: "apiKeys", ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path),
            let keys = try? PropertyListDecoder().decode(APIKeys.self, from: xml) else {
                return nil
        }
        return keys
    }
}

struct APIKeys: Codable {
    let pusher: String
}
