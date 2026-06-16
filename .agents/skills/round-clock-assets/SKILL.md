---
name: round-clock-assets
description: Use when adding, replacing, copying, or tuning this Clock HarmonyOS app's round_clock_styleN image-stack clock faces from a design/reference image. Covers Image2-style asset generation, transparent PNG post-processing, stackable clock_face/hour_hand/minute_hand/second_hand/center_cap outputs, ArkUI RoundClock wiring, smooth second-hand refresh, zip/preview deliverables, build, and device install.
---

# Round Clock Asset Workflow

Use this skill when the user provides a round clock design image and asks to add, replace, copy, or tune a `round_clock_styleN` face.

Also use `clock-ui` for final build/install verification.

## Core Rules

- Do not directly crop clock components from the user's reference image.
- Use the reference image only as visual guidance for Image2/image generation.
- Generate source images on a flat `#00ff00` chroma-key background, then remove that background locally.
- Final runtime assets are five independent transparent PNG layers:
  - `clock_face.png`
  - `hour_hand.png`
  - `minute_hand.png`
  - `second_hand.png`
  - `center_cap.png`
- All final PNGs must be exactly `1254x1254`, with alpha channel, transparent corners, and a shared center point at `(627, 627)`.
- The app should reference files in `entry/src/main/resources/base/media/`; generated work directories are only source/deliverable records.
- For image-stack round clocks, use continuous second-hand rotation by updating every `20ms`, matching Style2/Style3/Mechanical behavior.

## Directory Pattern

For a new or replaced style, create a reproducible work area:

```text
generated/clock_assets_styleN_work/
  source/
    image2_styleN_face.png
    image2_styleN_hands.png
  build_styleN_clock_assets.sh
  tmp/

generated/clock_assets_styleN_ready_to_stack/
  clock_face.png
  hour_hand.png
  minute_hand.png
  second_hand.png
  center_cap.png
  preview/
    overlay_preview.png

generated/clock_assets_styleN_ready_to_stack.zip
```

If replacing an already generated style while preserving the prior version, use a distinct work directory such as `clock_assets_style4_new_work`, and copy the old runtime `round_style4_*` files to the new style name before overwriting them.

## Image Generation

Use the built-in `image_gen` tool by default.

Generate two source images per style:

1. Face source:
   - square `1254x1254`
   - flat solid `#00ff00` background
   - only the clock face
   - no hands
   - no center cap
   - centered, front-facing, circular, symmetric
   - clear outer ring, 60 minute ticks, 12 hour markers/numerals

2. Hands/cap source sheet:
   - square `1254x1254`
   - flat solid `#00ff00` background
   - separated hour hand, minute hand, second hand, center cap
   - all hands point straight upward
   - no overlaps
   - no clock face
   - no holes in hands or cap

Prompt essentials:

```text
Use the user's attached image as visual style reference only; do not copy or crop it.
Create a square source image for app UI asset production.
Background: perfectly flat solid #00ff00 chroma-key background for later removal.
The background must be uniform: no shadows, gradients, texture, reflections, floor plane, or lighting variation.
Do not use #00ff00 anywhere in the subject.
No watermark, no grey/white checkerboard, no rectangular panel.
```

## Post-Processing Script Pattern

Base new scripts on existing generated scripts, especially:

- `generated/clock_assets_style3_work/build_cyber_clock_assets.sh`
- `generated/clock_assets_style4_work/build_style4_clock_assets.sh`
- `generated/clock_assets_style5_work/build_style5_clock_assets.sh`

Use ImageMagick. Pillow may not be available.

The script should:

1. Remove green background with a reusable helper:

```bash
key_to_alpha() {
  local input="$1"
  local output="$2"
  magick "$input" \
    -alpha set -fuzz 20% -transparent '#00ff00' \
    -channel A -fx "u.g>0.25 && (u.g-(u.r>u.b?u.r:u.b))>0.08 ? 0 : u.a" +channel \
    -background black -alpha background \
    -background none -alpha on \
    "$output"
}
```

2. Analyze hand source sheet component bounds before writing crop boxes:

```bash
magick generated/clock_assets_styleN_work/source/image2_styleN_hands.png \
  -alpha set -fuzz 20% -transparent '#00ff00' \
  -channel A -fx "u.g>0.25 && (u.g-(u.r>u.b?u.r:u.b))>0.08 ? 0 : u.a" +channel \
  -alpha extract -threshold 1% \
  -define connected-components:verbose=true \
  -connected-components 8 null:
```

3. Build each hand as a full `1254x1254` transparent canvas with pivot at center:

```bash
make_hand_layer '<crop>' <pivot_x> <pivot_y> <forward_len> hour_hand.png
make_hand_layer '<crop>' <pivot_x> <pivot_y> <forward_len> minute_hand.png
make_hand_layer '<crop>' <pivot_x> <pivot_y> <forward_len> second_hand.png
```

`pivot_y` is the source crop coordinate of the hand pivot/root. `forward_len` is the center-to-tip distance in the final canvas.

Recommended starting lengths:

- hour hand: `330` to `380`
- minute hand: `430` to `475`
- second hand: `465` to `515`

If the user says the hands are too long, reduce `forward_len`; do not move the canvas center.

4. Composite a preview:

```bash
magick -size 1254x1254 xc:'<background>' \
  "$OUT_DIR/clock_face.png" -composite \
  "$WORK_DIR/tmp/hour_preview.png" -composite \
  "$WORK_DIR/tmp/minute_preview.png" -composite \
  "$WORK_DIR/tmp/second_preview.png" -composite \
  "$OUT_DIR/center_cap.png" -composite \
  "$PREVIEW_DIR/overlay_preview.png"
```

5. Copy runtime files into `entry/src/main/resources/base/media/`:

```bash
cp "$OUT_DIR/clock_face.png" "$MEDIA_DIR/round_styleN_clock_face.png"
cp "$OUT_DIR/hour_hand.png" "$MEDIA_DIR/round_styleN_hour_hand.png"
cp "$OUT_DIR/minute_hand.png" "$MEDIA_DIR/round_styleN_minute_hand.png"
cp "$OUT_DIR/second_hand.png" "$MEDIA_DIR/round_styleN_second_hand.png"
cp "$OUT_DIR/center_cap.png" "$MEDIA_DIR/round_styleN_center_cap.png"
```

6. Zip the deliverable:

```bash
cd "$ROOT_DIR/generated"
zip -qr clock_assets_styleN_ready_to_stack.zip clock_assets_styleN_ready_to_stack
```

## ArkUI Integration

Update these files when adding or replacing a round image-stack style:

- `entry/src/main/ets/views/Clocks/RoundClock.ets`
- `entry/src/main/ets/pages/Index.ets`
- `entry/src/main/ets/views/Clocks/ClockConfig.ets`
- `entry/src/main/ets/pages/Settings/ClockThemesPage.ets` when adding a new selectable style

In `RoundClock.ets`:

- Include the style in `isImageStackStyle()`.
- Add a `Stack` branch with:
  - face image
  - hour hand image rotated by `hourAngle`
  - minute hand image rotated by `minuteAngle`
  - second hand image rotated by `secondAngle`
  - center cap image on top
- Use `.width('100%').height('100%').objectFit(ImageFit.Contain)` for every image.
- Keep `.width(this.canvasWidth).height(this.canvasWidth)` on the inner stack.

In `Index.ets`, include the style in the round-clock `20ms` refresh condition.

When copying an existing style to a new one:

- Copy all five `round_styleX_*` runtime PNGs to `round_styleY_*`.
- Add a new `CLOCK_CONFIGS` entry if it should appear as a selectable style.
- Add the new id to the `圆形指针` group in `ClockThemesPage.ets`.

## Validation Checklist

Before final response, verify:

- All five output files exist in the generated ready directory.
- All five runtime files exist in `entry/src/main/resources/base/media/`.
- Every PNG is `1254x1254`, `srgba`, and has transparent corner pixels:

```bash
identify -format '%f %wx%h %[channels] %[pixel:p{0,0}]\n' \
  generated/clock_assets_styleN_ready_to_stack/*.png \
  entry/src/main/resources/base/media/round_styleN_*.png
```

- `overlay_preview.png` visually shows correct stacking, centered cap, and reasonable hand lengths.
- The zip contains the five PNGs plus `preview/overlay_preview.png`.
- `rg` confirms ArkUI references match actual media file names.
- Run the debug build and install workflow from `clock-ui`.

If the device is locked, install can still succeed but `aa start` may fail; report that explicitly.
