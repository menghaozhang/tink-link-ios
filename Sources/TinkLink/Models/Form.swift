import Foundation

public struct Form {
    public var fields: [Field]
    
    internal init(fieldSpecifications: [Provider.FieldSpecification]) {
        fields = fieldSpecifications.map({ Field(fieldSpecification: $0) })
    }
    
    public var areValuesValid: Bool {
        return fields.areValuesValid
    }
    
    public func validateValues() throws {
        try fields.validateValues()
    }
    
    internal func makeFields() -> [String: String] {
        var fieldValues: [String: String] = [:]
        for field in fields {
            fieldValues[field.name] = field.text
        }
        return fieldValues
    }
}

extension Form {
    public init(provider: Provider) {
        self.init(fieldSpecifications: provider.fields)
    }
    
    public init(credential: Credential) {
        self.init(fieldSpecifications: credential.supplementalInformationFields)
    }
}
