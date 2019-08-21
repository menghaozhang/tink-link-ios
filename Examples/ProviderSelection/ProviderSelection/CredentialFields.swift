import Foundation

class CredentialFields {
    enum CredentialFieldError: Error {
        case invalidField(String)
        case validationFailed(String)
        case maxLengthLimit(Int)
        case minLengthLimit(Int)
        case emptyRequiredField
    }
    
    let fields: [Provider.FieldSpecification]
    var values: [String: String]
    
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
        values = requiredValues.merging(initialValues, uniquingKeysWith: { return $1 })
    }
    
    subscript(_ fieldName: String) -> String? {
        return values[fieldName]
    }
    
    subscript(_ field: Provider.FieldSpecification) -> String? {
        return values[field.name]
    }
    
    func update(for field: Provider.FieldSpecification, value: String) -> Result<String, CredentialFieldError> {
        return update(for: field.name, value: value)
    }
    
    func update(for fieldName: String, value: String) -> Result<String, CredentialFieldError> {
        guard let updateField = fields.first(where: { $0.name == fieldName }) else {
            return .failure(.invalidField("Field does not exist"))
        }
        switch validate(for: updateField, value: value) {
        case .failure(let error):
            return .failure(error)
        case .success(let value):
            values[fieldName] = value
            return .success(value)
        }
    }
    
    private func validate(for field: Provider.FieldSpecification, value: String) -> Result<String, CredentialFieldError> {
        if value.isEmpty, !field.isOptional {
            return .failure(.emptyRequiredField)
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
