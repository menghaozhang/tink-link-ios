# Usage example

## List providers
Here's how you list providers.
```swift
class ProviderListViewController: UITableViewController, ProviderContextDelegate {
    let providerContext = ProviderContext()
    var providers: [Provider]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        providerContext.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func providerContextDidChangeProviders(_ context: ProviderContext) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let provider = providers[indexPath.row]
        cell.textLabel?.text = provider.displayName
        return cell
    }
}
```

## Add credential
### Creating and updating a form
Creates a form for the given provider.
```swift
let form = Form(provider: <#Provider#>)
form.fields[0].text = <#String#>
form.fields[1].text = <#String#>
```
or
```swift
form.fields[name: "username"]?.text = <#String#>
form.fields[name: "password"]?.text = <#String#>
...
```

### Form validation
Validate before you submit a request to add credential or supplement information.

Use `areFieldsValid` to return a boolean value that indicate if all form fields are valid. 
    
For example, you can use `areFieldsValid` to enable a submit button when text fields change.
```swift
@objc func textFieldDidChange(_ notification: Notification) {
    submitButton.isEnabled = form.areFieldsValid
}
```

Use validateFields() to validate all fields. If not valid, it will throw an error that contains more information about which fields are not valid and why

```swift
do {
    try form.validateFields()
} catch let error as Form.Fields.ValidationError {
    if let usernameFieldError = error[fieldName: "username"] {
        usernameValidationErrorLabel.text = usernameFieldError.errorDescription
    }
}
```

### Add Credential with form fields
```swift
credentialContext.addCredential(for: provider, form: form, progressHandler: { status in
    switch status {
    case .awaitingSupplementalInformation(let supplementInformationTask):
        <#Present form for supplemental information task#>
    case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthentication):
        <#Open third party app deep link URL#>
    default:
        break
    }
}, completion: { result in
    <#Handle result#>
}
```

### Handling awaiting supplemental information
Creates a form for the given credential. Usually you get the credential from `SupplementInformationTask`.
```swift
let form = Form(credential: supplementInformationTask.credential)
form.fields[0].text = <#String#>
form.fields[1].text = <#String#>
```

- Submit update supplement information

### Third party app authentication
- BankID
- Other

### Updated
