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

    var providerGroups: [ProviderGroup] = [
        ProviderGroup(providers: [
            Provider(name: "Amex"),
            Provider(name: "SAS")
            ]),
        ProviderGroup(providers: [Provider(name: "Avanza")]),
        ProviderGroup(providers: [
            Provider(name: "Nordea Openbanking"),
            Provider(name: "Nordea BankID"),
            Provider(name: "Nordea Password")
            ])
    ]
}

struct Provider {
    let name: String
}

struct ProviderGroup {
    var providers: [Provider]
    var name: String { return providers.first?.name ?? "" }
    var financialInstitutions: [String] = []
    var accessTypes: [Int] = []
    var credentialTypes: [Int] = []

    init(providers: [Provider]) {
        self.providers = providers
    }
}

protocol ProviderContextDelegate: AnyObject {
    func providersDidChange(context: ProviderContext)
}

class ProviderListViewController: UITableViewController {
    var providerContext: ProviderContext?

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
        return providerContext!.providerGroups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let group = providerContext!.providerGroups[indexPath.item]
        cell.textLabel?.text = group.name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let providerGroup = providerContext!.providerGroups[indexPath.item]
        if providerGroup.financialInstitutions.count > 1 {
            showFinancialInstitution(for: providerGroup)
        } else if providerGroup.accessTypes.count > 1 {
            showAccessTypePicker(for: providerGroup)
        } else if providerGroup.credentialTypes.count > 1 {
            showCredentialTypePicker(for: providerGroup)
        } else {
            showAddCredential(for: providerGroup)
        }
    }

    func showFinancialInstitution(for providerGroup: ProviderGroup) {
        performSegue(withIdentifier: "FinancialInstitutionPicker", sender: self)
    }

    func showAccessTypePicker(for providerGroup: ProviderGroup) {
        performSegue(withIdentifier: "AccessTypePicker", sender: self)
    }

    func showCredentialTypePicker(for providerGroup: ProviderGroup) {
        performSegue(withIdentifier: "CredentialTypePicker", sender: self)
    }

    func showAddCredential(for providerGroup: ProviderGroup) {
        performSegue(withIdentifier: "AddCredential", sender: self)
    }
}

extension ProviderListViewController: ProviderContextDelegate {
    func providersDidChange(context: ProviderContext) {
        tableView.reloadData()
    }
}
