import XCTest
@testable import TinkLink

class ThirdPartyCallbackTests: XCTestCase {
    func testValidCallbackURL() {
        var redirectURI = Link.shared.configuration.redirectURI
        redirectURI.appendPathComponent("someValue")
        XCTAssert(Link.shared.open(redirectURI))
    }

    func testInvalidCallbackURL() {
        if let scheme = Link.shared.configuration.redirectURI.scheme, let url = URL(string: "\(scheme)://randomHost/randomPath") {
            XCTAssert(!Link.shared.open(url))
        }
    }
}
