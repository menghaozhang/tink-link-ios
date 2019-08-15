# gRPC

## Update compiler and plugins
1. Download the latest Protobuf compiler here: [Protobuf Releases](https://github.com/protocolbuffers/protobuf/releases)
2. Checkout the latest tag of [Swift gPRC](https://github.com/grpc/grpc-swift) and run `make plugin`
3. Replace executables in GRPC/vendor.

## Update TinkGRPC
1. Replace `.proto` files in `./GRPC/proto` directory with latest files from [Tink gRPC](https://github.com/tink-ab/tink-grpc).
2. Run `make generate` to generate new Swift code.
