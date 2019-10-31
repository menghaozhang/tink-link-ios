import XCTest
@testable import TinkLink

class ConfigurationTests: XCTestCase {

    func testConfiguration() {
        let redirectURI = URL(string: "http://my-customer-app.com/authentication")!
        let configuration = TinkLink.Configuration(clientID: "abc", redirectURI: redirectURI)
        let link = TinkLink(configuration: configuration)
        XCTAssertNotNil(link.configuration)
    }

    func testConfigureSharedTinkLinkWithConfiguration() {
        TinkLink._shared = nil
        let redirectURI = URL(string: "my-customer-app://authentication")!
        let configuration = TinkLink.Configuration(clientID: "abc", redirectURI: redirectURI)
        TinkLink.configure(with: configuration)
        XCTAssertEqual(TinkLink.shared.configuration.redirectURI, redirectURI)
    }
}
