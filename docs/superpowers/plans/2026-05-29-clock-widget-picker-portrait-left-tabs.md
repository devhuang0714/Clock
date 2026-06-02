# Clock Widget Picker Portrait Left Tabs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the desktop widget picker size Tabs to a left-side vertical rail in portrait while keeping landscape's top horizontal Tabs.

**Architecture:** Keep all changes in `ClockWidgetsPage.ets`. Split the shared list rendering into a builder so portrait can compose `Row { LeftSizeTabs(); WidgetList() }` while landscape keeps `SizeTabs(); WidgetList()`. Keep selection behavior and neutral non-blue Tab styling shared.

**Tech Stack:** HarmonyOS ArkTS / ArkUI ETS components, existing `ClockWidgetConfig`, existing `ClockWidgetView`, existing `isLandscape` storage prop.

---

## File Structure

- Modify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets`
  - Add `WidgetList()` builder for the grouped list.
  - Add `LeftSizeTabs()` builder for portrait.
  - Keep `SizeTabs()` as the horizontal landscape control.
  - Add `SizeTabButton(widgetSize: ClockWidgetSize)` builder for shared Tab styling and click behavior.

No new source files are needed.

---

### Task 1: Split the Body Layout by Orientation

**Files:**
- Modify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets:122-133`

- [ ] **Step 1: Replace direct top Tab + List with orientation-aware body**

Replace this block in `build()`:

```ts
this.SizeTabs()

List({ space: this.isLandscape ? 18 : 26 }) {
  ForEach(this.getVisibleGroups(), (group: ClockWidgetGroup) => {
    ListItem() {
      this.WidgetGroupSection(group)
    }
  }, (group: ClockWidgetGroup) => group.title)
}
.scrollBar(BarState.Off)
.layoutWeight(1)
.margin({ top: this.isLandscape ? 12 : 18 })
```

With:

```ts
if (this.isLandscape) {
  this.SizeTabs()
  this.WidgetList()
} else {
  Row({ space: 14 }) {
    this.LeftSizeTabs()
    this.WidgetList()
  }
  .width('100%')
  .layoutWeight(1)
}
```

---

### Task 2: Extract Shared List Builder

**Files:**
- Modify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets`

- [ ] **Step 1: Add `WidgetList()` builder before `SizeTabs()`**

Insert this builder before `SizeTabs()`:

```ts
@Builder
WidgetList() {
  List({ space: this.isLandscape ? 18 : 26 }) {
    ForEach(this.getVisibleGroups(), (group: ClockWidgetGroup) => {
      ListItem() {
        this.WidgetGroupSection(group)
      }
    }, (group: ClockWidgetGroup) => group.title)
  }
  .scrollBar(BarState.Off)
  .layoutWeight(1)
  .margin({ top: this.isLandscape ? 12 : 0 })
}
```

Portrait margin becomes `0` because the left rail and list begin under the header together.

---

### Task 3: Share Tab Button Styling

**Files:**
- Modify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets:145-180`

- [ ] **Step 1: Add shared Tab button builder**

Insert this builder before `SizeTabs()` or after `WidgetList()`:

```ts
@Builder
SizeTabButton(widgetSize: ClockWidgetSize) {
  Button(getClockWidgetSizeLabel(widgetSize))
    .type(ButtonType.Normal)
    .fontSize(15)
    .fontWeight(this.selectedSize == widgetSize ? FontWeight.Bold : FontWeight.Medium)
    .fontColor($r('app.color.flip_text_color'))
    .backgroundColor(this.selectedSize == widgetSize ? $r('app.color.main_background_color') : Color.Transparent)
    .borderRadius(14)
    .padding({ top: this.isLandscape ? 8 : 10, bottom: this.isLandscape ? 8 : 10 })
    .shadow(this.selectedSize == widgetSize ? {
      radius: 8,
      color: '#18000000',
      offsetY: 2
    } : {
      radius: 0,
      color: Color.Transparent,
      offsetY: 0
    })
    .onClick(() => {
      this.selectedSize = widgetSize
      const selectedConfig = CLOCK_WIDGET_CONFIGS.find((item: ClockWidgetConfig) => item.id == this.selectedWidgetId)
      if (selectedConfig == undefined || !isClockWidgetSizeSupported(selectedConfig, widgetSize)) {
        this.selectedWidgetId = this.getCurrentItems()[0].id
      }
    })
}
```

- [ ] **Step 2: Simplify horizontal `SizeTabs()`**

Replace the contents of `SizeTabs()` with:

```ts
@Builder
SizeTabs() {
  Row({ space: 6 }) {
    ForEach(CLOCK_WIDGET_SIZES, (widgetSize: ClockWidgetSize) => {
      this.SizeTabButton(widgetSize)
        .layoutWeight(1)
    }, (widgetSize: ClockWidgetSize) => getClockWidgetSizeLabel(widgetSize))
  }
  .width('100%')
  .padding(4)
  .borderRadius(18)
  .backgroundColor($r('app.color.flip_card_bg_color'))
}
```

Expected: Tab selected state remains neutral and no blue color is used.

---

### Task 4: Add Portrait Left Tab Rail

**Files:**
- Modify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets`

- [ ] **Step 1: Add `LeftSizeTabs()` builder after `SizeTabs()`**

Insert:

```ts
@Builder
LeftSizeTabs() {
  Column({ space: 6 }) {
    ForEach(CLOCK_WIDGET_SIZES, (widgetSize: ClockWidgetSize) => {
      this.SizeTabButton(widgetSize)
        .width('100%')
    }, (widgetSize: ClockWidgetSize) => getClockWidgetSizeLabel(widgetSize))
  }
  .width(68)
  .padding(4)
  .borderRadius(18)
  .backgroundColor($r('app.color.flip_card_bg_color'))
}
```

This keeps the portrait rail compact enough for the widget list to retain useful width.

---

### Task 5: Verify

**Files:**
- Verify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets`

- [ ] **Step 1: Confirm left tab and shared button symbols exist**

Run:

```bash
grep -n "LeftSizeTabs\|SizeTabButton\|WidgetList" entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets
```

Expected: matches for all three builders and their call sites.

- [ ] **Step 2: Confirm blue selected state is still absent**

Run:

```bash
grep -n "app.color.blue" entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets
```

Expected: no output.

- [ ] **Step 3: Build without installing or launching**

Run:

```bash
./run-harmony.sh --skip-install --skip-start
```

Expected: `BUILD SUCCESSFUL`.

- [ ] **Step 4: Manual UI verification if device/preview is available**

Open Settings → 桌面小组件 and verify:

```text
Portrait: size Tabs appear as a left vertical rail; widget groups render to the right; selected Tab uses neutral style.
Landscape: size Tabs remain horizontal at the top; compact multi-column layout remains unchanged.
```

If no local device/preview is available, report that manual UI verification was not completed locally.

---

## Self-Review

- Spec coverage: The plan covers portrait left-side Tabs, landscape preservation, shared neutral Tab styling, and selection fallback preservation.
- Placeholder scan: No TBD/TODO/implement-later placeholders remain.
- Type consistency: `WidgetList`, `SizeTabButton`, and `LeftSizeTabs` are defined before use and use existing `ClockWidgetSize` types.
