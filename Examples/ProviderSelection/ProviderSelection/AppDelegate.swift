//
//  AppDelegate.swift
//  ProviderSelection
//
//  Created by Kasper Lahti on 2019-08-19.
//  Copyright © 2019 Tink. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Can support two options to setup the TinkLink
        // Option 1
        let tinkLinkConfiguration = TinkLink.Configuration(clientId: "123", redirectUrl: URL(string: "http://localhost:3000")!, timeoutIntervalForRequest: 15)
        TinkLink.configure(with: tinkLinkConfiguration)
        
        // Option 2
        try? TinkLink.configure(tinklinkUrl: Bundle.main.url(forResource: "Tinklink", withExtension: "plist")!)

        window = UIWindow(frame: UIScreen.main.bounds)
        let providerListViewController = ProviderListViewController(style: .plain)
        let navigationController = UINavigationController(rootViewController: providerListViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

