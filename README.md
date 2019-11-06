![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/languages-swift-orange.svg)

# Tink Link iOS

## Prerequisites

1. Create your developer account at [Tink Console](https://console.tink.com)
1. Follow the [getting started guide](https://docs.tink.com/resources/getting-started/set-up-your-account) to retrieve your `client_id` and `client_secret`
1. Add a deep link to your app (`yourapp://`) to the [list of redirect URIs under your app's settings](https://console.tink.com/overview)

## Installation

[Carthage](https://github.com/Carthage/Carthage#installing-carthage) is used to integrate Tink Link into your project.

1. Add a file named `Cartfile` at the root of your Xcode project with the following contents:

```
github "grpc/grpc-swift" ~> 0.9.1
```

2. Run `carthage bootstrap --platform iOS`
3. Move the `TinkLink.framework` binary to the generated `Carthage/Build/iOS/` folder
4. Drag the built `.framework` binaries (BoringSSL, CgRPC, SwiftGRPC, SwiftProtobuf and TinkLink) from `Carthage/Build/iOS` into the _Linked Binary With Libraries_ section on your application targets’ _Build Phases_ tab
5. Move the `input.xcfilelist` and `output.xcfilelist` files into the root of your Xcode project
6. On your application targets’ _Build Phases_ settings tab, click the _+_ icon and choose _New Run Script Phase_ with the following contents:

```sh
/usr/local/bin/carthage copy-frameworks
```

- Add the `input.xcfilelist` to the _Input File Lists_ section of the run script phase
- Add the `output.xcfilelist` to the _Output File Lists_ section of the run script phase

You should now be able to `import TinkLink` within your project.

## Configuration

To start using Tink Link, you will need to configure a `TinkLink` instance with your client ID and redirect URI.

### Swift

```swift
let configuration = TinkLink.Configuration(clientID: <#String#>, redirectURI: <#URL#>)
TinkLink.configure(with: configuration)
```

### Environment Variables

The shared instance of TinkLink can also be configured using environment variables defined in your application's target run scheme.

| Key                         | Value      |
| --------------------------- | ---------- |
| `TINK_CLIENT_ID`            | String     |
| `TINK_REDIRECT_URI`         | String     |
| `TINK_CUSTOM_GRPC_ENDPOINT` | _Optional_ |
| `TINK_CUSTOM_REST_ENDPOINT` | _Optional_ |
| `TINK_GRPC_CERTIFICATE`     | _Optional_ |
| `TINK_REST_CERTIFICATE`     | _Optional_ |

## Redirect Handling

You will need to add a custom URL scheme or support universal links to handle redirects from a third party authentication flow back into your app.

Follow the instructions at one of these links for how to set this up:

- [Defining a Custom URL Scheme for Your App](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)
- [Allowing Apps and Websites to Link to Your Content](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content)

## Examples

- [Usage Examples](https://github.com/tink-ab/tink-link-ios/blob/master/USAGE.md) This document outlines how to use the different classes and types provided by Tink Link.
- [Provider Selection](https://github.com/tink-ab/tink-link-ios/blob/master/Examples/ProviderSelection) This example shows how to build a complete aggregation flow using Tink Link.
