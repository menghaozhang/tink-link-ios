# Tink Link iOS

## Installation

### [CocoaPods](https://cocoapods.org)
```ruby
pod "TinkLink"
```

### [Carthage](https://github.com/Carthage/Carthage)
```ogdl
github "tink-ab/tink-link-ios"
```

## Configuration

### Info.plist
Key | Type | Value
--- | ---- | -----
`TINK_ENVIRONMENT` | String | `production` or `staging` 
`TINK_CLIENT_ID` | String |
`TINK_REDIRECT_URL` | String |
`TINK_TIMEOUT_INTERVAL` | String | *Optional*
`TINK_CERTIFICATE_FILE_NAME` | String | *Optional*

### Environment Variables
Key | Value
--- | -----
`TINK_CLIENT_KEY` | 
`TINK_OAUTH_CLIENT_ID`| 
`TINK_CERTIFICATE`| 
`TINK_BEARER_TOKEN` | *For testing*
`TINK_SESSION_ID` | *For testing*

### Swift
```swift
let configuration = TinkLink.Configuration(environment: <#Environment#>, clientId: <#String#>, redirectUrl: <#URL#>)
TinkLink.configure(with: configuration)
```
