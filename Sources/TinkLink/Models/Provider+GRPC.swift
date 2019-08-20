import Foundation
import SwiftGRPC

extension Provider {
    init(grpcProvider: GRPCProvider) {
        self.name = grpcProvider.name
        self.displayName = grpcProvider.displayName
        self.type = .init(grpcType: grpcProvider.type)
        self.status = Status(grpcStatus: grpcProvider.status)
        self.helpText = grpcProvider.helpText
        self.isPopular = grpcProvider.popular
        self.fields = grpcProvider.fields.map(FieldSpecification.init(grpcProviderFieldSpecification:))
        self.groupDisplayName = grpcProvider.groupDisplayName
        self.image = grpcProvider.hasImages ? URL(string: grpcProvider.images.iconURL) : nil
        self.displayDescription = grpcProvider.displayDescription
        self.capabilities = .init(grpcCapabilities: grpcProvider.capabilities)
        self.marketCode = grpcProvider.marketCode
        self.accessType = .init(grpcAccessType: grpcProvider.accessType)
        self.financialInstitutionID = grpcProvider.financialInstitutionID
        self.financialInstitutionName = grpcProvider.financialInstitutionName
    }
}

extension Provider.`Type` {
    init(grpcType: GRPCProvider.TypeEnum) {
        switch grpcType {
        case .unknown:
            self = .unknown
        case .bank:
            self = .bank
        case .creditCard:
            self = .creditCard
        case .broker:
            self = .broker
        case .other:
            self = .other
        case .test:
            self = .test
        case .fraud:
            self = .fraud
        case .UNRECOGNIZED(let value):
            assertionFailure("Unrecognized type: \(value)")
            self = .unknown
        }
    }
}

extension Provider.Status {
    init(grpcStatus: GRPCProvider.Status) {
        switch grpcStatus {
        case .unknown:
            self = .unknown
        case .enabled:
            self = .enabled
        case .disabled:
            self = .disabled
        case .temporaryDisabled:
            self = .temporaryDisabled
        case .obsolete:
            self = .obsolete
        case .UNRECOGNIZED(let value):
            assertionFailure("Unrecognized status: \(value)")
            self = .unknown
        }
    }
}

extension Provider.Capabilities {
    init(grpcCapabilities: [GRPCProvider.Capability]) {
        self = grpcCapabilities.reduce([], { (capability, grpcCapabilitiy) in
            switch grpcCapabilitiy {
            case .unknown:
                return capability
            case .transfers:
                return capability.union(.transfers)
            case .mortgageAggregation:
                return capability.union(.mortgageAggregation)
            case .checkingAccounts:
                return capability.union(.checkingAccounts)
            case .savingsAccounts:
                return capability.union(.savingsAccounts)
            case .creditCards:
                return capability.union(.creditCards)
            case .investments:
                return capability.union(.investments)
            case .loans:
                return capability.union(.loans)
            case .payments:
                return capability.union(.payments)
            case .mortgageLoan:
                return capability.union(.mortgageLoan)
            case .identityData:
                return capability.union(.identityData)
            case .UNRECOGNIZED(let value):
                assertionFailure("Unrecognized capability: \(value)")
                return capability
            }
        })
    }

    var grcpCapabilities: [GRPCProvider.Capability] {
        var result: [GRPCProvider.Capability] = []
        if self.contains(.transfers) {
            result.append(.transfers)
        }
        if self.contains(.mortgageAggregation) {
            result.append(.mortgageAggregation)
        }
        if self.contains(.checkingAccounts) {
            result.append(.checkingAccounts)
        }
        if self.contains(.savingsAccounts) {
            result.append(.savingsAccounts)
        }
        if self.contains(.creditCards) {
            result.append(.creditCards)
        }
        if self.contains(.investments) {
            result.append(.investments)
        }
        if self.contains(.loans) {
            result.append(.loans)
        }
        if self.contains(.payments) {
            result.append(.payments)
        }
        if self.contains(.mortgageLoan) {
            result.append(.mortgageLoan)
        }
        if self.contains(.identityData) {
            result.append(.identityData)
        }
        return result
    }
}

extension Provider.AccessType {
    init(grpcAccessType: GRPCProvider.AccessType) {
        switch grpcAccessType {
        case .openBanking:
            self = .openBanking
        case .other:
            self = .other
        case .unknown:
            self = .unknown
        case .UNRECOGNIZED(let value):
            assertionFailure("Unrecognized access type: \(value)")
            self = .unknown
        }
    }
}

extension Provider.FieldSpecification {
    init(grpcProviderFieldSpecification: GRPCProviderFieldSpecification) {
        self.fieldDescription = grpcProviderFieldSpecification.description_p
        self.hint = grpcProviderFieldSpecification.hint
        self.maxLength = grpcProviderFieldSpecification.maxLength > 0 ? Int(grpcProviderFieldSpecification.maxLength) : nil
        self.minLength = grpcProviderFieldSpecification.minLength > 0 ? Int(grpcProviderFieldSpecification.minLength) : nil
        self.isMasked = grpcProviderFieldSpecification.masked
        self.isNumeric = grpcProviderFieldSpecification.numeric
        self.isImmutable = grpcProviderFieldSpecification.immutable
        self.isOptional = grpcProviderFieldSpecification.optional
        self.name = grpcProviderFieldSpecification.name
        self.value = grpcProviderFieldSpecification.value
        self.pattern = grpcProviderFieldSpecification.pattern
        self.patternError = grpcProviderFieldSpecification.patternError
        self.helpText = grpcProviderFieldSpecification.helpText
    }
}
