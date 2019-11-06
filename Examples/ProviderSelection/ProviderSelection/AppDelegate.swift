import TinkLink
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let configuration = TinkLink.Configuration(clientID: <#T##String#>, redirectURI: URL(string: "link-demo://")!, environment: .production, market: Market(code: "SE"))
        TinkLink.configure(with: configuration)
        window = UIWindow(frame: UIScreen.main.bounds)
        let providerListViewController = ProviderListViewController(style: .plain)
        let navigationController = UINavigationController(rootViewController: providerListViewController)
        navigationController.navigationBar.prefersLargeTitles = true

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return TinkLink.shared.open(url)
    }
}
