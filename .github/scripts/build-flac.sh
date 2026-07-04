#!/bin/bash

echo "Build Flac"

FLAC_MODULE_PATH="${MEDIA3_PATH}/libraries/decoder_flac/src/main"
GD_PATH="${MEDIA3_PATH}/libraries/decoder_flac/build.gradle.kts"


## Fetch libflac

cd "${FLAC_MODULE_PATH}/jni"

git clone --depth=1  https://github.com/xiph/flac.git libflac



## Enable publishing

echo "
android {
    namespace = \"androidx.media3.decoder.flac\"

    publishing {
        singleVariant(\"release\") {
            withSourcesJar()
        }
    }
}
extra[\"releaseArtifactId\"] = \"media3-decode-flac\"
extra[\"releaseName\"] = \"Media3 flac module\"
apply(from = \"../../publish.gradle.kts\")
">>"${GD_PATH}"