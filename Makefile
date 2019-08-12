generate:
	mkdir ./rpc/Sources/
	./rpc/vendor/protoc \
		--proto_path=./rpc/proto \
		--proto_path=./rpc/third-party \
		./rpc/proto/*.proto \
		--swift_out=./rpc/Sources/ \
		--swiftgrpc_out=./rpc/Sources/ \
		--swift_opt=Visibility=Public \
		--swiftgrpc_opt=Visibility=Public,Sync=false,Server=false \
		--plugin=protoc-gen-swift=./rpc/vendor/protoc-gen-swift \
		--plugin=protoc-gen-swiftgrpc=./rpc/vendor/protoc-gen-swiftgrpc

clean: 
	-rm -rf ./rpc/Sources/
