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
	swiftformat ./Sources/ 2> /dev/null

release: format lint
