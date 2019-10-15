all:

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

test:
	swift test -Xcc -ISources/BoringSSL/include -Xlinker -lz

clean: 
	-rm -rf ./Sources/TinkLink/GRPC/

bootstrap:
ifeq ($(strip $(shell command -v brew 2> /dev/null)),)
	$(error "`brew` is not available, please install homebrew")
endif
	brew install swiftlint swiftformat > /dev/null

lint:
ifeq ($(strip $(shell command -v swiftlint 2> /dev/null)),)
	$(error "`swiftlint` is not available, please run `make bootstrap` first")
endif
	swiftlint 2> /dev/null

format:
ifeq ($(strip $(shell command -v swiftformat 2> /dev/null)),)
	$(error "`swiftformat` is not available, please run `make bootstrap` first")
endif
	swiftformat . 2> /dev/null

release: format lint

#This script builds the framework using Carthage and packages it in a zip file. This zip file can then be referenced
#in the binary specification (see https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#binary-project-specification)
#which is then referenced from the SDK users Cartfile.
#This should be run from the root folder of the TinkLink repository by running 'make build-alpha'.
build-alpha:
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
