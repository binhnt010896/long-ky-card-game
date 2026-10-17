#!/bin/zsh
# Imports the painted art the game uses from the owner's viet-su project,
# resized for the game (the originals are 2048 px PNGs of 5 to 8 MB).
#
#   tools/art/import_viet_su.sh [/path/to/viet-su]
#
# Content art (named by apps/game/assets/content/*.json):
#   officers/<id>/portrait.jpg  1:1, 512 px     (viet-su <id>-avatar.png)
#   officers/<id>/card.jpg      2:3, 800 px tall edge 1194 (viet-su <id>-full.png)
# UI art (named in the Flutter code): apps/game/assets/images/ui/
# Needs macOS `sips`.
set -euo pipefail
SRC="${1:-$HOME/Projects/viet-su}"
DST="$(cd "$(dirname "$0")/../.." && pwd)/apps/game/assets/images"
ERAS="$SRC/content/eras"

jpg()    { sips -s format jpeg -s formatOptions 82 -Z "$3" "$1" --out "$2" >/dev/null; }
square() { jpg "$1" "$2" 512; }
tall()   { jpg "$1" "$2" 1194; }

person() { # <game id> <viet-su id> <era folder> <officers|enemies>
  mkdir -p "$DST/$4/$1"
  square "$ERAS/$3/characters/$2-avatar.png" "$DST/$4/$1/portrait.jpg"
  tall   "$ERAS/$3/characters/$2-full.png"   "$DST/$4/$1/card.jpg"
}

person tran-thai-tong       tran-thai-tong       tran-thai-tong officers
person tran-thu-do          tran-thu-do          tran-thai-tong officers
person le-phu-tran          le-phu-tran          tran-thai-tong officers
person tran-nhat-hieu       tran-nhat-hieu       tran-thai-tong officers
person tran-quoc-tuan       tran-hung-dao        tran-hung-dao  officers
person tran-khanh-du        tran-khanh-du        tran-hung-dao  officers
person ngot-luong-hop-thai  ngot-luong-hop-thai  tran-thai-tong enemies

mkdir -p "$DST/ui" "$DST/missions"
jpg "$ERAS/tran-thai-tong/cover.png"                         "$DST/ui/title-cover.jpg"      1800
jpg "$SRC/brand/splash/splash-dragon.png"                    "$DST/ui/dragon-splash.jpg"    1600
sips -s format png -Z 512 "$SRC/brand/logo/longky-01-circle-oxblood.png" --out "$DST/ui/logo.png" >/dev/null
# Existing event paintings used as mission backdrops.
jpg "$ERAS/tran-thai-tong/events/khang-chien-mong-co-lan-mot.png" "$DST/missions/ch1_m2.jpg" 1600
jpg "$ERAS/tran-thai-tong/events/tran-thu-do-dung-nen.png"        "$DST/missions/ch1_m4.jpg" 1600
echo "Imported into $DST"
