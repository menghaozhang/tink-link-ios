# Tink Link iOS

## Prerequisites
1. Create your developer account at [Tink Console](https://console.tink.com/).
2. Follow the getting started guide to retrieve your Client ID.
3. Register the Redirect URI for your app (e.g. `myapp://callback`) in the list of allowed redirect URIs.

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
- Create credential
- Supplemental information
- 
