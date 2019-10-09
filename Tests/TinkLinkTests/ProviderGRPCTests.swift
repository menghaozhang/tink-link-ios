import XCTest
@testable import TinkLink

class ProviderGRPCTests: XCTestCase {
    func testProviderMapping() {
        var grpcProvider = GRPCProvider()
        grpcProvider.name = "se-test-other-third-party-app-successful"
        grpcProvider.displayName = "Demo Unregulated Third party (successful)"
        grpcProvider.type = .test
        grpcProvider.status = .enabled
        grpcProvider.credentialType = .thirdPartyAuthentication
        grpcProvider.helpText = "To connect your bank, you need to identify yourself using a third party app."
        grpcProvider.popular = false

        var field = GRPCProviderFieldSpecification()
        field.description_p = "Username"
        field.immutable = true
        field.masked = false
        field.name = "username"
        field.numeric = false
        field.optional = false
        grpcProvider.fields = [
            field
        ]
        grpcProvider.groupDisplayName = "Demo providers"

        var images = GRPCImages()
        images.iconURL = "https://cdn.tink.se/provider-images/tink.png"
        grpcProvider.images = images
        grpcProvider.displayDescription = "Third party app"
        grpcProvider.capabilities = [
            .loans,
            .savingsAccounts,
            .investments,
            .creditCards
        ]
        grpcProvider.marketCode = "SE"
        grpcProvider.accessType = .other
        grpcProvider.financialInstitutionID = "f128639c-171b-46eb-8eff-219705bcbbcc"
        grpcProvider.financialInstitutionName = "Demo"
        grpcProvider.authenticationFlow = .decoupled

        let provider = Provider(grpcProvider: grpcProvider)

        XCTAssertEqual(provider.id.value, grpcProvider.name)
        XCTAssertEqual(provider.displayName, grpcProvider.displayName)
        XCTAssertEqual(provider.displayDescription, grpcProvider.displayDescription)
        XCTAssertEqual(provider.type, .test)
        XCTAssertEqual(provider.isPopular, true)
        XCTAssertEqual(provider.fields.count, 1)
        XCTAssertEqual(provider.status, .enabled)
    }

    func testCapabilitiesMapping() {
        let grpcCapabilities: [GRPCProvider.Capability] = [.transfers, .checkingAccounts, .savingsAccounts]
        let capabilities = Provider.Capabilities(grpcCapabilities: grpcCapabilities)
        XCTAssertTrue(capabilities.contains(.checkingAccounts))
        XCTAssertEqual(Set(capabilities.grpcCapabilities), Set(grpcCapabilities))
    }

    func testCapabilitiesMatching() {
        let predicate: Provider.Capabilities = [.checkingAccounts, .savingsAccounts]
        XCTAssertFalse(predicate.isDisjoint(with: [.checkingAccounts, .creditCards]))
        XCTAssertTrue(predicate.isDisjoint(with: [.creditCards, .identityData]))
    }
}
