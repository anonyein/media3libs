#!/bin/bash

echo "Build Opus"

OPUS_MODULE_PATH="${MEDIA3_PATH}/libraries/decoder_opus/src/main"
GD_PATH="${MEDIA3_PATH}/libraries/decoder_opus/build.gradle.kts"


#Fetch libopus:

cd "${OPUS_MODULE_PATH}/jni" 

# Pin to the latest stable release. Unpinned master now includes
# celt/arm/celt_tx_neon.S, which references the global celt_tx_tab_* tables
# via ADRP; those symbols are preemptible in a shared-library link, so
# lld fails with "relocation R_AARCH64_ADR_PREL_PG_HI21 ... recompile with
# -fPIC" when linking libopusV2JNI.so (arm64-v8a).
git clone --depth=1 -b v1.6.1 https://gitlab.xiph.org/xiph/opus.git libopus

## Enable publishing
echo '
apply(plugin = "media3.publish")
'>>"${GD_PATH}"