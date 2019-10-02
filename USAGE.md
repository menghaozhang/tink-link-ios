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
### Initiate creating credential
- Creates a form for the given provider.
```swift
let form = Form(provider: <#Provider#>)
form.fields[0].text = <#String#>
form.fields[1].text = <#String#>
/// or
form.fields[name: "username"]?.text = <#String#>
form.fields[name: "password"]?.text = <#String#>
...
```

- Validate before submit request to add credential
	- Use `areFieldsValid` to return a boolean value that indicate if all form fields are valid. 
	- For example, you can use `areFieldsValid` to enable a submit button when text fields change.
	```swift
	@objc func textFieldDidChange(_ notification: Notification) {
	    submitButton.isEnabled = form.areFieldsValid
	}
	```

	- Use validateFields() to validate fields which can throw errors that contain more info about which fields are not valid and why

	```swift
	do {
    	try form.validateFields()
	} catch let error as Form.Fields.ValidationError {
    	if let usernameFieldError = error[fieldName: "username"] {
        	usernameValidationErrorLabel.text = usernameFieldError.errorDescription
	    }
	}
	```

- Add Credential with form fields

### Supplemental information
- Creates a form for the given credential.
```swift
let form = Form(credential: <#Credential#>)
form.fields[0].text = <#String#>
form.fields[1].text = <#String#>
/// or
form.fields[name: "username"]?.text = <#String#>
form.fields[name: "password"]?.text = <#String#>
...
```

- Validate before submit request to update credential(Same as validate for the provider form)
- Submit update supplement information

### Third party app authentication
- BankID
- Other

### Updated
