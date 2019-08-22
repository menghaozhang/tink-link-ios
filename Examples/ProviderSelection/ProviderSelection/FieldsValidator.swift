import Foundation

class FieldsValidator {
    enum CredentialFieldError: Error {
        case invalidField(String)
        case validationFailed(fieldName: String, patternError: String)
        case maxLengthLimit(fieldName: String, maxLength: Int)
        case minLengthLimit(fieldName: String, minLength: Int)
        case requiredFieldEmptyValue(fieldName: String)
    }
    
    static func createCredentialValues(for fields: [Provider.FieldSpecification]) -> Result<[String: String], CredentialFieldError> {
        do {
            try fields.forEach { try validate(for: $0).get() }
        } catch (let error as CredentialFieldError) {
            return .failure(error)
        } catch {
            fatalError()
        }
        let fieldValus = fields.reduce(into: [String: String]()) { $0[$1.name] = $1.value }
        return .success(fieldValus)
    }
    
    static func validate(for field: Provider.FieldSpecification) -> Result<String, CredentialFieldError> {
        let value = field.value
        if value.isEmpty, !field.isOptional {
            return .failure(.requiredFieldEmptyValue(fieldName: field.name))
        } else if let maxLength = field.maxLength, maxLength > 0 && maxLength < value.count {
            return .failure(.maxLengthLimit(fieldName: field.name, maxLength: maxLength))
        } else if let minLength = field.minLength, minLength > 0 && minLength > value.count {
            return .failure(.minLengthLimit(fieldName: field.name, minLength: minLength))
        } else if !field.pattern.isEmpty, let regex = try? NSRegularExpression(pattern: field.pattern, options: []) {
            let range = regex.rangeOfFirstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count))
            if range.location == NSNotFound {
                return .failure(.validationFailed(fieldName: field.name, patternError: field.patternError))
            }
        }
        return .success(value)
    }
}
