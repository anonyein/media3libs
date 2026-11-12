#!/bin/bash
set -eu

echo "Build IAMF"

IAMF_MODULE_PATH="${MEDIA3_PATH}/libraries/decoder_iamf/src/main"
GD_PATH="${MEDIA3_PATH}/libraries/decoder_iamf/build.gradle.kts"

## Fetch libiamf
IAMF_REVISION=$(sed -nE 's/.*--revision=([0-9a-f]{40}).*/\1/p' "${MEDIA3_PATH}/libraries/decoder_iamf/README.md")
if [[ ! "$IAMF_REVISION" =~ ^[0-9a-f]{40}$ ]]; then
  echo "Could not find a unique tested iamf-tools revision in Media3's decoder_iamf/README.md" >&2
  exit 1
fi
echo "Using Media3's tested iamf-tools revision: ${IAMF_REVISION}"
cd "${IAMF_MODULE_PATH}/jni"
git clone --depth=1 --revision="${IAMF_REVISION}" https://github.com/AOMediaCodec/iamf-tools.git iamf_tools

cd "${IAMF_MODULE_PATH}/jni"
./build_iamf_tools.sh "${IAMF_MODULE_PATH}" "${NDK_PATH}"

## Enable publishing

echo '
apply(plugin = "media3.publish")
'>>"${GD_PATH}"
