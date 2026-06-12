---
name: clock-ui
description: Use when modifying this Clock HarmonyOS app's clock faces, poster clocks, digital time displays, widget clocks, or ArkUI layouts that render HH:mm or HH:mm:ss time text.
---

# Clock UI Rules

## Hard Time Display Rule

Any visible clock time rendered as `HH:mm` or `HH:mm:ss` must stay on one line.

- Do not change an existing clock face's overall layout, orientation, alignment, spacing, or visual hierarchy just to satisfy this rule.
- Do set `maxLines(1)` on `Text` or `TextClock` time displays when the API supports it.
- If the time may not fit, first shrink the visible time text with `minFontSize` / `maxFontSize` or reserve stable width for the time text.
- For card-based clocks, preserve the existing card arrangement; only constrain the text inside each card unless the user explicitly asks to redesign the layout.
- Keeping seconds visually smaller is allowed, but the full minute value must remain visible.
- For split time such as `HH:mm` plus small `:ss`, reserve stable width for the `HH:mm` part and never let it be compressed until minutes disappear.

## Verification And Device Install

After changing clock UI, build the debug HAP and install it to the connected phone with `hdc` directly. Do not use `./run-harmony.sh` for this workflow.

```bash
/Applications/DevEco-Studio.app/Contents/tools/node/bin/node /Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw.js assembleHap --mode module -p module=entry@default -p product=debug -p buildMode=debug --no-daemon

/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc list targets
/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc shell mkdir -p /data/local/tmp/clock_install
/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc file send entry/build/debug/outputs/default/entry-default-signed.hap /data/local/tmp/clock_install/entry-default-signed.hap
/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc shell bm install -p /data/local/tmp/clock_install/entry-default-signed.hap -r
/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc shell rm -rf /data/local/tmp/clock_install
/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc shell aa start -a EntryAbility -b com.hyx.clock
```

If multiple devices are connected, pass `-t <connectKey>` immediately after the `hdc` binary for all `hdc` commands.
