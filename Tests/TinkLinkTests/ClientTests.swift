import SwiftGRPC
@testable import TinkLink
import XCTest

class ServiceTests: XCTestCase {
    func testInvalidClient() {
        let requestExpectation = expectation(description: "Providers Request")

        let canceller = UserService().createAnonymous(locale: TinkLink.defaultLocale) { result in
            do {
                _ = try result.get()
                XCTFail("Shouldn't receive access token when clientId is not valid.")
            } catch let rpcError as RPCError {
                switch rpcError {
                case .invalidMessageReceived:
                    XCTFail("Invalid message received")
                case .timedOut:
                    XCTFail("Request timed out")
                case .callError(let callResult):
                    XCTAssertEqual(callResult.statusCode, .unknown)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            requestExpectation.fulfill()
        }

        wait(for: [requestExpectation], timeout: 5)

        canceller.cancel()
    }
}
