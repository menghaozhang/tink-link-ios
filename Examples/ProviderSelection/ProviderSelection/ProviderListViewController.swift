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
        providers = [
            Provider(name: "Avanza", financialInstitutionID: "Avanza", groupedName: "Avanza", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification]),
            Provider(name: "SBAB BankID", financialInstitutionID: "SBAB", groupedName: "SBAB", accessType: .reverseEngineering, credentialType: .bankID, fields: [Provider.personalNumberFieldSpecification]),
            Provider(name: "SBAB Password", financialInstitutionID: "SBAB", groupedName: "SBAB", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification]),
            Provider(name: "SEB BankID", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .reverseEngineering, credentialType: .bankID, fields: [Provider.personalNumberFieldSpecification]),
            Provider(name: "SEB Password", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification]),
            Provider(name: "SEB openbanking", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .openBanking, credentialType: .thirdParty, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification]),
            Provider(name: "Nordea BankID", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .reverseEngineering, credentialType: .bankID, fields: [Provider.personalNumberFieldSpecification]),
            Provider(name: "Nordea Password", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification]),
            Provider(name: "Nordea Openbanking", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .openBanking, credentialType: .thirdParty, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification]),
            Provider(name: "Nordea", financialInstitutionID: "Nordea Other", groupedName: "Nordea", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification])
        ]
    }
    var providers: [Provider] {
        didSet {
            delegate?.providersDidChange(self)
        }
    }
    lazy var providerGroupsByGroupedName: [ProviderGroupedByGroupedName] = {
       return _providerGroupsByGroupedName
    }()
    weak var delegate: ProviderContextDelegate?
    
    private lazy var _providerGroupsByGroupedName: [ProviderGroupedByGroupedName] = {
        let providerGroupedByGroupedName = Dictionary(grouping: providers, by: { $0.groupedName })
        let groupedNames = providerGroupedByGroupedName.map { $0.key }
        var providerGroupsByGroupedNames = [ProviderGroupedByGroupedName]()
        groupedNames.forEach { groupName in
            let providersWithSameGroupedName = providers.filter({ $0.groupedName == groupName })
            providerGroupsByGroupedNames.append(ProviderGroupedByGroupedName(providers: providersWithSameGroupedName))
            
        }
        return providerGroupsByGroupedNames.sorted(by: { $0.providers.count < $1.providers.count })
    }()
}

protocol ProviderContextDelegate: AnyObject {
    func providersDidChange(_ context: ProviderContext)
}

final class ProviderListViewController: UITableViewController {
    var providerContext: ProviderContext?
    var providerGroupedByFinancialInsititutions: [ProviderGroupedByFinancialInsititution]?
    var providerGroupedByAccessTypes: [ProviderGroupedByAccessType]?
    var providers: [Provider]?
    var provider: Provider?
    
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
            self.provider = provider
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
        if let financialInstitutionPickerViewController = segue.destination as? FinancialInstitutionPickerViewController {
            financialInstitutionPickerViewController.providerGroupedByFinancialInsititutions = providerGroupedByFinancialInsititutions
        } else if let accessTypePickerViewController = segue.destination as? AccessTypePickerViewController {
            accessTypePickerViewController.providerGroupedByAccessTypes = providerGroupedByAccessTypes
        } else if let credentialTypePickerViewController = segue.destination as? CredentialTypePickerViewController  {
            credentialTypePickerViewController.providers = providers
        } else if let addCredentialViewController = segue.destination as? AddCredentialViewController {
            addCredentialViewController.provider = provider
        }
    }
}

extension ProviderListViewController: ProviderContextDelegate {
    func providersDidChange(_ context: ProviderContext) {
        tableView.reloadData()
    }
}
