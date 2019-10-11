
## Installation
For this release, we only support installing TinkLink through CocoaPods. Start by placing the `TinkLink` folder at the project root (where your xcodeproj file is). 

If you are already using Cocoapods, simply add `pod 'TinkLink', :path => 'TinkLink/'`  to your Podfile and do a `pod install`. 

If you are not using CocoaPods, add a file named `Podfile` to your root folder and add the following to it:
```
#Specify your deployment target
platform :ios, '11.0' 

#Replace with the name of your app target
target 'MyApp' do
  use_frameworks!

  # Pods
  pod 'TinkLink', :path => 'TinkLink/'
end
```

Then run `pod install` while at the root. Open the .xcworkspace file and you should be good to go. 
