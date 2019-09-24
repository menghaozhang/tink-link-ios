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

### Environment Variables
Key | Value
--- | -----
`TINK_CLIENT_ID` | 
`TINK_ENVIRONMENT` | 
`TINK_BEARER_TOKEN` | *For testing*

### Swift
```swift
let configuration = TinkLink.Configuration(environment: <#Environment#>, clientId: <#String#>)
TinkLink.configure(with: configuration)
```
