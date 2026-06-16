#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
WORK_DIR="$ROOT_DIR/generated/clock_assets_work"
OUT_DIR="$ROOT_DIR/generated/clock_assets_ready_to_stack"
PREVIEW_DIR="$OUT_DIR/preview"
MEDIA_DIR="$ROOT_DIR/entry/src/main/resources/base/media"

FACE_SRC="$WORK_DIR/source/image2_clock_face_source.png"
HANDS_SRC="$WORK_DIR/source/image2_hands_source.png"

mkdir -p "$OUT_DIR" "$PREVIEW_DIR" "$WORK_DIR/tmp" "$MEDIA_DIR"

SIZE=1254
CENTER=627
FACE_SHIFT_Y=3

make_hand_layer() {
  local crop="$1"
  local pivot_x="$2"
  local pivot_y="$3"
  local forward_len="$4"
  local out_name="$5"
  local tmp_crop="$WORK_DIR/tmp/${out_name%.png}_crop.png"
  local tmp_scaled="$WORK_DIR/tmp/${out_name%.png}_scaled.png"
  local crop_height
  crop_height="$(printf '%s' "$crop" | sed -E 's/^[0-9]+x([0-9]+).*/\1/')"
  local total_height
  total_height="$(awk -v h="$crop_height" -v len="$forward_len" -v pivot="$pivot_y" 'BEGIN { printf "%d", (h * len / pivot) + 0.5 }')"

  magick "$HANDS_SRC" \
    -crop "$crop" +repage \
    -alpha set -fuzz 20% -transparent '#00ff00' \
    -channel A -fx "u.g>0.25 && (u.g-(u.r>u.b?u.r:u.b))>0.08 ? 0 : u.a" +channel \
    -background black -alpha background \
    -background none -alpha on \
    "$tmp_crop"

  magick "$tmp_crop" \
    -filter Lanczos -resize "x${total_height}" \
    -background none -alpha on \
    "$tmp_scaled"

  local scaled_width
  scaled_width="$(magick identify -format '%w' "$tmp_scaled")"
  local x
  local y
  x="$(awk -v c="$CENTER" -v px="$pivot_x" -v total="$total_height" -v h="$crop_height" 'BEGIN { printf "%d", c - (px * total / h) + 0.5 }')"
  y="$(awk -v c="$CENTER" -v len="$forward_len" 'BEGIN { printf "%d", c - len }')"

  magick -size "${SIZE}x${SIZE}" xc:none \
    "$tmp_scaled" -geometry "+${x}+${y}" -composite \
    "$OUT_DIR/$out_name"
}

magick "$FACE_SRC" \
  -alpha set -fuzz 20% -transparent '#00ff00' \
  -channel A -fx "u.g>0.25 && (u.g-(u.r>u.b?u.r:u.b))>0.08 ? 0 : u.a" +channel \
  -background black -alpha background \
  -background none -alpha on \
  "$WORK_DIR/tmp/clock_face_keyed.png"

magick -size "${SIZE}x${SIZE}" xc:none \
  "$WORK_DIR/tmp/clock_face_keyed.png" -geometry "+0+${FACE_SHIFT_Y}" -composite \
  "$OUT_DIR/clock_face.png"

make_hand_layer '129x687+227+373' 64.5 543 365 hour_hand.png
make_hand_layer '127x912+464+148' 63.5 770 462 minute_hand.png
make_hand_layer '93x1064+703+71' 46.5 857 500 second_hand.png

magick "$HANDS_SRC" \
  -crop '173x181+903+857' +repage \
  -alpha set -fuzz 20% -transparent '#00ff00' \
  -channel A -fx "u.g>0.25 && (u.g-(u.r>u.b?u.r:u.b))>0.08 ? 0 : u.a" +channel \
  -background black -alpha background \
  -background none -alpha on \
  -filter Lanczos -resize 190x190 \
  "$WORK_DIR/tmp/center_cap_scaled.png"

magick -size "${SIZE}x${SIZE}" xc:none \
  "$WORK_DIR/tmp/center_cap_scaled.png" -geometry +532+532 -composite \
  "$OUT_DIR/center_cap.png"

magick "$OUT_DIR/hour_hand.png" -background none -virtual-pixel transparent \
  -set option:distort:viewport "${SIZE}x${SIZE}+0+0" -distort SRT 305 \
  "$WORK_DIR/tmp/hour_preview.png"
magick "$OUT_DIR/minute_hand.png" -background none -virtual-pixel transparent \
  -set option:distort:viewport "${SIZE}x${SIZE}+0+0" -distort SRT 50 \
  "$WORK_DIR/tmp/minute_preview.png"
magick "$OUT_DIR/second_hand.png" -background none -virtual-pixel transparent \
  -set option:distort:viewport "${SIZE}x${SIZE}+0+0" -distort SRT 210 \
  "$WORK_DIR/tmp/second_preview.png"

magick -size "${SIZE}x${SIZE}" xc:'#05080d' \
  "$OUT_DIR/clock_face.png" -composite \
  "$WORK_DIR/tmp/hour_preview.png" -composite \
  "$WORK_DIR/tmp/minute_preview.png" -composite \
  "$WORK_DIR/tmp/second_preview.png" -composite \
  "$OUT_DIR/center_cap.png" -composite \
  "$PREVIEW_DIR/overlay_preview.png"

cp "$OUT_DIR/clock_face.png" "$MEDIA_DIR/round_neon_clock_face.png"
cp "$OUT_DIR/hour_hand.png" "$MEDIA_DIR/round_neon_hour_hand.png"
cp "$OUT_DIR/minute_hand.png" "$MEDIA_DIR/round_neon_minute_hand.png"
cp "$OUT_DIR/second_hand.png" "$MEDIA_DIR/round_neon_second_hand.png"
cp "$OUT_DIR/center_cap.png" "$MEDIA_DIR/round_neon_center_cap.png"

cd "$ROOT_DIR/generated"
zip -qr clock_assets_ready_to_stack.zip clock_assets_ready_to_stack
