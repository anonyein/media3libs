#!/bin/bash
set -eu

echo "Build Vp9"

VP9_MODULE_PATH="${MEDIA3_PATH}/libraries/decoder_vp9/src/main"
GD_PATH="${MEDIA3_PATH}/libraries/decoder_vp9/build.gradle.kts"


cd "${VP9_MODULE_PATH}/jni"

git clone --depth=1 -b v1.15.2 https://chromium.googlesource.com/webm/libvpx libvpx

chmod +x ./generate_libvpx_android_configs.sh
./generate_libvpx_android_configs.sh

"${NDK_PATH}/ndk-build" APP_ABI="armeabi-v7a arm64-v8a x86 x86_64" -j4


## Enable publishing
echo '
apply(plugin = "media3.publish")
'>>"${GD_PATH}"
