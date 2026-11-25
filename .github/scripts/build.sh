#!/bin/bash
set -eux

echo $ANDROID_NDK_HOME
echo $NDK_PATH

chmod +x ${ROOT_DIR}/.github/scripts/build-ffmpeg.sh
chmod +x ${ROOT_DIR}/.github/scripts/build-libyuv.sh
chmod +x ${ROOT_DIR}/.github/scripts/patch_ffmpeg_video.sh
chmod +x ${ROOT_DIR}/.github/scripts/build-av1.sh
chmod +x ${ROOT_DIR}/.github/scripts/build-flac.sh
chmod +x ${ROOT_DIR}/.github/scripts/build-opus.sh
chmod +x ${ROOT_DIR}/.github/scripts/build-vp9.sh
chmod +x ${ROOT_DIR}/.github/scripts/build-iamf.sh

# Apply PR 1591 (FfmpegVideoRenderer + Hi10P) before building the extensions.
${ROOT_DIR}/.github/scripts/patch_ffmpeg_video.sh

cd media
export MEDIA3_PATH="$(pwd)"


${ROOT_DIR}/.github/scripts/build-libyuv.sh
${ROOT_DIR}/.github/scripts/build-ffmpeg.sh
${ROOT_DIR}/.github/scripts/build-av1.sh
${ROOT_DIR}/.github/scripts/build-flac.sh
${ROOT_DIR}/.github/scripts/build-opus.sh
${ROOT_DIR}/.github/scripts/build-vp9.sh
${ROOT_DIR}/.github/scripts/build-iamf.sh
cd ${MEDIA3_PATH}
(
  set -o pipefail
  gradle_log=$(mktemp)
  trap 'rm -f "$gradle_log"' EXIT

  for attempt in 1 2 3; do
    if ./gradlew --console=plain publishToMavenLocal 2>&1 | tee "$gradle_log"; then
      exit 0
    else
      status=$?
    fi

    if (( attempt == 3 )) || ! grep -qF 'Received status code 429' "$gradle_log"; then
      exit "$status"
    fi

    delay=$((30 * attempt))
    echo "Gradle dependency download was rate limited (HTTP 429); retrying in ${delay}s." >&2
    sleep "$delay"
  done
)



cd ${ROOT_DIR}
mkdir -p repo
mv ~/.m2/repository/* repo


git config --local user.email "github-action@users.noreply.github.com"
git config --local user.name "GitHub Action"
git add repo/**
git commit -m "build aar"
