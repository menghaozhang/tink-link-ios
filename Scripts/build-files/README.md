## Installation

1. To install TinkLink, we use Carthage. Add a file named `Cartfile` at the root of your Xcode project and add the following:

```
binary "TinkLink.json" ~> 1.0
github "grpc/grpc-swift" ~> 0.9.1
```

Also make sure `TinkLink.json` is present at the root. 
 
1. Run `carthage update`
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
