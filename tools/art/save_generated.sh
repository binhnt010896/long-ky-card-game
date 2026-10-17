#!/bin/zsh
# Downloads a generated image and saves it, resized, as a JPEG under
# apps/game/assets/images/.
#
#   tools/art/save_generated.sh <url> <path under assets/images, .jpg> <long edge px>
set -euo pipefail
URL="$1"; REL="$2"; EDGE="${3:-1600}"
DST="$(cd "$(dirname "$0")/../.." && pwd)/apps/game/assets/images/$REL"
TMP="$(mktemp -t lkart).png"
mkdir -p "$(dirname "$DST")"
curl -fsS -o "$TMP" "$URL"
sips -s format jpeg -s formatOptions 82 -Z "$EDGE" "$TMP" --out "$DST" >/dev/null
rm -f "$TMP"
echo "$DST $(du -h "$DST" | cut -f1)"
