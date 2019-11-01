# Provider Selection - Example Project 

This example project shows how to make a simple integration with Tink using TinkLink on iOS. The project demonstrates how display and allow users to connect to providers (financial institutions) using their credentials. 

## Prerequisites

1. Follow the [getting started guide](https://docs.tink.com/resources/getting-started/set-up-your-account) to create your developer account and retrieve your Client ID.
2. Register the Redirect URI for your app (e.g. `myapp://callback`) in the list of allowed redirect URIs.
Note: The `TinkLink.Configuration` has been prefilled with `link-demo://`, you need add the deeplink  `link-demo://` at [TinkLink Console](`https://console.tink.com`)  as redirectURI. This redirectURI should be the same as the deep link in the info.plist (link-demo://).

## Getting started

1. To run the example project, you need to set it up using Carthage. [Quick start guide for Carthage](https://github.com/Carthage/Carthage#quick-start)
1. Go to the sample app directory, setup all the dependencies by running `carthage bootstrap --platform iOS` in your terminal.
1. Find the `TinkLink.framework` provided by Tink, move the `TinkLink.framework` binary to generated `Carthage/Build/iOS/` folder.
1. Drag the built `.framework` binaries (TinkLink, SwiftyMarkdown, SwiftProtobuf, BoringSSL, CgRPC and SwiftGRPC) from `Carthage/Build/iOS` into the _Linked Binary With Libraries_ section on your application targets’ _Build Phases_ tab. Please select `Do Not Embed`

After that you need to open `AppDelegate.swift` and add your client id and redirect uri to the `TinkLink.Configuration` initializer.

You should now be able to run the test project and try it out.
