import XCTest
@testable import TinkLink

class ProviderGroupTests: XCTestCase {
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
        displayDescription: "Password",
        capabilities: .init(rawValue: 1266),
        accessType: .other,
        marketCode: "SE",
        financialInstitutionID: "dde2463acf40501389de4fca5a3693a4",
        financialInstitutionName: "Nordea"
    )

    let sparbankernaBankID = Provider(
        id: "savingsbank-bankid",
        displayName: "Sparbankerna",
        type: .bank,
        status: .enabled,
        credentialType: .mobileBankID,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Swedbank och Sparbankerna",
        image: nil,
        displayDescription: "Mobile BankID",
        capabilities: .init(rawValue: 1534),
        accessType: .other,
        marketCode: "SE",
        financialInstitutionID: "a0afa9bbc85c52aba1b1b8d6a04bc57c",
        financialInstitutionName: "Sparbankerna"
    )

    let sparbankernaPassword = Provider(
        id: "savingsbank-token",
        displayName: "Sparbankerna",
        type: .bank,
        status: .enabled,
        credentialType: .password,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Swedbank och Sparbankerna",
        image: nil,
        displayDescription: "Security token",
        capabilities: .init(rawValue: 1534),
        accessType: .other,
        marketCode: "SE",
        financialInstitutionID: "a0afa9bbc85c52aba1b1b8d6a04bc57c",
        financialInstitutionName: "Sparbankerna"
    )

    let swedbankBankID = Provider(
        id: "swedbank-bankid",
        displayName: "Swedbank",
        type: .bank,
        status: .enabled,
        credentialType: .mobileBankID,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Swedbank och Sparbankerna",
        image: nil,
        displayDescription: "Mobile BankID",
        capabilities: .init(rawValue: 1534),
        accessType: .other,
        marketCode: "SE",
        financialInstitutionID: "6c1749b4475e5677a83e9fa4bb60a18a",
        financialInstitutionName: "Swedbank"
    )

    let swedbankPassword = Provider(
        id: "swedbank-token",
        displayName: "Swedbank",
        type: .bank,
        status: .enabled,
        credentialType: .password,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Swedbank och Sparbankerna",
        image: nil,
        displayDescription: "Security token",
        capabilities: .init(rawValue: 1534),
        accessType: .other,
        marketCode: "SE",
        financialInstitutionID: "6c1749b4475e5677a83e9fa4bb60a18a",
        financialInstitutionName: "Swedbank"
    )

    func testCredentialTypesGrouping() {

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

    func testGroupDisplayNameGrouping() {
        let providers = [
            nordeaBankID,
            nordeaPassword,
            swedbankBankID,
            swedbankPassword
        ]

        let groups = ProviderGroup.makeGroups(providers: providers)

        XCTAssertEqual(groups.count, 2)

        let nordeaGroup = groups[0]
        switch nordeaGroup {
        case .credentialTypes(let providers):
            XCTAssertEqual(providers.count, 2)
        default:
            XCTFail("Expected credential types group.")
        }

        let swedbankAndSparbankernaGroup = groups[1]
        switch swedbankAndSparbankernaGroup {
        case .credentialTypes(let providers):
            XCTAssertEqual(providers.count, 2)
        default:
            XCTFail("Expected credential types group.")
        }
    }

    func testGroupDisplayNameAndFinancialInstitutionGrouping() {
        let providers = [
            nordeaBankID,
            nordeaPassword,
            sparbankernaBankID,
            sparbankernaPassword,
            swedbankBankID,
            swedbankPassword
        ]

        let groups = ProviderGroup.makeGroups(providers: providers)

        XCTAssertEqual(groups.count, 2)

        let nordeaGroup = groups[0]
        switch nordeaGroup {
        case .credentialTypes(let providers):
            XCTAssertEqual(providers.count, 2)
        default:
            XCTFail("Expected credential types group.")
        }

        let swedbankAndSparbankernaGroup = groups[1]
        switch swedbankAndSparbankernaGroup {
        case .financialInsititutions(let financialInstitutions):
            XCTAssertEqual(financialInstitutions.count, 2)
            for financialInstitution in financialInstitutions {
                switch financialInstitution {
                case .credentialTypes(let providers):
                    XCTAssertEqual(providers.count, 2)
                default:
                    XCTFail("Expected credential types group.")
                }
            }
        default:
            XCTFail("Expected financial institutions group.")
        }
    }
}
