#!/bin/bash
# Clone and build libyuv for all 4 ABIs. Required by the FFmpeg video renderer
# (YUV420P / YUV420P10 -> I420 conversion + ANativeWindow rendering).
set -e

JNI_DIR="${MEDIA3_PATH}/libraries/decoder_ffmpeg/src/main/jni"
FFMPEG_MODULE_PATH="${MEDIA3_PATH}/libraries/decoder_ffmpeg/src/main"

echo "Clone libyuv"
cd "$JNI_DIR"
rm -rf libyuv
git clone --depth=1 https://chromium.googlesource.com/libyuv/libyuv

echo "Build libyuv"
cd "$JNI_DIR"
chmod +x build_yuv.sh
./build_yuv.sh "$FFMPEG_MODULE_PATH" "$NDK_PATH" 21

# Verify
test -f "$JNI_DIR/libyuv/android-libs/arm64-v8a/libyuv.so"
test -f "$JNI_DIR/libyuv/android-libs/armeabi-v7a/libyuv.so"
echo "libyuv built for 4 ABIs."
