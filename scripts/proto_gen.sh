protoc \
  --experimental_allow_proto3_optional \
  --dart_out=grpc:lib/generated \
  --proto_path=third_party/v2ray-core \
  $(find third_party/v2ray-core -name "*.proto")