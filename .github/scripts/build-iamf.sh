#!/bin/bash

echo "Build IAMF"

IAMF_MODULE_PATH="${MEDIA3_PATH}/libraries/decoder_iamf/src/main"
GD_PATH="${MEDIA3_PATH}/libraries/decoder_iamf/build.gradle"

## Fetch libiamf
cd "${IAMF_MODULE_PATH}/jni"
git clone https://github.com/AOMediaCodec/iamf-tools.git iamf_tools 
cd iamf_tools 
git reset --hard de364b983

cd "${IAMF_MODULE_PATH}/jni"
./build_iamf_tools.sh ${IAMF_MODULE_PATH}




## Enable publishing

echo "
android {
    namespace 'androidx.media3.decoder.iamf'

    publishing {
        singleVariant('release') {
            withSourcesJar()
        }
    }
}
ext {
     releaseArtifactId = 'media3-decode-iamf'
     releaseName = 'Media3 iamf module'
     }
     apply from: '../../publish.gradle'
">>"${GD_PATH}"
