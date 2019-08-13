import XCTest
@testable import TinkLink
import SwiftGRPC

class ClientTests: XCTestCase {
    func testUnauthenticatedClient() {
        let client = Client(
            environment: .staging,
            clientKey: ProcessInfo.processInfo.environment["TINK_CLIENT_KEY"]!,
            certificateURL: Bundle(for: Client.self).url(forResource: "staging", withExtension: "pem")!
        )

        let requestExpectation = expectation(description: "Providers Request")

        client.providerService.providers { (result) in
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
                    XCTAssertEqual(callResult.statusCode, .unauthenticated)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            requestExpectation.fulfill()
        }

        wait(for: [requestExpectation], timeout: 5)
    }
}
