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
        
        // Can support two options to setup the TinkLink
        // Option 1
        let tinkLinkConfiguration = TinkLink.Configuration(environment: .staging, clientId: "123", redirectUrl: URL(string: "http://localhost:3000")!)
        TinkLink.configure(with: tinkLinkConfiguration)
        
        // Option 2
//        try? TinkLink.configure(tinklinkUrl: Bundle.main.url(forResource: "Tinklink", withExtension: "plist")!)

        window = UIWindow(frame: UIScreen.main.bounds)
        let providerMarketsViewController = ProviderMarketsViewController()
        let navigationController = UINavigationController(rootViewController: providerMarketsViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}

