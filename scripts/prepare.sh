#!/bin/bash

os="$1"

dart run build_runner build

dart pub global activate protoc_plugin
export PATH="$PATH":"$HOME/.pub-cache/bin"
mkdir -p lib/generated/grpc/v2ray-core
protoc \
  --experimental_allow_proto3_optional \
  --dart_out=grpc:lib/generated/grpc/v2ray-core \
  --proto_path=third_party/v2ray-core \
  $(find third_party/v2ray-core -name "*.proto")

get_v2ray_assets () {
  wget https://github.com/v2fly/geoip/releases/latest/download/geoip.dat
  wget -O geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat
}

init_gomobile () {
  cd third_party/libv2raymobile
  go install golang.org/x/mobile/cmd/gomobile@latest
  go install golang.org/x/mobile/cmd/gobind@latest
  go get golang.org/x/mobile/cmd/gomobile
  go get golang.org/x/mobile/cmd/gobind
  gomobile init
  cd -
}

if [[ $os == "linux" ]]; then
  sudo apt-get update
  sudo apt-get install -y ninja-build build-essential
  sudo apt-get install libayatana-appindicator3-dev

elif [[ $os == "android" ]]; then
  init_gomobile
  cd third_party/libv2raymobile
  gomobile bind -v -ldflags='-s -w' -androidapi 21 -o ../../android/app/libs/libv2raymobile.aar
  cd -

  cd android/app/src/main/assets
  get_v2ray_assets
  cd -

elif [[ $os == "ios" ]]; then
  init_gomobile
  cd third_party/libv2raymobile
  mkdir build
  # https://github.com/golang/go/issues/58416
  gomobile bind -v -tags=netgo -ldflags='-s -w' -target=ios -o ./build/Libv2raymobile.xcframework
  cd -

  cd ios/PacketTunnel/Assets
  get_v2ray_assets
  cd -

  cd third_party/hev-socks5-tunnel
  ./build.sh
  mkdir build
  mv HevSocks5Tunnel.xcframework build
  cd -
fi
