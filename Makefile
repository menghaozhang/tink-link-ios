VERSION = $(shell egrep -o "MARKETING_VERSION = ([0-9.]+)" TinkLink.xcodeproj/project.pbxproj | head -n 1 | cut -d " " -f 3)

all:

bootstrap:
ifeq ($(strip $(shell command -v brew 2> /dev/null)),)
	$(error "`brew` is not available, please install homebrew")
endif
ifeq ($(strip $(shell command -v gem 2> /dev/null)),)
	$(error "`gem` is not available, please install ruby")
endif
ifeq ($(strip $(shell command -v swiftlint 2> /dev/null)),)
	brew install swiftlint
endif
ifeq ($(strip $(shell command -v swiftformat 2> /dev/null)),)
	brew install swiftformat
endif
ifeq ($(strip $(shell command -v bundle 2> /dev/null)),)
	gem install bundler
endif
	bundle install > /dev/null

generate:
	mkdir ./Sources/TinkLink/GRPC/
	./GRPC/vendor/protoc \
		--proto_path=./GRPC/proto \
		--proto_path=./GRPC/third-party \
		./GRPC/proto/*.proto ./GRPC/third-party/google/type/*.proto \
		--swift_out=./Sources/TinkLink/GRPC/ \
		--swiftgrpc_out=./Sources/TinkLink/GRPC/ \
		--swift_opt=Visibility=Internal \
		--swiftgrpc_opt=Visibility=Internal,Sync=false,Server=false \
		--plugin=protoc-gen-swift=./GRPC/vendor/protoc-gen-swift \
		--plugin=protoc-gen-swiftgrpc=./GRPC/vendor/protoc-gen-swiftgrpc

docs:
	bundle exec jazzy \
		--clean \
		--author Tink \
		--author_url https://tink.com \
		--github_url https://github.com/tink-ab/tink-link-ios \
		--github-file-prefix https://github.com/tink-ab/tink-link-ios/tree/v$(VERSION) \
		--module-version $(VERSION) \
		--build-tool-arguments -scheme,TinkLink \
		--module TinkLink \
		--output docs

lint:
	swiftlint 2> /dev/null

format:
	swiftformat . 2> /dev/null

test:
	carthage bootstrap --platform iOS
	xcodebuild -project TinkLinkSDK.xcodeproj -scheme TinkLinkSDK -destination 'platform=iOS Simulator,name=iPhone 11' test 

clean: 
	rm -rf ./Sources/TinkLink/GRPC/
	rm -rf ./docs

release: format lint

# This script builds the framework using Carthage and packages it in a zip file. This zip file can then be referenced
# in the binary specification (see https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#binary-project-specification)
# which is then referenced from the SDK users Cartfile.
# This should be run from the root folder of the TinkLink repository by running 'make build-alpha'.
build-alpha:
	# Pod and project from example project can interfere with Carthage so we remove those.
	rm -rf Examples/ProviderSelection/Pods/
	rm -rf Examples/ProviderSelection/ProviderSelection/ProviderSelection.xcworkspace

	# Build with Carthage
	echo 'Building dependencies...'
	carthage bootstrap --platform ios

	# Archive with xcodebuild
	echo 'Build iOS Framework...'
	xcodebuild archive \
		-scheme TinkLinkSDK \
		-destination="iOS" \
		-archivePath ./build/ios.xcarchive \
		-derivedDataPath /tmp/iphoneos \
		-sdk iphoneos \
		SKIP_INSTALL=NO \
		BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

	echo 'Build iOS Simulator Framework...'
	xcodebuild archive \
		-scheme TinkLinkSDK \
		-destination="iOS Simulator" \
		-archivePath ./build/iossimulator.xcarchive \
		-derivedDataPath /tmp/iphoneos \
		-sdk iphonesimulator \
		SKIP_INSTALL=NO \
		BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

	# Create XCFramework
	echo 'Assemble Frameworks...'
	xcodebuild -create-xcframework \
		-framework ./build/ios.xcarchive/Products/Library/Frameworks/TinkLinkSDK.framework \
		-framework ./build/iossimulator.xcarchive/Products/Library/Frameworks/TinkLinkSDK.framework \
		-output ./build/TinkLinkSDK.xcframework

.PHONY: all docs
