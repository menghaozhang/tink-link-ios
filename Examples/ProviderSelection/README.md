# Provider Selection - Example Project 

This example project shows how to make a simple integration with Tink using TinkLink on iOS. The project demonstrates how display and allow users to connect to providers (banks) using their bank credentials. 

## Getting started

To run the example project, you need to set it up using Carthage. Setup all the dependencies by running `carthage bootstrap --platform iOS` in your terminal.

After that you need to open `AppDelegate.swift` and add your client id and redirect uri to the `TinkLink.Configuration` initializer.

You should now be able to run the test project and try it out.

