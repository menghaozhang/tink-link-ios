# Usage Examples

## How to list and select providers

### Listing and responding to changes

Here's how you can list all providers with a `UITableViewController` subclass.

```swift
class ProviderListViewController: UITableViewController, ProviderContextDelegate {
    let providerContext = ProviderContext()
    var providers: [Provider]

    override func viewDidLoad() {
        super.viewDidLoad()
        providerContext.delegate = self
        providers = providerContext.providers
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    func providerContextDidChangeProviders(_ context: ProviderContext) {
        DispatchQueue.main.async {
            self.providers = context.providers
            self.tableView.reloadData()
        }
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

### Provider groups

Use the `providerGroups` property on `ProviderContext` to get providers grouped by financial institution, access type and credential kind.

Handle selection of a provider group by switching on the group to decide which screen should be shown next.

```swift
override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let providerGroup = providerGroups[indexPath.row]
    switch providerGroup {
    case .financialInsititutions(let financialInsititutionGroups):
        showFinancialInstitution(for: financialInsititutionGroups)
    case .accessTypes(let accessTypeGroups):
        showAccessTypePicker(for: accessTypeGroups)
    case .credentialKinds(let providers):
        showCredentialKindPicker(for: providers)
    case .provider(let provider):
        showAddCredentialFlow(for: provider)
    }
}
```

## Add credential

### Creating and updating a form

A `Form` is used to determine what a user needs to input in order to proceed. For example it could be a username and a password field.

Here's how to create a form for a provider with a username and password field and how to update the fields.

```swift
var form = Form(provider: <#Provider#>)
form.fields[name: "username"]?.text = <#String#>
form.fields[name: "password"]?.text = <#String#>
...
```

### Configuring UITextFields from form fields

```swift
for field in form.fields {
    let textField = UITextField()
    textField.placeholder = field.attributes.placeholder
    textField.isSecureTextEntry = field.attributes.isSecureTextEntry
    textField.isEnabled = field.attributes.isEditable
    textField.text = field.text
    <#Add to view#>
}
```

### Form validation

Validate before you submit a request to add credential or supplement information.

Use `areFieldsValid` to check if all form fields are valid. For example, you can use this to enable a submit button when text fields change.

```swift
@objc func textFieldDidChange(_ notification: Notification) {
    submitButton.isEnabled = form.areFieldsValid
}
```

Use validateFields() to validate all fields. If not valid, it will throw an error that contains more information about which fields are not valid and why.

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

To add a credential for the current user, call `addCredential` with the provider you want to add a credential for and a form with valid fields for that provider.
Then handle status changes in the `progressHandler` closure and the `result` from the completion handler.

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

Submit update supplement information after validating like this:

```swift
do {
    try form.validateFields()
    supplementInformationTask.submit(form)
} catch {
    <#Handle error#>
}
```

After submitting the form new status updates will sent to the `progressHandler` in the `addCredential` call.

### Handling third party app authentication

When progressHandler get a `awaitingThirdPartyAppAuthentication` status you need to try to open the url provided by `ThirdPartyAppAuthentication`. Check if the system can open the url or ask the user to download the app like this:

```swift
if let deepLinkURL = thirdPartyAppAuthentication.deepLinkURL, UIApplication.shared.canOpenURL(deepLinkURL) {
    UIApplication.shared.open(deepLinkURL)
} else {
    <#Ask user to download app#>
}
```

Here's how you can ask the user to download the third party app via an alert:

```swift
let alertController = UIAlertController(title: thirdPartyAppAuthentication.downloadTitle, message: thirdPartyAppAuthentication.downloadMessage, preferredStyle: .alert)

if let appStoreURL = thirdPartyAppAuthentication.appStoreURL, UIApplication.shared.canOpenURL(appStoreURL) {
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    let downloadAction = UIAlertAction(title: "Download", style: .default, handler: { _ in
        UIApplication.shared.open(appStoreURL)
    })
    alertController.addAction(cancelAction)
    alertController.addAction(downloadAction)
} else {
    let okAction = UIAlertAction(title: "OK", style: .default)
    alertController.addAction(okAction)
}

present(alertController, animated: true)
```

After the redirect to the third party app, some providers requires additional information to be sent to Tink after the user authenticates with the third party app for the credential to be added successfully. This information is passed to your app via the redirect URI. Use the open method in your `UIApplicationDelegate` to let TinkLink send the information to Tink if needed.
```swift
func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return TinkLink.shared.open(url)
}
```

## Advanced usage 
In some cases, you may want to have multiple `TinkLink` instances, you can create your custom `TinkLink` instance like this:

```swift
let configuration = TinkLink.Configuration(clientID: <#T##String#>, redirectURI: <#T##URL#>)
let customTinkLink = TinkLink(configuration: configuration)
```
 
### Listing providers

Instead of using `ProviderContext` for listing `ProviderGroup`, you can directly use the `ProviderService` for fetching providers and grouping them with custom logic. 
Make sure to register an access token before using the service.

```swift
var authenticationCancellable: Cancellable?
var providerCancellable: Cancellable?

let userService = UserService(tinkLink: customTinkLink)
authenticationCancellable = userService.createAnonymous(market: customTinkLink.configuration.market, locale: customTinkLink.configuration.locale) { [weak self] result in
    guard let self = self else { return }
    if let accessToken = try? result.get() {
        let providerService = ProviderService(tinkLink: customTinkLink, accessToken: accessToken)
        self.providerCancellable = providerService.providers(market: customTinkLink.configuration.market, capabilities: .all, includeTestProviders: true) { [weak self] result in
            guard let self = self else { return }
            if let providers = try? result.get() {
                <#Your Code#>
            }
        }
    }
}
```
