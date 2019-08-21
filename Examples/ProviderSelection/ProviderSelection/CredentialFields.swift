import Foundation

class CredentialFields {
    enum CredentialFieldError: Error {
        case invalidField(String)
        case validationFailed(String)
        case maxLengthLimit(Int)
        case minLengthLimit(Int)
        case requiredFieldEmptyValue(String)
    }
    
    let fields: [Provider.FieldSpecification]
    var values: [String: Result<String, CredentialFieldError>] = [:]
    
    var requiredFields: [Provider.FieldSpecification]
    var optionalFields: [Provider.FieldSpecification]
    
    convenience init(provider: Provider, initialValues: [String: String] = [:]) {
        self.init(providerFieldSpecification: provider.fields, initialValues: initialValues)
    }
    
    init(providerFieldSpecification: [Provider.FieldSpecification], initialValues: [String: String] = [:]) {
        fields = providerFieldSpecification
        requiredFields = fields.filter { !$0.isOptional }
        optionalFields = fields.filter { $0.isOptional }
        let grouped = Dictionary(grouping: requiredFields, by: { $0.name })
        let requiredValues = grouped.mapValues { $0.first?.value ?? "" }
        let stringValues = requiredValues.merging(initialValues, uniquingKeysWith: { return $1 })
        self.values = Dictionary(uniqueKeysWithValues: stringValues.map({ (key, value) in
            (key, validate(for: key, value: value))
        }))
    }
    
    subscript(_ fieldName: String) -> Result<String, CredentialFieldError>? {
        return values[fieldName]
    }
    
    subscript(_ field: Provider.FieldSpecification) -> Result<String, CredentialFieldError>? {
        return values[field.name]
    }
    
    func field(for name: String) -> Provider.FieldSpecification? {
        return fields.first { $0.name == name }
    }
    
    func update(for field: Provider.FieldSpecification, value: String) -> Result<String, CredentialFieldError> {
        let value = validate(for: field, value: value)
        values[field.name] = value
        return value
    }
    
    func update(for fieldName: String, value: String) -> Result<String, CredentialFieldError> {
        let value = validate(for: fieldName, value: value)
        switch value {
        case .failure(.invalidField):
            break
        default:
            values[fieldName] = value
        }
        return value
    }
    
    private func validate(for fieldName: String, value: String) -> Result<String, CredentialFieldError> {
        guard let updateField = fields.first(where: { $0.name == fieldName }) else {
            return .failure(.invalidField("Field does not exist"))
        }
        return validate(for: updateField, value: value)
    }
    
    private func validate(for field: Provider.FieldSpecification, value: String) -> Result<String, CredentialFieldError> {
        if value.isEmpty, !field.isOptional {
            return .failure(.requiredFieldEmptyValue(field.name))
        } else if let maxLength = field.maxLength, maxLength < value.count {
            return .failure(.maxLengthLimit(maxLength))
        } else if let minLength = field.minLength, minLength > value.count {
            return .failure(.minLengthLimit(minLength))
        } else if !field.pattern.isEmpty, let regex = try? NSRegularExpression(pattern: field.pattern, options: []) {
            let range = regex.rangeOfFirstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count))
            if range.location == NSNotFound {
                return .failure(.validationFailed(field.patternError))
            }
        }
        return .success(value)
    }
}
