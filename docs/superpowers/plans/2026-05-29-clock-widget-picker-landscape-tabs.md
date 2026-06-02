# Clock Widget Picker Landscape and Tabs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve the desktop widget picker in landscape by making previews compact and multi-column, removing the bottom collapse button, and replacing the blue selected Tab with a neutral segmented style.

**Architecture:** Keep all changes localized to `ClockWidgetsPage.ets`. Use the existing `isLandscape` storage prop to choose spacing, grid columns, preview widths, and page padding without changing widget data or `ClockWidgetView` rendering. Preserve portrait behavior except for the improved neutral Tab style and removed bottom button.

**Tech Stack:** HarmonyOS ArkTS / ArkUI ETS components, existing `ClockWidgetConfig`, existing `ClockWidgetView`, existing app color resources.

---

## File Structure

- Modify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets`
  - Remove bottom collapse button.
  - Add layout helper methods for landscape spacing and preview widths.
  - Update grouped sections to use adaptive Grid columns.
  - Update SizeTabs selected state to neutral colors with subtle elevation.

No new source files are needed.

---

### Task 1: Remove Bottom Button and Compact Page Spacing

**Files:**
- Modify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets:99-152`

- [ ] **Step 1: Remove bottom collapse button**

Delete this bottom button block from `build()`:

```ts
Button() {
  Text(Icons.PACK_UP)
    .fontFamily(Icons.FONT_FAMILY)
    .fontSize(28)
    .fontColor($r('app.color.flip_text_color'))
}
.type(ButtonType.Normal)
.padding(8)
.backgroundColor(Color.Transparent)
.onClick(() => {
  router.back()
})
```

- [ ] **Step 2: Make header and page padding landscape-aware**

Change the top Row margin to:

```ts
.margin({
  top: this.isLandscape ? 16 : 40,
  bottom: this.isLandscape ? 8 : 12,
  right: 12
})
```

Change the root `Column` padding to:

```ts
.padding({
  bottom: this.isLandscape ? 12 : AppConstants.DEFAULT_NAV_HEIGHT,
  left: this.isLandscape ? 18 : 24,
  right: this.isLandscape ? 18 : 24
})
```

- [ ] **Step 3: Make list spacing landscape-aware**

Change the List declaration and margin to:

```ts
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

---

### Task 2: Add Adaptive Layout Helpers

**Files:**
- Modify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets:281-289`

- [ ] **Step 1: Replace `getPreviewWidth()`**

Replace the existing helper with:

```ts
private getPreviewWidth(): Length {
  if (this.selectedSize == ClockWidgetSize.Size2x2) {
    return '100%'
  }
  if (this.isLandscape) {
    if (this.selectedSize == ClockWidgetSize.Size4x4) {
      return 180
    }
    return 300
  }
  if (this.selectedSize == ClockWidgetSize.Size4x4) {
    return 300
  }
  return '100%'
}
```

- [ ] **Step 2: Add grid column helper**

Add this method after `getPreviewWidth()`:

```ts
private getGridColumnsTemplate(): string {
  if (!this.isLandscape) {
    return this.selectedSize == ClockWidgetSize.Size2x2 ? '1fr 1fr' : '1fr'
  }
  if (this.selectedSize == ClockWidgetSize.Size2x2) {
    return '1fr 1fr 1fr 1fr'
  }
  if (this.selectedSize == ClockWidgetSize.Size4x4) {
    return '1fr 1fr 1fr'
  }
  return '1fr 1fr'
}
```

- [ ] **Step 3: Add spacing helpers**

Add these methods after `getGridColumnsTemplate()`:

```ts
private getGroupSpacing(): number {
  return this.isLandscape ? 10 : 12
}

private getGridColumnsGap(): number {
  return this.isLandscape ? 12 : 16
}

private getGridRowsGap(): number {
  return this.isLandscape ? 14 : 18
}
```

---

### Task 3: Use Adaptive Multi-Column Group Grids

**Files:**
- Modify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets:182-222`

- [ ] **Step 1: Update group container spacing**

Change:

```ts
Column({ space: 12 }) {
```

To:

```ts
Column({ space: this.getGroupSpacing() }) {
```

- [ ] **Step 2: Replace conditional 2x2-only Grid/Column with a single adaptive Grid**

Replace the current `if (this.selectedSize == ClockWidgetSize.Size2x2) { Grid() ... } else { Column() ... }` block with:

```ts
Grid() {
  ForEach(this.getGroupItems(group), (item: ClockWidgetConfig) => {
    GridItem() {
      this.WidgetItem(item)
    }
  }, (item: ClockWidgetConfig) => item.id)
}
.columnsTemplate(this.getGridColumnsTemplate())
.columnsGap(this.getGridColumnsGap())
.rowsGap(this.getGridRowsGap())
.width('100%')
```

This keeps portrait `2x4` and `4x4` single-column while enabling landscape multi-column layout.

---

### Task 4: Replace Blue Tab Selected State with Neutral Segmented Control

**Files:**
- Modify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets:154-180`

- [ ] **Step 1: Update Tab button visual style**

In `SizeTabs()`, replace the Button style chain with:

```ts
Button(getClockWidgetSizeLabel(widgetSize))
  .type(ButtonType.Normal)
  .layoutWeight(1)
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
```

- [ ] **Step 2: Update Tab wrapper spacing**

Keep the wrapper neutral and compact:

```ts
.width('100%')
.padding(4)
.borderRadius(18)
.backgroundColor($r('app.color.flip_card_bg_color'))
```

Expected: no `$r('app.color.blue')` remains in `ClockWidgetsPage.ets`.

---

### Task 5: Verify

**Files:**
- Verify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets`

- [ ] **Step 1: Confirm removed bottom button and blue Tab usage**

Run:

```bash
grep -n "PACK_UP\|app.color.blue" entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets
```

Expected: no output.

- [ ] **Step 2: Confirm landscape helper symbols exist**

Run:

```bash
grep -n "isLandscape ? 16 : 40\|getGridColumnsTemplate\|getGroupSpacing\|getGridColumnsGap\|getGridRowsGap" entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets
```

Expected: matches for all helper names and landscape header margin.

- [ ] **Step 3: Build without installing or launching**

Run:

```bash
./run-harmony.sh --skip-install --skip-start
```

Expected: `BUILD SUCCESSFUL`.

- [ ] **Step 4: Manual UI verification if device/preview is available**

Open Settings → 桌面小组件 and verify:

```text
Portrait: no bottom collapse button; Tab selected state is neutral, not blue; portrait widget proportions still match the prior design.
Landscape: page has more vertical browsing space; 2x2 uses compact multi-column layout; 2x4 and 4x4 previews are smaller and can appear in multiple columns; Tab selected state is neutral.
```

If no local device/preview is available, report that manual UI verification was not completed locally.

---

## Self-Review

- Spec coverage: The plan covers removing the bottom button, compact landscape padding/spacing, landscape multi-column layout, smaller landscape `2x4`/`4x4` previews, portrait preservation, and neutral non-blue Tabs.
- Placeholder scan: No TBD/TODO/implement-later placeholders remain.
- Type consistency: Helper names and ArkUI properties are consistent across the tasks.
