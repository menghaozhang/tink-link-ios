#!/bin/bash

#This script builds the framework using Carthage and packages it in a zip file. This zip file can then be referenced
#in the binary specification (see https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#binary-project-specification)
#which is then referenced from the SDK users Cartfile. 
#This should be run from the root folder of the TinkLink repository by running './Scripts/build.sh'.

#remove old Carthage files
echo 'Removing old build files...'
rm -rf Carthage/

#Pod and project from example project can interfere with Carthage so we remove those. 
rm -rf Examples/ProviderSelection/Pods/
rm -rf Examples/ProviderSelection/ProviderSelection/ProviderSelection.xcworkspace

#Build with Carthage
echo 'Building...'
carthage bootstrap --platform ios
carthage build --no-skip-current

#Put together the different build files into a zip
echo 'Packaging...'
carthage archive
mkdir -p build
mv TinkLink.framework.zip build/
