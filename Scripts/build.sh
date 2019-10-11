#!/bin/bash

#This is a really naive script that builds and packages the TinkLink iOS framework in a zip with a readme and podspec. 
#This should be run from the root folder of the TinkLink repository by running './Scripts/build.sh'.

VERSION_NAME='0.1-alpha'
ZIP_FILENAME='tinklink-ios-'${VERSION_NAME}
PODSPEC_PATH='Scripts/build-files/TinkLink.podspec'
README_PATH='Scripts/build-files/README.md'

#remove old Carthage files
echo 'Removing old build files...'
rm -rf Carthage/

#Init the test project with CocoaPods 
echo 'Building...'
cd Examples/ProviderSelection
pod install
cd ../..

#Build with Carthage
carthage build --no-skip-current

#Put together the different build files into a zip
echo 'Packaging...'
mkdir -p build/$ZIP_FILENAME/TinkLink
cp -R Carthage/Build/iOS/TinkLink.framework build/$ZIP_FILENAME/TinkLink
cp $PODSPEC_PATH build/$ZIP_FILENAME/TinkLink
cp $README_PATH build/$ZIP_FILENAME
cd build; zip -r $ZIP_FILENAME.zip $ZIP_FILENAME; cd ..;

#Cleanup 
echo 'Cleaning up...'
rm -rf build/$ZIP_FILENAME

echo 'Done! Zipped framework can be found in build folder.'
