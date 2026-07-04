#!/bin/bash

echo "Build Opus"

OPUS_MODULE_PATH="${MEDIA3_PATH}/libraries/decoder_opus/src/main"
GD_PATH="${MEDIA3_PATH}/libraries/decoder_opus/build.gradle.kts"


#Fetch libopus:

cd "${OPUS_MODULE_PATH}/jni" 
git clone --depth=1 https://gitlab.xiph.org/xiph/opus.git libopus

## Enable publishing
echo '
apply(plugin = "media3.publish")
'>>"${GD_PATH}"