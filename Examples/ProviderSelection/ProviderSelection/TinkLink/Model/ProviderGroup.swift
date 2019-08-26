import Foundation
// Mocked Provider model
struct Provider {
    let name: String
    let financialInstitutionID: String
    let groupedName: String
    let accessType: AccessType
    var credentialType: Credential.`Type`
    var fields: [FieldSpecification]
    
    public struct FieldSpecification {
        // description
        public var fieldDescription: String
        /// Gray text in the input view (Similar to a placeholder)
        public var hint: String
        public var maxLength: Int?
        public var minLength: Int?
        /// Controls whether or not the field should be shown masked, like a password field.
        public var isMasked: Bool
        public var isNumeric: Bool
        public var isImmutable: Bool
        public var isOptional: Bool
        public var name: String
        public var value: String
        public var pattern: String
        public var patternError: String
        /// Text displayed next to the input field
        public var helpText: String
        
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
    
    enum AccessType: String {
        case reverseEngineering
        case openBanking
    }
}

enum ProviderGroupedByAccessType {
    case singleProvider(Provider)
    case multipleCredentialTypes([Provider])
    
    init(providers: [Provider]) {
        if providers.count == 1, let provider = providers.first {
            self = .singleProvider(provider)
        } else {
            self = .multipleCredentialTypes(providers)
        }
    }
    
    var providers: [Provider] {
        switch self {
        case .multipleCredentialTypes(let providers):
            return providers
        case .singleProvider(let provider):
            return [provider]
        }
    }
    
    var accessType: String? {
        return providers.first?.accessType.rawValue
    }
}

enum ProviderGroupedByFinancialInsititution {
    case singleProvider(Provider)
    case multipleCredentialTypes([Provider])
    case multipleAccessTypes([ProviderGroupedByAccessType])
    
    init(providers: [Provider]) {
        if providers.count == 1, let provider = providers.first {
            self = .singleProvider(provider)
        } else {
            let providerGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType })
            let accessTypes = providerGroupedByAccessTypes.map { $0.key }
            if accessTypes.count == 1 {
                self = .multipleCredentialTypes(providers)
            } else {
                var providerGroupedByAccessType = [ProviderGroupedByAccessType]()
                accessTypes.forEach { accessType in
                    let providersWithSameAccessType = providers.filter({ $0.accessType == accessType })
                    providerGroupedByAccessType.append(ProviderGroupedByAccessType(providers: providersWithSameAccessType))
                }
                self = .multipleAccessTypes(providerGroupedByAccessType)
            }
        }
    }
    
    var providers: [Provider] {
        switch self {
        case .multipleAccessTypes(let providerGroupByAccessTypes):
            return providerGroupByAccessTypes.flatMap { $0.providers }
        case .multipleCredentialTypes(let providers):
            return providers
        case .singleProvider(let provider):
            return [provider]
        }
    }
    
    var financialInsititutionID: String? {
        return providers.first?.financialInstitutionID
    }
    
    func filter(predicate: (Provider) -> Bool) -> [Provider] {
        return providers.filter(predicate)
    }
}

enum ProviderGroupedByGroupedName {
    case singleProvider(Provider)
    case multipleCredentialTypes([Provider])
    case multipleAccessTypes([ProviderGroupedByAccessType])
    case financialInsititutions([ProviderGroupedByFinancialInsititution])
    
    init(providers: [Provider]) {
        if providers.count == 1, let provider = providers.first {
            self = .singleProvider(provider)
        } else {
            let providerGroupedByFinancialInstitutions = Dictionary(grouping: providers, by: { $0.financialInstitutionID })
            let financialInstitutions = providerGroupedByFinancialInstitutions.map { $0.key }
            if financialInstitutions.count == 1 {
                let providerGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType })
                let accessTypes = providerGroupedByAccessTypes.map { $0.key }
                if accessTypes.count == 1 {
                    self = .multipleCredentialTypes(providers)
                } else {
                    var providerGroupedByAccessType = [ProviderGroupedByAccessType]()
                    accessTypes.forEach { accessType in
                        let providersWithSameAccessType = providers.filter({ $0.accessType == accessType })
                        providerGroupedByAccessType.append(ProviderGroupedByAccessType(providers: providersWithSameAccessType))
                    }
                    self = .multipleAccessTypes(providerGroupedByAccessType)
                }
            } else {
                var providerGroupedByFinancialInstitution = [ProviderGroupedByFinancialInsititution]()
                financialInstitutions.forEach { financialInstitution in
                    let providersWithSameFinancialInstitutions = providers.filter({ $0.financialInstitutionID == financialInstitution })
                    providerGroupedByFinancialInstitution.append(ProviderGroupedByFinancialInsititution(providers: providersWithSameFinancialInstitutions))
                }
                self = .financialInsititutions(providerGroupedByFinancialInstitution)
            }
        }
    }
    
    var providers: [Provider] {
        switch self {
        case .financialInsititutions(let providerGroupedByFinancialInsititutions):
            return providerGroupedByFinancialInsititutions.flatMap{ $0.providers }
        case .multipleAccessTypes(let providerGroupByAccessTypes):
            return providerGroupByAccessTypes.flatMap { $0.providers }
        case .multipleCredentialTypes(let providers):
            return providers
        case .singleProvider(let provider):
            return [provider]
        }
    }
    
    var groupedName: String? {
        return providers.first?.groupedName
    }
}


extension Provider {
    static var personalNumberFieldSpecification: FieldSpecification {
        return FieldSpecification(fieldDescription: "PersonalNumber",
                                  hint: "YYYYMMDDXXXX",
                                  maxLength: 12,
                                  minLength: 12,
                                  isMasked: false,
                                  isNumeric: true,
                                  isImmutable: false,
                                  isOptional: false,
                                  name: "Username",
                                  value: "",
                                  pattern: "(19|20)[0-9]{10}",
                                  patternError: "Please enter a valid social security number.",
                                  helpText: "## PersonalNumber")
    }
    
    static var passwordFieldSpecification: FieldSpecification {
        return FieldSpecification(fieldDescription: "Password",
                                  hint: "",
                                  maxLength: nil,
                                  minLength: nil,
                                  isMasked: true,
                                  isNumeric: false,
                                  isImmutable: false,
                                  isOptional: false,
                                  name: "Password",
                                  value: "",
                                  pattern: "",
                                  patternError: "",
                                  helpText: "")
    }
    
    static var securityCodeFieldSpecification: FieldSpecification {
        return FieldSpecification(fieldDescription: "Security Code",
                                  hint: "",
                                  maxLength: 0,
                                  minLength: 0,
                                  isMasked: false,
                                  isNumeric: false,
                                  isImmutable: false,
                                  isOptional: false,
                                  name: "loginDescriptionField",
                                  value: "9876",
                                  pattern: "",
                                  patternError: "",
                                  helpText: "Login using your Card Reader. Enter the security code and press Ok. Provide the given return code in the input field to continue \n")
    }
    
    static var inputCodeFieldSpecification: FieldSpecification {
        return FieldSpecification(fieldDescription: "Input Code",
                                  hint: "",
                                  maxLength: 0,
                                  minLength: 0,
                                  isMasked: false,
                                  isNumeric: false,
                                  isImmutable: false,
                                  isOptional: false,
                                  name: "loginInputField",
                                  value: "",
                                  pattern: "",
                                  patternError: "",
                                  helpText: "")
    }
}
