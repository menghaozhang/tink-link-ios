# Usage example

## List provider/provider group
- Fetch provider list from Tink
## Add credential
### Initiate creating credential
- Creates a form for the given provider.
```swift
	let form = Form(provider: <#Provider#>)
	form.fields[0].text = <#String#>
	form.fields[1].text = <#String#>
	...
```

- Validate before submit request to add credential
```swift
/// Use `areFieldsValid` to return a boolean value that indicate if all form fields are valid
form.areFieldsValid
/// Use validateFields() to validate fields and throw errors that contain more info if values in the fields are not valid
form.validateFields()
```

- Add Credential with form fields
### Supplemental information
- Creates a form for the given credential.
```swift
let form = Form(provider: <#Credential#>)
form.fields[0].text = <#String#>
form.fields[1].text = <#String#>
...
```

- Validate before submit request to update credential
- Submit update supplement information 
### Third party app authentication
- BankID
- Other
### Updated