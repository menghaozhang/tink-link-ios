import XCTest
@testable import TinkLink

class ProviderGroupTests: XCTestCase {
    func testGroup() {
        let nordeaBankID = Provider(
            id: "nordea-bankid",
            displayName: "Nordea",
            type: .bank,
            status: .enabled,
            credentialType: .mobileBankID,
            helpText: "",
            isPopular: true,
            fields: [],
            groupDisplayName: "Nordea",
            image: nil,
            displayDescription: "Mobile BankID",
            capabilities: .init(rawValue: 1266),
            accessType: .other,
            marketCode: "SE",
            financialInstitutionID: "dde2463acf40501389de4fca5a3693a4",
            financialInstitutionName: "Nordea"
        )

        let nordeaPassword = Provider(
            id: "nordea-password",
            displayName: "Nordea",
            type: .bank,
            status: .enabled,
            credentialType: .password,
            helpText: "",
            isPopular: true,
            fields: [],
            groupDisplayName: "Nordea",
            image: nil,
            displayDescription: "Mobile BankID",
            capabilities: .init(rawValue: 1266),
            accessType: .other,
            marketCode: "SE",
            financialInstitutionID: "dde2463acf40501389de4fca5a3693a4",
            financialInstitutionName: "Nordea"
        )

        let providers = [nordeaBankID, nordeaPassword]

        let groups = ProviderGroup.makeGroups(providers: providers)

        XCTAssertEqual(groups.count, 1)
        for group in groups {
            switch group {
            case .credentialTypes(let providers):
                XCTAssertEqual(providers.count, 2)
            default:
                XCTFail("Expected credential types group.")
            }
        }
    }
}
