import XCTest
@testable import TinkLink

class ConfigurationTests: XCTestCase {
    func testConfiguration() {
        let configuration = TinkLink.Configuration(clientID: "abc")
        let link = TinkLink(configuration: configuration)
        XCTAssertNotNil(link.configuration)
    }

    func testMarketConfiguration() {
        let configuration = TinkLink.Configuration(clientID: "abc", market: "SE")
        let link = TinkLink(configuration: configuration)
        XCTAssertEqual(link.configuration.market.rawValue, "SE")
        XCTAssertEqual(link.client.market.rawValue, "SE")
    }

    func testPropertyListConfiguration() throws {
        let tempConfiguration = TinkLink.Configuration(clientID: "def", market: "NO", locale: nil)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Configuration").appendingPathExtension("plist")
        let data = try PropertyListEncoder().encode(tempConfiguration)
        try data.write(to: url)
        let configuration = try TinkLink.Configuration(plistURL: url)
        XCTAssertEqual(configuration.clientID, "def")
    }

    func testConfigureSharedTinkLinkWithConfiguration() {
        TinkLink._shared = nil
        let configuration = TinkLink.Configuration(clientID: "abc", market: "SE")
        TinkLink.configure(with: configuration)
        XCTAssertEqual(TinkLink.shared.configuration.market.rawValue, "SE")
        XCTAssertEqual(TinkLink.shared.client.market.rawValue, "SE")
    }

    func testConfigureSharedTinkLinkWithPropertyList() throws {
        TinkLink._shared = nil
        let configuration = TinkLink.Configuration(clientID: "def", market: "NO", locale: nil)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Configuration").appendingPathExtension("plist")
        let data = try PropertyListEncoder().encode(configuration)
        try data.write(to: url)
        try TinkLink.configure(configurationPlistURL: url)
        XCTAssertEqual(TinkLink.shared.configuration.market.rawValue, "NO")
        XCTAssertEqual(TinkLink.shared.client.market.rawValue, "NO")
    }
}