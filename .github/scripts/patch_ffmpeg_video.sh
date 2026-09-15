#!/bin/bash
# Apply rabbitknight/media PR 1591 (ExperimentalFfmpegVideoRenderer + Hi10P
# software decoding) onto the androidx/media 1.11.1 checkout.
#
# Scope: libraries/decoder_ffmpeg (video decoder/renderer/JNI/libyuv build) +
# libraries/common (VIDEO_PRORES constant required by FfmpegLibrary.getCodecName).
# The container/extractor ProRes MP4 parsing hunks are intentionally skipped —
# H.264 Hi10P HLS playback does not need them.
set -e

MEDIA_ROOT="${GITHUB_WORKSPACE}/media"
PATCH="${GITHUB_WORKSPACE}/.github/scripts/pr1591.patch"

cd "$MEDIA_ROOT"

git apply --include='libraries/decoder_ffmpeg/*' --include='libraries/common/*' "$PATCH"

# Verify the patch landed.
grep -q "ffmpegVideoInitialize" libraries/decoder_ffmpeg/src/main/jni/ffmpeg_jni.cc
grep -q "ffmpegGetAv1DecoderName" libraries/decoder_ffmpeg/src/main/java/androidx/media3/decoder/ffmpeg/FfmpegLibrary.java
test -f libraries/decoder_ffmpeg/src/main/java/androidx/media3/decoder/ffmpeg/ExperimentalFfmpegVideoDecoder.java
test -f libraries/decoder_ffmpeg/src/main/jni/build_yuv.sh
grep -q "libyuv" libraries/decoder_ffmpeg/src/main/jni/CMakeLists.txt
grep -q "VIDEO_PRORES" libraries/common/src/main/java/androidx/media3/common/MimeTypes.java

# 16 KB ELF alignment for the other extension JNI libs (Android 15+ 16KB-page
# devices). Upstream 1.11.1 CMakeLists lack it; all JNI .so are SHARED targets
# inside each module's CMake project, so the shared linker flag covers them.
for module in decoder_av1 decoder_flac decoder_opus decoder_vp9 decoder_iamf; do
  cmake_file="libraries/${module}/src/main/jni/CMakeLists.txt"
  if [ -f "$cmake_file" ] && ! grep -q "max-page-size" "$cmake_file"; then
    printf '\n# 16 KB ELF alignment for Android 15+ 16KB-page devices.\nset(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-z,max-page-size=16384")\n' >> "$cmake_file"
  fi
done

echo "PR 1591 (FfmpegVideoRenderer + Hi10P) patched onto media 1.11.1."
