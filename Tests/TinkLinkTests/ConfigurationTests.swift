import XCTest
@testable import TinkLink

class ConfigurationTests: XCTestCase {
    func testConfiguration() {
        let configuration = TinkLink.Configuration(clientID: "abc")
        let link = TinkLink(configuration: configuration)
        XCTAssertNotNil(link.configuration)
    }
}
