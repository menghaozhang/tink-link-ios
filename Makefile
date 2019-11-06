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
	xcodebuild -project TinkLink.xcodeproj -scheme TinkLink -destination 'platform=iOS Simulator,name=iPhone 11' test 

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
	echo 'Building...'
	carthage bootstrap --platform ios
	carthage build --no-skip-current

	# Put together the different build files into a zip
	echo 'Packaging...'
	carthage archive
	mkdir -p build
	mv TinkLink.framework.zip build/

	# Copy input output files
	cp input.xcfilelist build/
	cp output.xcfilelist build/

.PHONY: all docs
