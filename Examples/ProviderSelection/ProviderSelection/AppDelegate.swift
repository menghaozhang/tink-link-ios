//
//  AppDelegate.swift
//  ProviderSelection
//
//  Created by Kasper Lahti on 2019-08-19.
//  Copyright © 2019 Tink. All rights reserved.
//

import UIKit
import TinkLink

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        let providerMarketsViewController = ProviderMarketsViewController()
        let navigationController = UINavigationController(rootViewController: providerMarketsViewController)
        navigationController.navigationBar.prefersLargeTitles = true

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}

