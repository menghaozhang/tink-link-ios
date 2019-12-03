# Provider Selection - Example Project 

This example project shows how to make a simple integration with Tink using TinkLink on iOS. The project demonstrates how display and allow users to connect to providers (financial institutions) using their credentials. 

## Prerequisites

1. Create your developer account at [Tink Console](https://console.tink.com)
1. Follow the [getting started guide](https://docs.tink.com/resources/getting-started/set-up-your-account) to retrieve your `client_id` and `client_secret`
1. Add the custom URL scheme for this app (`link-demo://tink`) to the [list of redirect URIs under your app's settings](https://console.tink.com/overview)

## Getting started

1. To run the example project, you will need to set it up using [Carthage](https://github.com/Carthage/Carthage#quick-start). 
1. In the example app directory, setup all the dependencies by running `carthage bootstrap --platform iOS`.
1. Find the built `TinkLinkSDK.xcframework` and drag it into the _Frameworks, Libraries, and Embedded Content_  section on your application targets’ _General_ tab

After that you need to open `AppDelegate.swift` and add your client id and redirect uri to the `TinkLink.Configuration` initializer.

You should now be able to run the test project and try it out.
