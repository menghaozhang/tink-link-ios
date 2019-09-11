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
    
    public struct Field {
        public var text: String
        public let name: String
        public let isOptional: Bool
        public let helpText: String
        public let validationRules: ValidationRules
        public let attributes: Attributes
        
        internal init(fieldSpecification: Provider.FieldSpecification) {
            text = fieldSpecification.initialValue
            name = fieldSpecification.name
            isOptional = fieldSpecification.isOptional
            helpText = fieldSpecification.helpText
            validationRules = ValidationRules(
                maxLength: fieldSpecification.maxLength,
                minLength: fieldSpecification.minLength,
                regex: fieldSpecification.pattern,
                regexError: fieldSpecification.patternError
            )
            attributes = Attributes(
                placeholder: fieldSpecification.fieldDescription,
                isSecureTextEntry: fieldSpecification.isMasked,
                inputType: fieldSpecification.isNumeric ? .numeric : .default,
                isEnabled: !fieldSpecification.isImmutable || fieldSpecification.initialValue.isEmpty
            )
        }
        
        public struct ValidationRules {
            public let maxLength: Int?
            public let minLength: Int?
            internal let regex: String
            internal let regexError: String
        }
        
        public struct Attributes {
            public enum InputType {
                case `default`
                case numeric
            }
            
            public let placeholder: String
            public let isSecureTextEntry: Bool
            public let inputType: InputType
            public let isEnabled: Bool
        }
        
        public enum ValidationError: Error {
            case invalidField(String)
            case validationFailed(fieldName: String, patternError: String)
            case maxLengthLimit(fieldName: String, maxLength: Int)
            case minLengthLimit(fieldName: String, minLength: Int)
            case requiredFieldEmptyValue(fieldName: String)
        }
        
        public var isValueValid: Bool {
            do {
                try validate(value: text)
                return true
            } catch {
                return false
            }
        }
        
        public func validate(value: String) throws {
            if value.isEmpty, !isOptional {
                throw ValidationError.requiredFieldEmptyValue(fieldName: name)
            } else if let maxLength = validationRules.maxLength, maxLength > 0 && maxLength < value.count {
                throw ValidationError.maxLengthLimit(fieldName: name, maxLength: maxLength)
            } else if let minLength = validationRules.minLength, minLength > 0 && minLength > value.count {
                throw ValidationError.minLengthLimit(fieldName: name, minLength: minLength)
            } else if !validationRules.regex.isEmpty, let regex = try? NSRegularExpression(pattern: validationRules.regex, options: []) {
                let range = regex.rangeOfFirstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count))
                if range.location == NSNotFound {
                    throw ValidationError.validationFailed(fieldName: name, patternError: validationRules.regexError)
                }
            }
        }
    }
    
    public struct FieldsError: Error {
        public var errors: [Form.Field.ValidationError]
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

extension Array where Element == Form.Field {
    func validateValues() throws {
        var fieldsValidationError = Form.FieldsError(errors: [])
        for field in self {
            do {
                try field.validate(value: field.text)
            } catch let error as Form.Field.ValidationError {
                fieldsValidationError.errors.append(error)
            } catch {
                fatalError()
            }
        }
        guard fieldsValidationError.errors.isEmpty else { throw fieldsValidationError }
    }
    
    var areValuesValid: Bool {
        do {
            try validateValues()
            return true
        } catch {
            return false
        }
    }
}
