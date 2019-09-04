import Foundation

extension Provider.FieldSpecification {
    public func validateValue() throws {
        let value = self.value
        if value.isEmpty, !self.isOptional {
            throw FieldSpecificationError.requiredFieldEmptyValue(fieldName: self.name)
        } else if let maxLength = self.maxLength, maxLength > 0 && maxLength < value.count {
            throw FieldSpecificationError.maxLengthLimit(fieldName: self.name, maxLength: maxLength)
        } else if let minLength = self.minLength, minLength > 0 && minLength > value.count {
            throw FieldSpecificationError.minLengthLimit(fieldName: self.name, minLength: minLength)
        } else if !self.pattern.isEmpty, let regex = try? NSRegularExpression(pattern: self.pattern, options: []) {
            let range = regex.rangeOfFirstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count))
            if range.location == NSNotFound {
                throw FieldSpecificationError.validationFailed(fieldName: self.name, patternError: self.patternError)
            }
        }
    }

    public var isValueValid: Bool {
        do {
            try validateValue()
            return true
        } catch {
            return false
        }
    }
}

extension Array where Element == Provider.FieldSpecification {
    public func validateValues() throws {
        var fieldSpecificationsError = FieldSpecificationsError(errors: [])
        for fieldSpecification in self {
            do {
                try fieldSpecification.validateValue()
            } catch let error as FieldSpecificationError {
                fieldSpecificationsError.errors.append(error)
            } catch {
                fatalError()
            }
        }
        guard fieldSpecificationsError.errors.isEmpty else { throw fieldSpecificationsError }
    }

    public var areValuesValid: Bool {
        do {
            try validateValues()
            return true
        } catch {
            return false
        }
    }

    internal func makeFields() -> [String: String] {
        var fieldValues: [String: String] = [:]
        for fieldSpecification in self {
            fieldValues[fieldSpecification.name] = fieldSpecification.value
        }
        return fieldValues
    }
}

public enum FieldSpecificationError: Error {
    case invalidField(String)
    case validationFailed(fieldName: String, patternError: String)
    case maxLengthLimit(fieldName: String, maxLength: Int)
    case minLengthLimit(fieldName: String, minLength: Int)
    case requiredFieldEmptyValue(fieldName: String)
}

public struct FieldSpecificationsError: Error {
    public var errors: [FieldSpecificationError]
}
