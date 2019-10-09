import XCTest
@testable import TinkLink

class CredentialGRPCTests: XCTestCase {
    func testCreatedCapabilitiesMapping() {
        var grpcCredential = GRPCCredential()
        grpcCredential.id = "6e68cc6287704273984567b3300c5822"
        grpcCredential.providerName = "handelsbanken-bankid"
        grpcCredential.type = .mobileBankid
        grpcCredential.status = .created
        grpcCredential.statusPayload = "Analyzed 1,200 out of 1,200 transactions"
        grpcCredential.clearUpdated()
        grpcCredential.fields = ["username": "180012121234"]
        grpcCredential.supplementalInformationFields = []
        grpcCredential.clearThirdPartyAppAuthentication()
        grpcCredential.clearSessionExpiryDate()

        let credential = Credential(grpcCredential: grpcCredential)

        XCTAssertEqual(credential.id.value, grpcCredential.id)
        XCTAssertEqual(credential.providerID.value, grpcCredential.providerName)
        XCTAssertEqual(credential.type, .mobileBankID)
        XCTAssertEqual(credential.status, .created)
        XCTAssertEqual(credential.statusPayload, grpcCredential.statusPayload)
        XCTAssertNil(credential.updated)
        XCTAssertEqual(credential.fields, grpcCredential.fields)
        XCTAssertTrue(credential.supplementalInformationFields.isEmpty)
        XCTAssertNil(credential.thirdPartyAppAuthentication)
        XCTAssertNil(credential.sessionExpiryDate)
    }

    func testUpdatedCredentialMapping() {
        let updatedAt = Calendar.current.date(from: DateComponents(year: 2019, month: 10, day: 8, hour: 15, minute: 24))!

        var grpcCredential = GRPCCredential()
        grpcCredential.id = "6e68cc6287704273984567b3300c5822"
        grpcCredential.providerName = "handelsbanken-bankid"
        grpcCredential.type = .mobileBankid
        grpcCredential.status = .updated
        grpcCredential.statusPayload = "Analyzed 1,200 out of 1,200 transactions"
        grpcCredential.updated = .init(date: updatedAt)
        grpcCredential.fields = ["username": "180012121234"]
        grpcCredential.supplementalInformationFields = []
        grpcCredential.clearThirdPartyAppAuthentication()
        grpcCredential.clearSessionExpiryDate()

        let credential = Credential(grpcCredential: grpcCredential)

        XCTAssertEqual(credential.id.value, grpcCredential.id)
        XCTAssertEqual(credential.providerID.value, grpcCredential.providerName)
        XCTAssertEqual(credential.type, .mobileBankID)
        XCTAssertEqual(credential.status, .updated)
        XCTAssertEqual(credential.statusPayload, grpcCredential.statusPayload)
        XCTAssertEqual(credential.updated, updatedAt)
        XCTAssertEqual(credential.fields, grpcCredential.fields)
        XCTAssertTrue(credential.supplementalInformationFields.isEmpty)
        XCTAssertNil(credential.thirdPartyAppAuthentication)
        XCTAssertNil(credential.sessionExpiryDate)
    }
}
