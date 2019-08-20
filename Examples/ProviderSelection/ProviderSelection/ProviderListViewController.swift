//
//  ViewController.swift
//  ProviderSelection
//
//  Created by Kasper Lahti on 2019-08-19.
//  Copyright © 2019 Tink. All rights reserved.
//

import UIKit

struct Client {
    let clientId: String
}

class ProviderContext {
    let client: Client
    init(client: Client) {
        self.client = client
    }
    weak var delegate: ProviderContextDelegate?
    
    var providers = [
        Provider(name: "Avanza", financialInstitutionID: "Avanza", groupedName: "Avanza", accessType: .reverseEngineering),
        Provider(name: "SBAB BankID", financialInstitutionID: "SBAB", groupedName: "SBAB", accessType: .reverseEngineering),
        Provider(name: "SBAB Password", financialInstitutionID: "SBAB", groupedName: "SBAB", accessType: .reverseEngineering),
        Provider(name: "SEB BankID", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .reverseEngineering),
        Provider(name: "SEB Password", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .reverseEngineering),
        Provider(name: "SEB openbanking", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .openBanking),
        Provider(name: "Nordea BankID", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .reverseEngineering),
        Provider(name: "Nordea Password", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .reverseEngineering),
        Provider(name: "Nordea Openbanking", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .openBanking),
        Provider(name: "Nordea", financialInstitutionID: "Nordea Other", groupedName: "Nordea", accessType: .reverseEngineering)
    ]
    
    lazy var providerGroupsByGroupedName: [ProviderGroupedByGroupedName] = {
        let providerGroupedByGroupedName = Dictionary(grouping: providers, by: { $0.groupedName })
        let groupedNames = providerGroupedByGroupedName.map { $0.key }
        var providerGroupsByGroupedNames = [ProviderGroupedByGroupedName]()
        groupedNames.forEach { groupName in
            let providersWithSameGroupedName = providers.filter({ $0.groupedName == groupName })
            providerGroupsByGroupedNames.append(ProviderGroupedByGroupedName(providers: providersWithSameGroupedName))
            
        }
        return providerGroupsByGroupedNames
    }()
}

struct Provider {
    let name: String
    let financialInstitutionID: String
    let groupedName: String
    let accessType: AccessType
    var credentialType: Int { return financialInstitutionID.count }
    
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
//            let providerGroupedByCredentialTypes = Dictionary(grouping: providers, by: { $0.credentialType })
//            let credentialTypes = providerGroupedByCredentialTypes.map { $0.key }
//            var providerGroupedByCredentialType = [ProviderGroupedByCredentialType]()
//            credentialTypes.forEach { credentialType in
//                let providersWithSameCredentialType = providers.filter({ $0.credentialType == credentialType })
//                providerGroupedByCredentialType.append(ProviderGroupedByCredentialType(providers: providersWithSameCredentialType))
//            }
//            self = .multipleCredentialTypes(providerGroupedByCredentialType)
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
    case multupleAccessTypes([ProviderGroupedByAccessType])
    
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
                self = .multupleAccessTypes(providerGroupedByAccessType)
            }
        }
    }
    
    var providers: [Provider] {
        switch self {
        case .multupleAccessTypes(let providerGroupByAccessTypes):
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
}

enum ProviderGroupedByGroupedName {
    case singleProvider(Provider)
    case multipleCredentialTypes([Provider])
    case multupleAccessTypes([ProviderGroupedByAccessType])
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
                    self = .multupleAccessTypes([ProviderGroupedByAccessType(providers: providers)])
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
        case .multupleAccessTypes(let providerGroupByAccessTypes):
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

struct ProviderGroup {
    var providers: [Provider]
    var name: String { return providers.first?.name ?? "" }
    
    var providerGroupedByFinancialInstitutions: [String: [Provider]]
    var providerGroupedByAccessTypes: [String: [Provider]]
    var providerGroupedByCredentialTypes: [Int: [Provider]]
    
    init(providers: [Provider]) {
        self.providers = providers
        providerGroupedByFinancialInstitutions = Dictionary(grouping: providers, by: { $0.financialInstitutionID })
        providerGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType.rawValue })
        providerGroupedByCredentialTypes = Dictionary(grouping: providers, by: { $0.credentialType - $0.accessType.rawValue.count })
    }
}

protocol ProviderContextDelegate: AnyObject {
    func providersDidChange(context: ProviderContext)
}

class ProviderListViewController: UITableViewController, ProvidersWithCredentialTypeOverview, ProviderGroupedByAccessTypeOverview, ProviderGroupedByFinancialInsititutionOverview {
    var providerContext: ProviderContext?
    var providerGroupedByFinancialInsititutions: [ProviderGroupedByFinancialInsititution]?
    var providerGroupedByAccessTypes: [ProviderGroupedByAccessType]?
    var providers: [Provider]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        let client = TinkLink.shared.client
        //        providerContext = TinkLink.shared.makeProviderContext()
        
        let client = Client(clientId: "123")
        
        providerContext = ProviderContext(client: client)
        providerContext?.delegate = self
        //        providerContext.types = []
        //        providerContext.performFetch()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providerContext!.providerGroupsByGroupedName.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let group = providerContext!.providerGroupsByGroupedName[indexPath.item]
        cell.textLabel?.text = group.groupedName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let providerGroup = providerContext!.providerGroupsByGroupedName[indexPath.item]
        switch providerGroup {
        case .financialInsititutions(let providerGroupedByFinancialInsititutions):
            self.providerGroupedByFinancialInsititutions = providerGroupedByFinancialInsititutions
            showFinancialInstitution(for: providerGroupedByFinancialInsititutions)
        case .multupleAccessTypes(let providerGroupedByAccessTypes):
            self.providerGroupedByAccessTypes = providerGroupedByAccessTypes
            showAccessTypePicker(for: providerGroupedByAccessTypes)
        case .multipleCredentialTypes(let providers):
            self.providers = providers
            showCredentialTypePicker(for: providers)
        case .singleProvider(let provider):
            showAddCredential(for: provider)
        }
    }
    
    func showFinancialInstitution(for providerGroup: [ProviderGroupedByFinancialInsititution]) {
        performSegue(withIdentifier: "FinancialInstitutionPicker", sender: self)
    }
    
    func showAccessTypePicker(for providerGroup: [ProviderGroupedByAccessType]) {
        performSegue(withIdentifier: "AccessTypePicker", sender: self)
    }
    
    func showCredentialTypePicker(for providerGroup: [Provider]) {
        performSegue(withIdentifier: "CredentialTypePicker", sender: self)
    }
    
    func showAddCredential(for providerGroup: Provider) {
        performSegue(withIdentifier: "AddCredential", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let providerGroupOverview = segue.destination as? ProviderGroupedByFinancialInsititutionOverview {
            providerGroupOverview.providerGroupedByFinancialInsititutions = providerGroupedByFinancialInsititutions
        } else if let providerGroupOverview = segue.destination as? ProviderGroupedByAccessTypeOverview {
            providerGroupOverview.providerGroupedByAccessTypes = providerGroupedByAccessTypes
        } else if let providerGroupOverview = segue.destination as? ProvidersWithCredentialTypeOverview  {
            providerGroupOverview.providers = providers
        }
    }
}

extension ProviderListViewController: ProviderContextDelegate {
    func providersDidChange(context: ProviderContext) {
        tableView.reloadData()
    }
}
