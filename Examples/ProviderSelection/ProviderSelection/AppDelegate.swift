import UIKit
import TinkLink

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let configuration = TinkLink.Configuration(clientId: "12a7f8c23cb441f88ed673440693d308", redirectUrl: URL(string: "https://google.com")!)
        let tinklink = TinkLink()
        tinklink.configure(with: configuration)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let providerListViewController = ProviderListViewController(tinkLink: tinklink, style: .plain)
        let navigationController = UINavigationController(rootViewController: providerListViewController)
        navigationController.navigationBar.prefersLargeTitles = true

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}
