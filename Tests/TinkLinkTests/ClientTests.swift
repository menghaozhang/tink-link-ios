import XCTest
@testable import TinkLink
import SwiftGRPC

class ClientTests: XCTestCase {
    func testUnauthenticatedClient() {
        let client = Client(environment: .staging, clientKey: "not_work_client", certificateURL: nil, market: TinkLink.defaultMarket, locale: TinkLink.defaultLocale)

        let requestExpectation = expectation(description: "Providers Request")

        let canceller = client.providerService.providers { (result) in
            do {
                _ = try result.get()
                XCTFail("Shouldn't receive providers when not authenticated.")
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
