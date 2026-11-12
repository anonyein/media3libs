#!/bin/bash
set -eu

echo "Build IAMF"

IAMF_MODULE_PATH="${MEDIA3_PATH}/libraries/decoder_iamf/src/main"
GD_PATH="${MEDIA3_PATH}/libraries/decoder_iamf/build.gradle.kts"

## Fetch libiamf
cd "${IAMF_MODULE_PATH}/jni"
# Use the revision tested by Media3 1.12.0-beta01.
git clone --depth=1 --revision=e552e7d6d8b55530d201fd2764ca7e12d2c66cd6 https://github.com/AOMediaCodec/iamf-tools.git iamf_tools

cd "${IAMF_MODULE_PATH}/jni"
./build_iamf_tools.sh "${IAMF_MODULE_PATH}" "${NDK_PATH}"

## Enable publishing

echo '
apply(plugin = "media3.publish")
'>>"${GD_PATH}"
