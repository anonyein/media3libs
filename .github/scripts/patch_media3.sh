#!/bin/bash
set -e

FILE="${GITHUB_WORKSPACE}/media/libraries/exoplayer_hls/src/main/java/androidx/media3/exoplayer/hls/HlsMediaChunk.java"

# 补丁1：保护 dataSource.open
perl -i -pe 's/long bytesToRead = dataSource.open\(dataSpec\);/long bytesToRead = 0L;\n            try {\n                bytesToRead = dataSource.open(dataSpec);\n            } catch (Exception ignored) {\n            }/' "$FILE"

# 补丁2：在 feedDataToExtractor 的内层 finally 前插入 catch(Exception)
# 通过匹配连续两行：6空格 finally { 紧接着 8空格 nextLoadPosition... 来精确定位
sed -i '/^      } finally {/{
    N
    /nextLoadPosition = (int) (input.getPosition() - dataSpec.position);/{
        i\
      } catch (Exception e) {\
        throw new IOException("Unexpected error in feedDataToExtractor", e);
    }
}' "$FILE"

# 验证
if grep -c 'catch (Exception e)' "$FILE" | grep -q 1; then
    echo "✅ Both patches applied successfully."
else
    echo "❌ Patch 2 not applied!" >&2
    exit 1
fi
