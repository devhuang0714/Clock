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

build_uniform_tick_overlay() {
  local svg="$WORK_DIR/tmp/uniform_ticks.svg"
  awk -v c="$CENTER" 'BEGIN {
    pi = atan2(0, -1)
    print "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"1254\" height=\"1254\" viewBox=\"0 0 1254 1254\">"
    print "  <defs>"
    print "    <filter id=\"cyanGlow\" x=\"-40%\" y=\"-40%\" width=\"180%\" height=\"180%\">"
    print "      <feGaussianBlur stdDeviation=\"3\" result=\"blur\"/>"
    print "      <feMerge><feMergeNode in=\"blur\"/><feMergeNode in=\"SourceGraphic\"/></feMerge>"
    print "    </filter>"
    print "  </defs>"
    print "  <path d=\"M 627 627 m -536 0 a 536 536 0 1 0 1072 0 a 536 536 0 1 0 -1072 0 M 627 627 m -433 0 a 433 433 0 1 1 866 0 a 433 433 0 1 1 -866 0\" fill=\"#04111a\" fill-opacity=\"0.96\" fill-rule=\"evenodd\"/>"
    print "  <circle cx=\"627\" cy=\"627\" r=\"523\" fill=\"none\" stroke=\"#1bd8ff\" stroke-width=\"3\" stroke-opacity=\"0.75\" filter=\"url(#cyanGlow)\"/>"
    print "  <circle cx=\"627\" cy=\"627\" r=\"438\" fill=\"none\" stroke=\"#00c8df\" stroke-width=\"1.4\" stroke-opacity=\"0.45\"/>"
    print "  <circle cx=\"627\" cy=\"627\" r=\"462\" fill=\"none\" stroke=\"#0a5f77\" stroke-width=\"1\" stroke-opacity=\"0.65\"/>"

    for (i = 0; i < 60; i++) {
      a = i * 2 * pi / 60 - pi / 2
      if (i % 5 == 0) {
        r1 = 474; r2 = 514; swGlow = 10; sw = 6; color = "#79f4ff"
      } else {
        r1 = 486; r2 = 510; swGlow = 5; sw = 2.6; color = "#20d9ff"
      }
      x1 = c + cos(a) * r1; y1 = c + sin(a) * r1
      x2 = c + cos(a) * r2; y2 = c + sin(a) * r2
      printf "  <line x1=\"%.3f\" y1=\"%.3f\" x2=\"%.3f\" y2=\"%.3f\" stroke=\"#0bbfff\" stroke-width=\"%.1f\" stroke-opacity=\"0.26\" stroke-linecap=\"round\" filter=\"url(#cyanGlow)\"/>\n", x1, y1, x2, y2, swGlow
      printf "  <line x1=\"%.3f\" y1=\"%.3f\" x2=\"%.3f\" y2=\"%.3f\" stroke=\"%s\" stroke-width=\"%.1f\" stroke-opacity=\"0.96\" stroke-linecap=\"round\"/>\n", x1, y1, x2, y2, color, sw
    }

    for (i = 0; i < 60; i += 5) {
      a = i * 2 * pi / 60 - pi / 2
      label = (i == 0) ? "60" : sprintf("%02d", i)
      r = 545
      x = c + cos(a) * r
      y = c + sin(a) * r + 7
      printf "  <text x=\"%.3f\" y=\"%.3f\" text-anchor=\"middle\" font-family=\"Arial, Helvetica, sans-serif\" font-size=\"25\" font-weight=\"500\" fill=\"#52e7ff\" fill-opacity=\"0.88\">%s</text>\n", x, y, label
    }

    print "</svg>"
  }' > "$svg"
  magick "$svg" "$WORK_DIR/tmp/uniform_ticks.png"
}

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
  "$WORK_DIR/tmp/clock_face_base.png"

build_uniform_tick_overlay

magick "$WORK_DIR/tmp/clock_face_base.png" \
  "$WORK_DIR/tmp/uniform_ticks.png" -composite \
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
