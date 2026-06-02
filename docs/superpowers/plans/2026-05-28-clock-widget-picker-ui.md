# Clock Widget Picker UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rework the desktop widget picker so size selection uses Tabs, widgets are grouped by style type, unsupported styles are hidden, and previews use realistic 2x2 / 2x4 / 4x4 proportions.

**Architecture:** Keep the existing widget renderer (`ClockWidgetView`) as the source of truth for widget visuals. Change only `ClockWidgetsPage.ets` so it computes visible grouped data and renders size-specific preview containers around `ClockWidgetView`. Remove the special round carousel in favor of one independent item per round style.

**Tech Stack:** HarmonyOS ArkTS / ArkUI ETS components, existing `ClockWidgetConfig` model, existing `ClockWidgetView` component, existing preference persistence through `ClockWidgetConfigManager`.

---

## File Structure

- Modify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets`
  - Owns page-level state (`selectedSize`, `selectedWidgetId`) and save behavior.
  - Will own UI-only grouping metadata and preview sizing builders.
  - Will no longer own round-carousel state or behavior.
- Read-only dependency: `entry/src/main/ets/views/Widgets/ClockWidgetConfig.ets`
  - Provides widget types, sizes, configs, labels, support checks, and aspect ratio helper.
- Read-only dependency: `entry/src/main/ets/views/Widgets/ClockWidgetView.ets`
  - Continues rendering actual widget previews.

No new source files are needed. This is a focused page-level UI change.

## Commit Policy

This session does not have explicit permission to create commits. Do not run `git commit` while executing this plan unless the user explicitly asks for a commit.

---

### Task 1: Simplify Page State and Add Grouping Helpers

**Files:**
- Modify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets:4-122`

- [ ] **Step 1: Update imports**

Replace the import block from `../../views/Widgets/ClockWidgetConfig` so the page no longer imports `ClockWidgetStyleType` only for the round carousel and keeps the sizing helpers it needs:

```ts
import {
  ClockWidgetConfig,
  ClockWidgetSize,
  ClockWidgetStyleType,
  CLOCK_WIDGET_CONFIGS,
  CLOCK_WIDGET_SIZES,
  DEFAULT_CLOCK_WIDGET_ID,
  getClockWidgetSizeAspectRatio,
  getClockWidgetSizeLabel,
  isClockWidgetSizeSupported
} from '../../views/Widgets/ClockWidgetConfig'
```

Keep `ClockWidgetStyleType` because grouping uses it.

- [ ] **Step 2: Add a page-local grouping interface**

Add this interface after the imports and before `@Entry`:

```ts
interface ClockWidgetGroup {
  title: string
  types: ClockWidgetStyleType[]
}
```

- [ ] **Step 3: Replace round-carousel state with static group metadata**

Inside `struct ClockWidgetsPage`, remove:

```ts
@State roundPreviewIndex: number = 0
```

Add this readonly group list below the remaining state fields:

```ts
private readonly widgetGroups: ClockWidgetGroup[] = [
  {
    title: '数字表盘',
    types: [ClockWidgetStyleType.Minimal, ClockWidgetStyleType.Digital]
  },
  {
    title: '翻页表盘',
    types: [ClockWidgetStyleType.Flip]
  },
  {
    title: '指针表盘',
    types: [ClockWidgetStyleType.Round]
  },
  {
    title: '日期表盘',
    types: [ClockWidgetStyleType.Lunar]
  }
]
```

- [ ] **Step 4: Remove round-carousel initialization**

In `aboutToAppear()`, delete this line:

```ts
this.syncRoundPreviewIndex()
```

The method should remain:

```ts
aboutToAppear(): void {
  this.selectedWidgetId = ClockWidgetConfigManager.getDefaultWidgetId(getContext(this))
  const selectedConfig = CLOCK_WIDGET_CONFIGS.find((item: ClockWidgetConfig) => item.id == this.selectedWidgetId)
  if (selectedConfig != undefined && !isClockWidgetSizeSupported(selectedConfig, this.selectedSize)) {
    this.selectedSize = selectedConfig.supportedSizes[0]
  }
}
```

- [ ] **Step 5: Replace item helper methods**

Keep `getCurrentItems()` as-is. Delete these methods completely:

```ts
private getRoundItems(): ClockWidgetConfig[]
private getRegularItems(): ClockWidgetConfig[]
private getCurrentRoundItem(): ClockWidgetConfig
private syncRoundPreviewIndex(): void
private switchRound(direction: number): void
```

Add these methods after `getCurrentItems()`:

```ts
private getGroupItems(group: ClockWidgetGroup): ClockWidgetConfig[] {
  return this.getCurrentItems().filter((item: ClockWidgetConfig) => {
    return group.types.indexOf(item.type) >= 0
  })
}

private getVisibleGroups(): ClockWidgetGroup[] {
  return this.widgetGroups.filter((group: ClockWidgetGroup) => {
    return this.getGroupItems(group).length > 0
  })
}
```

- [ ] **Step 6: Update size switch behavior**

In `SizeTabs()` click handler, delete:

```ts
this.syncRoundPreviewIndex()
```

Keep the selected-widget fallback:

```ts
.onClick(() => {
  this.selectedSize = widgetSize
  const selectedConfig = CLOCK_WIDGET_CONFIGS.find((item: ClockWidgetConfig) => item.id == this.selectedWidgetId)
  if (selectedConfig == undefined || !isClockWidgetSizeSupported(selectedConfig, widgetSize)) {
    this.selectedWidgetId = this.getCurrentItems()[0].id
  }
})
```

- [ ] **Step 7: Verify syntax after helper refactor**

Run a search to ensure removed helpers have no references:

```bash
grep -n "RoundSwitcherItem\|RoundSwitchButton\|roundPreviewIndex\|syncRoundPreviewIndex\|switchRound\|getRoundItems\|getRegularItems\|getCurrentRoundItem" entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets
```

Expected: no output after Task 2 is also complete. During Task 1, references may still exist in the old builders until Task 2 removes them.

---

### Task 2: Replace the List Body with Group Sections

**Files:**
- Modify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets:124-183`

- [ ] **Step 1: Replace the `List` content in `build()`**

Replace the current `List({ space: 16 }) { ... }` body with grouped sections:

```ts
List({ space: 26 }) {
  ForEach(this.getVisibleGroups(), (group: ClockWidgetGroup) => {
    ListItem() {
      this.WidgetGroupSection(group)
    }
  }, (group: ClockWidgetGroup) => group.title)
}
.scrollBar(BarState.Off)
.layoutWeight(1)
.margin({ top: 18 })
```

This removes the special round switcher and regular-item split.

- [ ] **Step 2: Add the group section builder**

Add this builder after `SizeTabs()` and before the item builder methods:

```ts
@Builder
WidgetGroupSection(group: ClockWidgetGroup) {
  Column({ space: 12 }) {
    Row() {
      Text(group.title)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.flip_text_color'))

      Blank()

      Text(`${this.getGroupItems(group).length} 款`)
        .fontSize(12)
        .fontColor($r('app.color.flip_text_color'))
        .opacity(0.5)
    }
    .width('100%')

    if (this.selectedSize == ClockWidgetSize.Size2x2) {
      Grid() {
        ForEach(this.getGroupItems(group), (item: ClockWidgetConfig) => {
          GridItem() {
            this.WidgetItem(item)
          }
        }, (item: ClockWidgetConfig) => item.id)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(16)
      .rowsGap(18)
      .width('100%')
    } else {
      Column({ space: 18 }) {
        ForEach(this.getGroupItems(group), (item: ClockWidgetConfig) => {
          this.WidgetItem(item)
        }, (item: ClockWidgetConfig) => item.id)
      }
      .width('100%')
    }
  }
  .width('100%')
}
```

- [ ] **Step 3: Delete old round carousel builders**

Delete these builders completely:

```ts
@Builder
RoundSwitcherItem() { ... }

@Builder
RoundSwitchButton(direction: number) { ... }
```

- [ ] **Step 4: Verify no old round carousel references remain**

Run:

```bash
grep -n "RoundSwitcherItem\|RoundSwitchButton\|roundPreviewIndex\|syncRoundPreviewIndex\|switchRound\|getRoundItems\|getRegularItems\|getCurrentRoundItem" entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets
```

Expected: no output.

---

### Task 3: Render Independent Real-Proportion Widget Items

**Files:**
- Modify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets:313-380`

- [ ] **Step 1: Replace `WidgetItem` with a no-card item layout**

Replace the existing `WidgetItem(item: ClockWidgetConfig)` builder with:

```ts
@Builder
WidgetItem(item: ClockWidgetConfig) {
  Column({ space: 8 }) {
    Stack() {
      ClockWidgetView({
        config: item,
        widgetSize: this.selectedSize
      })

      if (this.isSelected(item)) {
        Text(Icons.CHECKED)
          .fontFamily(Icons.FONT_FAMILY)
          .fontSize(24)
          .fontColor(Color.Green)
          .margin(10)
      }
    }
    .alignContent(Alignment.BottomEnd)
    .width(this.getPreviewWidth())
    .aspectRatio(getClockWidgetSizeAspectRatio(this.selectedSize))
    .border({
      width: 2,
      color: this.isSelected(item) ? Color.Green : Color.Transparent,
      radius: 24
    })
    .clip(true)
    .shadow({
      radius: 12,
      color: '#24000000',
      offsetY: 5
    })

    Column({ space: 3 }) {
      Text(item.title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.flip_text_color'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(item.subtitle)
        .fontSize(12)
        .fontColor($r('app.color.flip_text_color'))
        .opacity(0.5)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width(this.getPreviewWidth())
    .alignItems(HorizontalAlign.Start)
  }
  .width('100%')
  .alignItems(this.selectedSize == ClockWidgetSize.Size2x2 ? HorizontalAlign.Start : HorizontalAlign.Center)
  .onClick(() => {
    this.selectedWidgetId = item.id
  })
}
```

- [ ] **Step 2: Add preview width helper**

Add this method near the bottom of the struct, before `supportSizeText()` or replace `supportSizeText()` if it becomes unused:

```ts
private getPreviewWidth(): Length {
  if (this.selectedSize == ClockWidgetSize.Size2x2) {
    return '100%'
  }
  if (this.selectedSize == ClockWidgetSize.Size4x4) {
    return 300
  }
  return '100%'
}
```

- [ ] **Step 3: Remove unused support-size text helper if unused**

After replacing `WidgetItem`, run:

```bash
grep -n "supportSizeText" entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets
```

If the only match is the method declaration, delete:

```ts
private supportSizeText(item: ClockWidgetConfig): string {
  const labels: string[] = []
  item.supportedSizes.forEach((widgetSize: ClockWidgetSize) => {
    labels.push(getClockWidgetSizeLabel(widgetSize))
  })
  return labels.join(' / ')
}
```

- [ ] **Step 4: Remove unused import if necessary**

If `supportSizeText()` is removed, `getClockWidgetSizeLabel` is still used by `SizeTabs()`, so keep it imported.

---

### Task 4: Polish Size Tabs for Tab-Like Behavior

**Files:**
- Modify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets:185-207`

- [ ] **Step 1: Replace `SizeTabs()` visual wrapper**

Replace the current `SizeTabs()` builder with:

```ts
@Builder
SizeTabs() {
  Row({ space: 6 }) {
    ForEach(CLOCK_WIDGET_SIZES, (widgetSize: ClockWidgetSize) => {
      Button(getClockWidgetSizeLabel(widgetSize))
        .type(ButtonType.Normal)
        .layoutWeight(1)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.selectedSize == widgetSize ? Color.White : $r('app.color.flip_text_color'))
        .backgroundColor(this.selectedSize == widgetSize ? $r('app.color.blue') : Color.Transparent)
        .borderRadius(14)
        .padding({ top: 10, bottom: 10 })
        .onClick(() => {
          this.selectedSize = widgetSize
          const selectedConfig = CLOCK_WIDGET_CONFIGS.find((item: ClockWidgetConfig) => item.id == this.selectedWidgetId)
          if (selectedConfig == undefined || !isClockWidgetSizeSupported(selectedConfig, widgetSize)) {
            this.selectedWidgetId = this.getCurrentItems()[0].id
          }
        })
    }, (widgetSize: ClockWidgetSize) => getClockWidgetSizeLabel(widgetSize))
  }
  .width('100%')
  .padding(4)
  .borderRadius(18)
  .backgroundColor($r('app.color.flip_card_bg_color'))
}
```

- [ ] **Step 2: Confirm Tab behavior still preserves valid selection**

Manually inspect the click handler after editing. It must still set `selectedSize`, check support against `widgetSize`, and fallback to `this.getCurrentItems()[0].id` only when the selected widget is unsupported.

---

### Task 5: Build and Static Verification

**Files:**
- Verify: `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets`

- [ ] **Step 1: Check for old carousel symbols**

Run:

```bash
grep -n "RoundSwitcherItem\|RoundSwitchButton\|roundPreviewIndex\|syncRoundPreviewIndex\|switchRound\|getRoundItems\|getRegularItems\|getCurrentRoundItem\|supportSizeText" entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets
```

Expected: no output.

- [ ] **Step 2: Check current grouping symbols exist**

Run:

```bash
grep -n "ClockWidgetGroup\|widgetGroups\|getGroupItems\|getVisibleGroups\|WidgetGroupSection\|getPreviewWidth" entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets
```

Expected: matches for all six names.

- [ ] **Step 3: Run available Harmony build command**

Try the local project build command:

```bash
hvigor assembleHap --mode module -p module=entry@default
```

Expected: build succeeds. If `hvigor` is not available in PATH, report that the build command could not run locally and include the exact shell error.

- [ ] **Step 4: Manual UI verification if local device tooling is available**

If the Harmony preview/device workflow is configured locally, open the app, navigate to Settings → 桌面小组件, and verify:

```text
2x2: 数字表盘 and 指针表盘 are visible; 翻页表盘 and 日期表盘 are hidden if unsupported.
2x4: 翻页表盘, 数字表盘, 指针表盘, and 日期表盘 appear according to supportedSizes.
4x4: the previews are single-column and larger than 2x2 previews.
Switching tabs keeps the current widget selected when supported.
Switching tabs falls back to a valid widget when unsupported.
完成 saves and returns.
```

Expected: UI matches the approved browser preview. If no local Harmony preview/device is available, state that manual UI verification could not be completed locally.

---

## Self-Review

- Spec coverage: The plan covers Tab size selection, size filtering, grouping, empty-group hiding, independent previews, 2x2 / 2x4 / larger 4x4 sizing, removal of the round carousel, selection fallback, and save behavior preservation.
- Placeholder scan: No TBD/TODO/implement-later placeholders remain.
- Type consistency: `ClockWidgetGroup`, `ClockWidgetConfig`, `ClockWidgetSize`, `ClockWidgetStyleType`, `Length`, `getGroupItems`, `getVisibleGroups`, `WidgetGroupSection`, and `getPreviewWidth` are used consistently across tasks.
