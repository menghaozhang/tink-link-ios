import Foundation

extension Provider.FieldSpecification {
    public func validatedValue() -> Result<String, FieldSpecificationError> {
        let value = self.value
        if value.isEmpty, !self.isOptional {
            return .failure(.requiredFieldEmptyValue(fieldName: self.name))
        } else if let maxLength = self.maxLength, maxLength > 0 && maxLength < value.count {
            return .failure(.maxLengthLimit(fieldName: self.name, maxLength: maxLength))
        } else if let minLength = self.minLength, minLength > 0 && minLength > value.count {
            return .failure(.minLengthLimit(fieldName: self.name, minLength: minLength))
        } else if !self.pattern.isEmpty, let regex = try? NSRegularExpression(pattern: self.pattern, options: []) {
            let range = regex.rangeOfFirstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count))
            if range.location == NSNotFound {
                return .failure(.validationFailed(fieldName: self.name, patternError: self.patternError))
            }
        }
        return .success(value)
    }
}

extension Array where Element == Provider.FieldSpecification {
    func createCredentialValues() -> Result<[String: String], FieldSpecificationError> {
        do {
            try self.forEach { try $0.validatedValue().get() }
        } catch (let error as FieldSpecificationError) {
            return .failure(error)
        } catch {
            fatalError()
        }
        let fieldValus = self.reduce(into: [String: String]()) { $0[$1.name] = $1.value }
        return .success(fieldValus)
    }
}

public enum FieldSpecificationError: Error {
    case invalidField(String)
    case validationFailed(fieldName: String, patternError: String)
    case maxLengthLimit(fieldName: String, maxLength: Int)
    case minLengthLimit(fieldName: String, minLength: Int)
    case requiredFieldEmptyValue(fieldName: String)
}

// TODO: FieldSpecificationsError description
struct FieldSpecificationsError: Error {
    let errors: [FieldSpecificationError]
}
