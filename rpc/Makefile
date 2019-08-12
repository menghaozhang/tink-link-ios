generate:
	mkdir ./source/
	./vendor/protoc \
		--proto_path=proto \
		--proto_path=third-party \
		./proto/*.proto \
		--swift_out=./source/ \
		--swiftgrpc_out=./source/ \
		--swift_opt=Visibility=Public \
		--swiftgrpc_opt=Visibility=Public,Sync=false,Server=false \
		--plugin=protoc-gen-swift=./vendor/protoc-gen-swift \
		--plugin=protoc-gen-swiftgrpc=./vendor/protoc-gen-swiftgrpc

clean: 
	-rm -rf ./source/
