@testable import TinkLink
import XCTest

class ConfigurationTests: XCTestCase {
    func testConfiguration() {
        let redirectURI = URL(string: "http://my-customer-app.com/authentication")!
        let configuration = try! Link.Configuration(clientID: "abc", redirectURI: redirectURI)
        let link = Link(configuration: configuration)
        XCTAssertNotNil(link.configuration)
    }

    func testConfigureTinkLinkWithConfiguration() {
        let redirectURI = URL(string: "http://my-customer-app.com/authentication")!
        let configuration = try! Link.Configuration(clientID: "abc", redirectURI: redirectURI)
        let link = Link(configuration: configuration)
        XCTAssertEqual(link.configuration.redirectURI, URL(string: "http://my-customer-app.com/authentication")!)
    }

    func testConfigureWithoutRedirectURLHost() {
        let redirectURI = URL(string: "http-my-customer-app://")!
        do {
            let _ = try Link.Configuration(clientID: "abc", redirectURI: redirectURI)
            XCTFail("Cannot configure TinkLink with redriect url without host")
        } catch let urlError as URLError {
            XCTAssert(urlError.code == .cannotFindHost)
        } catch {
            XCTFail("Cannot configure TinkLink with redriect url without host")
        }
    }

    func testConfigureSharedTinkLinkWithConfigurationWithAppURI() {
        Link._shared = nil
        let redirectURI = URL(string: "my-customer-app://authentication")!
        let configuration = try! Link.Configuration(clientID: "abc", redirectURI: redirectURI)
        Link.configure(with: configuration)
        XCTAssertEqual(Link.shared.configuration.redirectURI, redirectURI)
    }
}
