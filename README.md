# Tink Link iOS

## Prerequisites

1. Follow the [getting started guide](https://docs.tink.com/resources/getting-started/set-up-your-account) to create your developer account and retrieve your Client ID.
2. Register the Redirect URI for your app (e.g. `myapp://callback`) in the list of allowed redirect URIs.

## Installation

1. To install TinkLink, we use Carthage. Add a file named `Cartfile` at the root of your Xcode project and add the following:

```
binary "TinkLink.json" ~> 0.1.0
github "grpc/grpc-swift" ~> 0.9.1
```

Also make sure `TinkLink.json` is present at the root.

1. Run `carthage bootstrap --platform iOS`
1. Drag the built `.framework` binaries (TinkLink, SwiftProtobuf, BoringSSL, CgRPC and SwiftGRPC) from `Carthage/Build/<platform>` into your application’s Xcode project.
1. On your application targets’ _Build Phases_ settings tab, click the _+_ icon and choose _New Run Script Phase_. Create a Run Script in which you specify your shell (ex: `/bin/sh`), add the following contents to the script area below the shell:

   ```sh
   /usr/local/bin/carthage copy-frameworks
   ```

- Add the paths to the frameworks under "Input Files":

  ```
  $(SRCROOT)/Carthage/Build/iOS/TinkLink.framework
  $(SRCROOT)/Carthage/Build/iOS/SwiftProtobuf.framework
  $(SRCROOT)/Carthage/Build/iOS/BoringSSL.framework
  $(SRCROOT)/Carthage/Build/iOS/CgRPC.framework
  $(SRCROOT)/Carthage/Build/iOS/SwiftGRPC.framework
  ```

- Also add the paths to the frameworks under "Output Files":

  ```
  $(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/TinkLink.framework
  $(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/SwiftProtobuf.framework
  $(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/BoringSSL.framework
  $(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/CgRPC.framework
  $(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/SwiftGRPC.framework
  ```

  - You should now be able to use TinkLink within your project.

## Configuration

You need to configure TinkLink with a client id and redirect URI before using.
TinkLink can be configured either by adding keys and values in your app's Info.plist, environment variables or in code.

### Environment Variables

| Key                      | Value      |
| ------------------------ | ---------- |
| `TINK_CLIENT_ID`         | String     |
| `TINK_REDIRECT_URI`      | String     |
| `TINK_MARKET_CODE`       | _Optional_ |
| `TINK_LOCALE_IDENTIFIER` | _Optional_ |

### Swift

```swift
let configuration = TinkLink.Configuration(clientID: <#String#>, redirectURI: <#URL#>)
TinkLink.configure(with: configuration)
```

## Redirect Handling

You need to add a custom URL scheme or support universal links to handle redirects from a third party authentication flow back into your app. Follow the instructions at one of these links for how to set this up:

- [Defining a Custom URL Scheme for Your App](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)
- [Allowing Apps and Websites to Link to Your Content](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content)

## Examples

- [Usage Examples](https://github.com/tink-ab/tink-link-ios/blob/master/USAGE.md) This document outlines how to use the different classes and types provided with TinkLink
- [Provider Selection](https://github.com/tink-ab/tink-link-ios/blob/master/Examples/ProviderSelection) This example shows how to build a complete aggregation flow using Tink Link.

## Development

1. Install [Carthage](https://github.com/Carthage/Carthage)
2. Install dependencies by running `carthage bootstrap --platform iOS`
3. Open project `xed .`
