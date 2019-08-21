public struct FieldName<Value>: Hashable, ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        rawValue = value
    }
    let rawValue: String
}


class CredentialFields {
    private let fields: [Provider.FieldSpecification]
    private let values: [FieldName<Provider.FieldSpecification>: String]
    
    init(provider: Provider, values: [FieldName<Provider.FieldSpecification>: String] = [:]) {
        fields = provider.fields
        self.values = values
        var multableValues = values
        multableValues = ["a" : "b"]
    }
}
