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
}
