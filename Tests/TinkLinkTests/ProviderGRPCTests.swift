import XCTest
@testable import TinkLink

class ProviderGRPCTests: XCTestCase {
    func testCapabilitiesMapping() {
        let grpcCapabilities: [GRPCProvider.Capability] = [.transfers, .checkingAccounts, .savingsAccounts]
        let capabilities = Provider.Capabilities(grpcCapabilities: grpcCapabilities)
        XCTAssertTrue(capabilities.contains(.checkingAccounts))
        XCTAssertEqual(Set(capabilities.grcpCapabilities), Set(grpcCapabilities))
    }
}
