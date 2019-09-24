import UIKit
import TinkLink

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        TinkLink.Configuration(environment: .production, clientId: <#T##String#>, redirectUrl: <#T##URL#>)
        TinkLink.configure(with: )
        window = UIWindow(frame: UIScreen.main.bounds)
        let providerListViewController = ProviderListViewController(market: TinkLink.defaultMarket, style: .plain)
        let navigationController = UINavigationController(rootViewController: providerListViewController)
        navigationController.navigationBar.prefersLargeTitles = true

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}
