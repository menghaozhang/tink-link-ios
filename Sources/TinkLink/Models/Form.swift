import Foundation

public struct Form {
    /// A collection of fields.
    ///
    /// Represents a list of fields and provides access to the fields. Each field in can be accessed either by index or by field name.
    public struct Fields: MutableCollection {

        var fields: [Form.Field]

        // MARK: Collection Conformance
        public var startIndex: Int { fields.startIndex }
        public var endIndex: Int { fields.endIndex }
        public subscript(position: Int) -> Form.Field {
            get { fields[position] }
            set { fields[position] = newValue }
        }
        public func index(after i: Int) -> Int { fields.index(after: i) }

        // MARK: Dictionary Lookup

        /// Accesses the field associated with the given field for reading and writing.
        ///
        /// This name based subscript returns the first field with the same name, or `nil` if the field is not found.
        ///
        /// - Parameter name: The name of the field to find in the list.
        /// - Returns: The field associciated with `name` if it exists; otherwise, `nil`.
        public subscript(name fieldName: String) -> Form.Field? {
            get {
                return fields.first(where: { $0.name == fieldName })
            }
            set {
                if let index = fields.firstIndex(where: { $0.name == fieldName }) {
                    if let field = newValue {
                        fields[index] = field
                    } else {
                        fields.remove(at: index)
                    }
                } else if let field = newValue {
                    fields.append(field)
                }
            }
        }
    }

    public var fields: Fields
    
    internal init(fieldSpecifications: [Provider.FieldSpecification]) {
        fields = Fields(fields: fieldSpecifications.map({ Field(fieldSpecification: $0) }))
    }

    /// Returns a Boolean value indicating whether every field in the form are valid.
    ///
    /// - Returns: `true` if all fields in the form have valid text; otherwise, `false`.
    public var areFieldsValid: Bool {
        return fields.areFieldsValid
    }

    /// Validate all fields.
    ///
    /// Use this method to validate all fields in the form or catch the value if one or more field are invalid.
    ///
    /// - Returns: `true` if all fields in the form have valid text; otherwise, `false`.
    /// - Throws: A `Form.ValidationError` if one or more fields are invalid.
    public func validateFields() throws {
        try fields.validateFields()
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
                description: fieldSpecification.fieldDescription,
                placeholder: fieldSpecification.hint,
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

            public func validate(_ value: String, fieldName name: String) throws {
                if let maxLength = maxLength, maxLength > 0 && maxLength < value.count {
                    throw ValidationError.maxLengthLimit(fieldName: name, maxLength: maxLength)
                } else if let minLength = minLength, minLength > 0 && minLength > value.count {
                    throw ValidationError.minLengthLimit(fieldName: name, minLength: minLength)
                } else if !regex.isEmpty, let regex = try? NSRegularExpression(pattern: regex, options: []) {
                    let range = regex.rangeOfFirstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count))
                    if range.location == NSNotFound {
                        throw ValidationError.validationFailed(fieldName: name, reason: regexError)
                    }
                }
            }
        }
        
        public struct Attributes {
            public enum InputType {
                case `default`
                case numeric
            }

            public let description: String
            public let placeholder: String
            public let isSecureTextEntry: Bool
            public let inputType: InputType
            public let isEnabled: Bool
        }
        
        public enum ValidationError: Error, LocalizedError {
            case validationFailed(fieldName: String, reason: String)
            case maxLengthLimit(fieldName: String, maxLength: Int)
            case minLengthLimit(fieldName: String, minLength: Int)
            case requiredFieldEmptyValue(fieldName: String)

            var fieldName: String {
                switch self {
                case .validationFailed(let fieldName, _):
                    return fieldName
                case .maxLengthLimit(let fieldName, _):
                    return fieldName
                case .minLengthLimit(let fieldName, _):
                    return fieldName
                case .requiredFieldEmptyValue(let fieldName):
                    return fieldName
                }
            }

            public var errorDescription: String? {
                switch self {
                case .validationFailed(_, let reason):
                    return reason
                case .maxLengthLimit(_, let maxLength):
                    return "Field can't be longer than \(maxLength)"
                case .minLengthLimit(_, let minLength):
                    return "Field can't be shorter than \(minLength)"
                case .requiredFieldEmptyValue:
                    return "Required field"
                }
            }
        }

        /// Is `true` if `text` passes the validation rules for this field.
        ///
        /// To check why `text` wasn't valid if `false`, call `validate()` and check the thrown error for validation failure reason.
        public var isValid: Bool {
            do {
                try validate()
                return true
            } catch {
                return false
            }
        }

        public func validate() throws {
            let value = text
            if value.isEmpty, !isOptional {
                throw ValidationError.requiredFieldEmptyValue(fieldName: name)
            } else {
                try validationRules.validate(value, fieldName: name)
            }
        }
    }
    
    public struct ValidationError: Error {
        public var errors: [Form.Field.ValidationError]

        public subscript(fieldName fieldName: String) -> Form.Field.ValidationError? {
            errors.first(where: { $0.fieldName == fieldName })
        }
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

extension Form.Fields {
    func validateFields() throws {
        var fieldsValidationError = Form.ValidationError(errors: [])
        for field in fields {
            do {
                try field.validate()
            } catch let error as Form.Field.ValidationError {
                fieldsValidationError.errors.append(error)
            } catch {
                fatalError()
            }
        }
        guard fieldsValidationError.errors.isEmpty else { throw fieldsValidationError }
    }
    
    var areFieldsValid: Bool {
        do {
            try validateFields()
            return true
        } catch {
            return false
        }
    }
}
