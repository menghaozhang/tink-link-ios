import XCTest
@testable import TinkLink

class FormTests: XCTestCase {
    func testFieldValidation() throws {
        let fieldSpecification = Provider.FieldSpecification(
            fieldDescription: "Social security number",
            hint: "YYYYMMDDNNNN",
            maxLength: 12,
            minLength: 12,
            isMasked: false,
            isNumeric: true,
            isImmutable: false,
            isOptional: false,
            name: "username",
            initialValue: "",
            pattern: "(19|20)[0-9]{10}",
            patternError: "Please enter a valid social security number",
            helpText: ""
        )

        var field = Form.Field(fieldSpecification: fieldSpecification)

        do {
            try field.validate()
        } catch Form.Field.ValidationError.requiredFieldEmptyValue(let fieldName) {
            XCTAssertEqual(fieldName, "username")
        } catch {
            XCTFail()
        }

        field.text = "201212121212"

        try field.validate()
    }
}
