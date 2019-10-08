# Tink Link iOS

## Prerequisites
1. Follow the [getting started guide](https://docs.tink.com/resources/getting-started/set-up-your-account) to create your developer account and retrieve your Client ID.
2. Register the Redirect URI for your app (e.g. `myapp://callback`) in the list of allowed redirect URIs.

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
`TINK_CLIENT_ID` | String |

### Environment Variables
Key | Value
--- | -----
`TINK_CLIENT_ID` | 
`TINK_BEARER_TOKEN` | *For testing*

### Swift
```swift
let configuration = TinkLink.Configuration(clientID: <#String#>)
TinkLink.configure(with: configuration)
```

## [Usage](https://github.com/tink-ab/tink-link-ios/blob/master/USAGE.md)
### List Provider

### Add Credential
- [Create credential](https://github.com/tink-ab/tink-link-ios/blob/master/USAGE.md#add-credential)
