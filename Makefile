generate:
	mkdir ./Sources/TinkGRPC/
	./GRPC/vendor/protoc \
		--proto_path=./GRPC/proto \
		--proto_path=./GRPC/third-party \
		./GRPC/proto/*.proto \
		--swift_out=./Sources/TinkGRPC/ \
		--swiftgrpc_out=./Sources/TinkGRPC/ \
		--swift_opt=Visibility=Public \
		--swiftgrpc_opt=Visibility=Public,Sync=false,Server=false \
		--plugin=protoc-gen-swift=./GRPC/vendor/protoc-gen-swift \
		--plugin=protoc-gen-swiftgrpc=./GRPC/vendor/protoc-gen-swiftgrpc

test:
	swift test -Xcc -ISources/BoringSSL/include -Xlinker -lz

clean: 
	-rm -rf ./Sources/TinkGRPC/
