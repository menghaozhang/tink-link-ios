import XCTest
@testable import TinkLink

class ConfigurationTests: XCTestCase {

    func testConfiguration() {
        let redirectURI = URL(string: "http://my-customer-app.com/authentication")!
        let configuration = TinkLink.Configuration(clientID: "abc", redirectURI: redirectURI)
        let link = TinkLink(configuration: configuration)
        XCTAssertNotNil(link.configuration)
    }

    func testMarketConfiguration() {
        let redirectURI = URL(string: "http://my-customer-app.com/authentication")!
        let configuration = TinkLink.Configuration(clientID: "abc", market: "SE", redirectURI: redirectURI)
        let link = TinkLink(configuration: configuration)
        XCTAssertEqual(link.configuration.market.rawValue, "SE")
        XCTAssertEqual(link.client.market.rawValue, "SE")
    }

    func testPropertyListConfiguration() throws {
        let redirectURI = URL(string: "http://my-customer-app.com/authentication")!
        let tempConfiguration = TinkLink.Configuration(clientID: "def", market: "NO", locale: nil, redirectURI: redirectURI)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Configuration").appendingPathExtension("plist")
        let data = try PropertyListEncoder().encode(tempConfiguration)
        try data.write(to: url)
        let configuration = try TinkLink.Configuration(plistURL: url)
        XCTAssertEqual(configuration.clientID, "def")
    }

    func testConfigureSharedTinkLinkWithConfiguration() {
        TinkLink._shared = nil
        let redirectURI = URL(string: "my-customer-app://authentication")!
        let configuration = TinkLink.Configuration(clientID: "abc", market: "SE", redirectURI: redirectURI)
        TinkLink.configure(with: configuration)
        XCTAssertEqual(TinkLink.shared.configuration.market.rawValue, "SE")
        XCTAssertEqual(TinkLink.shared.client.market.rawValue, "SE")
        XCTAssertEqual(TinkLink.shared.configuration.redirectURI, redirectURI)
    }

    func testConfigureSharedTinkLinkWithPropertyList() throws {
        TinkLink._shared = nil
        let redirectURI = URL(string: "my-customer-app-2://authentication")!
        let configuration = TinkLink.Configuration(clientID: "def", market: "NO", locale: nil, redirectURI: redirectURI)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Configuration").appendingPathExtension("plist")
        let data = try PropertyListEncoder().encode(configuration)
        try data.write(to: url)
        try TinkLink.configure(configurationPlistURL: url)
        XCTAssertEqual(TinkLink.shared.configuration.market.rawValue, "NO")
        XCTAssertEqual(TinkLink.shared.client.market.rawValue, "NO")
        XCTAssertEqual(TinkLink.shared.configuration.redirectURI, redirectURI)
    }
}
