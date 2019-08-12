generate:
	mkdir ./GRPC/Sources/
	./GRPC/vendor/protoc \
		--proto_path=./GRPC/proto \
		--proto_path=./GRPC/third-party \
		./GRPC/proto/*.proto \
		--swift_out=./GRPC/Sources/ \
		--swiftgrpc_out=./GRPC/Sources/ \
		--swift_opt=Visibility=Public \
		--swiftgrpc_opt=Visibility=Public,Sync=false,Server=false \
		--plugin=protoc-gen-swift=./GRPC/vendor/protoc-gen-swift \
		--plugin=protoc-gen-swiftgrpc=./GRPC/vendor/protoc-gen-swiftgrpc

clean: 
	-rm -rf ./GRPC/Sources/
