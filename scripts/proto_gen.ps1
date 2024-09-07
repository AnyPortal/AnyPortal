# Assuming your project root is the base
$protoBasePath = "third_party\v2ray-core"
# Find all .proto files under third_party/v2ray-core
Get-ChildItem -Recurse $protoBasePath -Filter *.proto | ForEach-Object {
    # Generate stubs, with the proto_path being the parent of third_party
    protoc --dart_out=grpc:"lib\generated\grpc\v2ray-core" --proto_path=$protoBasePath $_.FullName
}