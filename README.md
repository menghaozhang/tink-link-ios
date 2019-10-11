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
You need to configure TinkLink with a client id before using.
TinkLink can be configured either by adding keys and values in your app's Info.plist, environment variables or in code.

### Info.plist
Key | Type | Value
--- | ---- | -----
`TINK_CLIENT_ID` | String |
`TINK_MARKET_CODE` | String | *Optional*
`TINK_LOCALE_IDENTIFIER` | String | *Optional*

### Environment Variables
Key | Value
--- | -----
`TINK_CLIENT_ID` | 
`TINK_MARKET_CODE` | *Optional*
`TINK_LOCALE_IDENTIFIER` | *Optional*

### Swift
```swift
let configuration = TinkLink.Configuration(clientID: <#String#>)
TinkLink.configure(with: configuration)
```

## Examples
- [Usage Examples](https://github.com/tink-ab/tink-link-ios/blob/master/USAGE.md) This document outlines how to use the different classes and types provided with TinkLink
- [Provider Selection](https://github.com/tink-ab/tink-link-ios/blob/master/Examples/ProviderSelection) This example shows how to build a complete aggregation flow using Tink Link.

## Development
1. Install [Carthage](https://github.com/Carthage/Carthage)
2. Install dependencies by running `carthage bootstrap --platform iOS`
3. Open project `xed .`
