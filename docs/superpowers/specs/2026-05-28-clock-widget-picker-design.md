# Desktop Widget Picker UI Design

## Goal

Optimize the desktop widget selection page so users can browse widget styles by size and visual category, with previews that look close to how widgets appear on the desktop.

## Current Context

The page is implemented in `entry/src/main/ets/pages/Settings/ClockWidgetsPage.ets`. Widget metadata and size support live in `entry/src/main/ets/views/Widgets/ClockWidgetConfig.ets`, and previews are rendered by `ClockWidgetView`.

The existing picker already filters items by selected size, but it presents previews inside large card containers and treats round styles as a special switcher. The new design should make each widget preview feel like an actual desktop widget tile.

## Confirmed UI Direction

Use a top Tab-style size selector for `2x2`, `2x4`, and `4x4`.

For the selected size:

- Show only widget styles whose `supportedSizes` include that size.
- Group visible widgets by style category:
  - 数字表盘: `Minimal`, `Digital`
  - 翻页表盘: `Flip`
  - 指针表盘: `Round`
  - 日期表盘: `Lunar`
- Hide groups that have no widgets for the current size.
- Render each widget as an independent preview, not embedded inside a larger card container.
- Keep the title and subtitle below the preview.
- Use a clear selected state on the preview itself.

## Size Presentation

The preview size should simulate real desktop widget proportions:

- `2x2`: square previews in a two-column grid. This should visually read as half the width of a `2x4` widget.
- `2x4`: wide previews in a single-column list with `2:1` aspect ratio.
- `4x4`: larger square previews in a single-column list. These should be visibly larger than `2x2` previews so they feel like desktop large widgets.

## Interaction Behavior

- Tapping a size Tab updates `selectedSize`.
- If the currently selected widget does not support the new size, select the first visible widget in that size.
- Tapping any widget preview selects that widget.
- Tapping “完成” saves the selected widget ID and updates existing forms as it does today.
- Round widgets should no longer be collapsed into a single carousel; each round style appears as its own item within 指针表盘.
- Remove the bottom collapse button from the widget picker to preserve vertical browsing space.

## Landscape Behavior

Landscape should use a compact multi-column layout:

- Reduce page top/bottom padding and list/group spacing.
- `2x2` widgets use more columns than portrait.
- `2x4` and `4x4` widgets use smaller fixed preview widths and can flow into multiple columns within a group.
- Portrait behavior stays unchanged from the approved picker design.

## Tab Visual Style

The size selector should use a neutral segmented-control style:

- Do not use the blue app accent for the selected Tab.
- Use the existing card/background/text palette, with a subtle elevated selected state.
- Apply the improved Tab style in both portrait and landscape.

## Implementation Notes

The existing `ClockWidgetView` should continue to render the actual widget visuals. The picker page should change only the surrounding selection UI and grouping logic.

The current `getClockWidgetSizeAspectRatio()` helper can still provide aspect ratios, but the picker needs size-specific preview width rules so `4x4` is larger than `2x2` in the selection page.

## Testing

- Verify each Tab filters unsupported widget styles correctly.
- Verify empty groups are hidden.
- Verify selection survives size changes when supported.
- Verify selection moves to a valid widget when the previous selection is unsupported by the new size.
- Verify “完成” persists the selected widget and updates forms.
- Run the app preview if the local Harmony environment supports it; otherwise run available build/type checks and report that manual UI verification could not be completed locally.
