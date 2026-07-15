import { Icons } from '../../common/constants/Constants'
import {
  ClockColorSetting,
  ClockConfig,
  CLOCK_CONFIGS,
  getOrderedClockConfigs,
  supportsClockColorSetting
} from './ClockConfig'
import display from '@ohos.display';
import { startVibration } from '../../common/utils/Vibrator'
import Icon from '../../common/icons/Icon'
import {
  ClockPreviewCanvas,
  getCurrentPreviewCanvasHeight,
  getCurrentPreviewCanvasWidth,
  getCurrentPreviewItemHeight,
  getCurrentPreviewItemWidth,
  getCurrentPreviewScale
} from './ClockPreviewCanvas';

@Extend(Text)
function setTabTextStyles(selected: boolean) {
  .fontSize(18)
  .fontColor($r('app.color.flip_text_color'))
  .borderWidth({
    top: 0,
    left: 0,
    right: 0,
    bottom: 2
  })
  .borderColor(selected ? $r('app.color.flip_text_color') : Color.Transparent)
  .height(32)
}

enum TabType {
  Theme,
  Background,
  Font,
  CardColor,
  FontColor,
  ShadowColor,
}

interface TabItem {
  title: string,
  type: TabType
}

interface ColorItem {
  color: ResourceColor,
  title?: string,
  isDefault?: boolean
}

const TAB_BAR_HEIGHT = 32
const TAB_CONTENT_GAP = 12
const PANEL_PADDING = 12
const PANEL_BOTTOM_GAP = 20
const COLOR_PICKER_HEIGHT = 40
const PANEL_CLOSE_OFFSET_EXTRA = 24

@CustomDialog
export struct ClockStyleDialog {
  controller: CustomDialogController
  onSelected: (config: ClockConfig) => void = () => {
  }
  @State offsetY: number = 240
  @State isClosing: boolean = false
  @State tabItems: TabItem[] = [{
    title: '主题皮肤',
    type: TabType.Theme
  }]
  @State clockItems: ClockConfig[] = getOrderedClockConfigs()
  @Watch('changeConfig') @Prop selectedConfig: ClockConfig = CLOCK_CONFIGS[0]
  @Watch('onPreviewOrientationChange') @StorageLink('isLandscape') isLandscape: boolean = false
  @State selectedTabItem: TabItem = this.tabItems[0]
  private scroller: Scroller = new Scroller()
  private previewDate: Date = new Date('2022-09-22 09:22:00')

  aboutToAppear(): void {
    // 深拷贝，防止直接修改原数据
    this.selectedConfig = this.deepCopy(this.selectedConfig)

    this.isClosing = false
    this.offsetY = this.getPanelCloseOffset()
    this.changeConfig()
  }

  onPreviewOrientationChange() {
    if (this.isClosing) {
      this.offsetY = this.getPanelCloseOffset()
    }
    if (this.selectedTabItem.type == TabType.Theme) {
      this.scrollSelectedClockIntoView(50)
    }
  }

  deepCopy<T>(item: T): T {
    return JSON.parse(JSON.stringify(item))
  }

  changeConfig() {
    const tabItems: TabItem[] = [{
      title: '主题皮肤',
      type: TabType.Theme
    }]
    if (supportsClockColorSetting(this.selectedConfig, ClockColorSetting.Background)) {
      tabItems.push({
        title: '背景',
        type: TabType.Background
      })
    }
    if (supportsClockColorSetting(this.selectedConfig, ClockColorSetting.FontColor)) {
      tabItems.push({
        title: '字体颜色',
        type: TabType.FontColor
      })
    }
    if (supportsClockColorSetting(this.selectedConfig, ClockColorSetting.CardColor)) {
      tabItems.push({
        title: '卡片颜色',
        type: TabType.CardColor
      })
    }
    if (supportsClockColorSetting(this.selectedConfig, ClockColorSetting.ShadowColor)) {
      tabItems.push({
        title: '阴影颜色',
        type: TabType.ShadowColor
      })
    }
    this.tabItems = tabItems
    this.selectedTabItem = tabItems[0]
  }

  isSelected(item: ClockConfig): boolean {
    return this.selectedConfig.id == item.id
  }

  getDefaultConfig(): ClockConfig {
    return CLOCK_CONFIGS.find((item: ClockConfig) => item.id == this.selectedConfig.id) ?? this.selectedConfig
  }

  scrollToCenter(index: number) {
    const width = px2vp(display.getDefaultDisplaySync().width)
    let itemRect = this.scroller.getItemRect(index)
    let targetXOffset = this.scroller.currentOffset().xOffset + itemRect.x - (width - itemRect.width) / 2
    this.scroller.scrollTo({
      xOffset: targetXOffset, yOffset: 0, animation: {
        duration: 300
      }
    })
  }

  scrollSelectedClockIntoView(delay: number = 100) {
    setTimeout(() => {
      const index = this.clockItems.findIndex(item => item.id === this.selectedConfig.id)
      if (index >= 0) {
        this.scroller.scrollToIndex(index)
      }
    }, delay)
  }

  getPreviewCanvasWidth(): number {
    return getCurrentPreviewCanvasWidth(this.isLandscape)
  }

  getPreviewCanvasHeight(): number {
    return getCurrentPreviewCanvasHeight(this.isLandscape)
  }

  getClockStyleItemWidth(): number {
    return getCurrentPreviewItemWidth(this.isLandscape)
  }

  getClockStyleItemHeight(): number {
    return getCurrentPreviewItemHeight(this.isLandscape)
  }

  getPreviewScale(): number {
    return getCurrentPreviewScale(this.isLandscape)
  }

  getTabContentHeight(): number {
    return Math.max(this.getClockStyleItemHeight(), COLOR_PICKER_HEIGHT)
  }

  getPanelHeight(): number {
    return TAB_BAR_HEIGHT + TAB_CONTENT_GAP + this.getTabContentHeight() + PANEL_PADDING * 2 + PANEL_BOTTOM_GAP
  }

  getPanelCloseOffset(): number {
    return this.getPanelHeight() + PANEL_CLOSE_OFFSET_EXTRA
  }

  closeDialog() {
    if (this.isClosing) {
      return
    }
    this.isClosing = true
    this.offsetY = this.getPanelCloseOffset()
  }

  build() {
    Column() {
      Column() {
        Scroll() {
          Row({ space: 16 }) {
            ForEach(this.tabItems, (item: TabItem) => {
              Text(item.title)
                .setTabTextStyles(this.selectedTabItem.type == item.type)
                .onClick(() => {
                  this.selectedTabItem = item
                  startVibration()
                })
            })
          }
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .align(Alignment.Start)
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .height(TAB_BAR_HEIGHT)

        Blank()
          .height(TAB_CONTENT_GAP)

        Stack({ alignContent: Alignment.TopStart }) {
          ForEach(this.tabItems, (item: TabItem) => {
            if (item.type == TabType.Theme) {
              this.ClockStylesView(TabType.Theme)
            } else if (item.type == TabType.Background) {
              ColorsView({
                selectedColor: this.selectedConfig.colors.backgroundColor,
                defaultColor: this.getDefaultConfig().colors.backgroundColor,
                showDefaultOption: true,
                onSelected: (color) => {
                  this.selectedConfig.colors.backgroundColor = color
                  this.onSelected(this.selectedConfig)
                }
              })
                .visibility(this.selectedTabItem.type == TabType.Background ? Visibility.Visible : Visibility.Hidden)
            } else if (item.type == TabType.CardColor) {
              ColorsView({
                selectedColor: this.selectedConfig.colors.cardColor ?? '',
                defaultColor: this.getDefaultConfig().colors.cardColor ?? '',
                showDefaultOption: true,
                onSelected: (color) => {
                  this.selectedConfig.colors.cardColor = color
                  this.onSelected(this.selectedConfig)
                }
              })
                .visibility(this.selectedTabItem.type == TabType.CardColor ? Visibility.Visible : Visibility.Hidden)
            } else if (item.type == TabType.FontColor) {
              ColorsView({
                selectedColor: this.selectedConfig.colors.fontColor,
                defaultColor: this.getDefaultConfig().colors.fontColor,
                showDefaultOption: true,
                onSelected: (color) => {
                  this.selectedConfig.colors.fontColor = color
                  this.onSelected(this.selectedConfig)
                }
              })
                .visibility(this.selectedTabItem.type == TabType.FontColor ? Visibility.Visible : Visibility.Hidden)
            } else if (item.type == TabType.ShadowColor) {
              ColorsView({
                selectedColor: (this.selectedConfig.colors.shadowColor ?? '') as string,
                defaultColor: this.getDefaultConfig().colors.shadowColor ?? '',
                showDefaultOption: true,
                onSelected: (color) => {
                  this.selectedConfig.colors.shadowColor = color
                  this.onSelected(this.selectedConfig)
                }
              })
                .visibility(this.selectedTabItem.type == TabType.ShadowColor ? Visibility.Visible : Visibility.Hidden)
            }
          })
        }
        .height(this.getTabContentHeight())
      }
      .height(this.getPanelHeight())
      .width('100%')
      .padding({
        left: PANEL_PADDING,
        right: PANEL_PADDING,
        top: PANEL_PADDING,
        bottom: PANEL_PADDING + PANEL_BOTTOM_GAP
      })
      .backgroundColor($r('app.color.cover_bg_color'))
      .backdropBlur(20) // 高斯模糊
      .offset({
        y: this.offsetY
      })
      .animation({
        duration: 400,
        onFinish: () => {
          if (this.isClosing) {
            this.controller.close()
          }
        }
      })
      .onClick(() => {
      })
    }
    .justifyContent(FlexAlign.End)
    .backgroundColor(Color.Transparent)
    .height('100%')
    .width('100%')
    .onAppear(() => {
      this.isClosing = false
      this.offsetY = 0
    })
    .onClick(() => {
      this.closeDialog()
    })
  }

  @Builder
  ClockStylesView(type: TabType) {
    Grid(this.scroller) {
      ForEach(this.clockItems, (item: ClockConfig, index: number) => {
        GridItem() {
          Stack() {
            this.PreviewClockView(item)

            if (this.isSelected(item)) {
              Icon({
                name: Icons.CHECKED,
                iconSize: 24,
                color: Color.Green
              })
            }
          }
          .alignContent(Alignment.BottomEnd)
        }
        .width(this.getClockStyleItemWidth())
        .height(this.getClockStyleItemHeight())
        .border({
          width: 2,
          color: this.isSelected(item) ? Color.Green : $r('app.color.flip_card_bg_color'),
          radius: 8
        })
        .clip(true)
        .onClick(() => {
          if (!this.isSelected(item)) {
            startVibration()

            this.selectedConfig = this.deepCopy(item)
            this.onSelected(this.selectedConfig)

            let index = this.clockItems.indexOf(item)
            this.scrollToCenter(index)
          }
        })
      })
    }
    .height(this.getClockStyleItemHeight())
    .columnsGap(12)
    .rowsTemplate('1fr')
    .scrollBar(BarState.Off)
    .visibility(this.selectedTabItem.type == type ? Visibility.Visible : Visibility.Hidden)
    .onAppear(() => {
      this.scrollSelectedClockIntoView()
    })
  }

  @Builder
  PreviewClockView(clockConfig: ClockConfig) {
    Stack({ alignContent: Alignment.Center }) {
      ClockPreviewCanvas({
        clockConfig: clockConfig,
        date: this.previewDate,
        isLandscape: this.isLandscape,
        canvasWidth: this.getPreviewCanvasWidth(),
        canvasHeight: this.getPreviewCanvasHeight()
      })
        .width(this.getPreviewCanvasWidth())
        .height(this.getPreviewCanvasHeight())
        .scale({
          x: this.getPreviewScale(),
          y: this.getPreviewScale(),
          centerX: '50%',
          centerY: '50%'
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
  }
}

@Component
struct ColorsView {
  @Prop selectedColor: ResourceColor = '#ffcccc'
  @Prop defaultColor: ResourceColor = ''
  @Prop showDefaultOption: boolean = false
  onSelected: (color: ResourceColor) => void = () => {
  }
  private colors: string[] = [
    "#ffffff", "#000000", "#ffcccc", "#ff9999", "#ff6666", "#ff3333", "#ff0000", "#f50000", "#d60000", "#a30000",
    "#5c0000", "#ffe6cc", "#ffcc99", "#ffb366", "#ff9933", "#ff8000", "#f57b00", "#d66c00", "#a35200", "#5c2e00",
    "#cdcdcd", "#ffffcc", "#ffff99", "#ffff66", "#ffff33", "#ffff00", "#f5f500", "#d6d600", "#a3a300", "#5c5c00",
    "#b2b2b2", "#ccffcc", "#99ff99", "#66ff66", "#33ff33", "#00ff00", "#00f500", "#00d600", "#00a300", "#005c00",
    "#999999", "#ccffe6", "#99ffcc", "#66ffb3", "#33ff99", "#00ff80", "#00f57b", "#00d66c", "#00a352", "#005c2e",
    "#7f7f7f", "#ccffff", "#99ffff", "#66ffff", "#33ffff", "#00ffff", "#00f5f5", "#00d6d6", "#00a3a3", "#005c5c",
    "#666666", "#cce6ff", "#99ccff", "#66b3ff", "#3399ff", "#0080ff", "#007bf5", "#006cd6", "#0052a3", "#002e5c",
    "#4c4c4c", "#ccccff", "#9999ff", "#6666ff", "#3333ff", "#0000ff", "#0000f5", "#0000d6", "#0000a3", "#00005c",
    "#333333", "#e6ccff", "#cc99ff", "#b366ff", "#9933ff", "#8000ff", "#7b00f5", "#6c00d6", "#5200a3", "#2e005c",
    "#191919", "#ffccff", "#ff99ff", "#ff66ff", "#ff33ff", "#ff00ff", "#f500f5", "#d600d6", "#a300a3", "#5c005c"
  ]
  private scroller: Scroller = new Scroller()

  getColorItems(): ColorItem[] {
    const items: ColorItem[] = this.colors.map((color: string): ColorItem => {
      return { color: color }
    })
    if (this.showDefaultOption) {
      items.unshift({
        color: this.defaultColor,
        title: '[默认]',
        isDefault: true
      })
    }
    return items
  }

  isSameColor(a: ResourceColor, b: ResourceColor): boolean {
    return JSON.stringify(a) == JSON.stringify(b)
  }

  isSelectedColor(item: ColorItem): boolean {
    if (item.isDefault) {
      return this.isSameColor(this.selectedColor, this.defaultColor)
    }
    if (this.showDefaultOption && this.isSameColor(this.selectedColor, this.defaultColor) &&
      this.isSameColor(item.color, this.defaultColor)) {
      return false
    }
    return this.isSameColor(this.selectedColor, item.color)
  }

  scrollToCenter(index: number) {
    const width = px2vp(display.getDefaultDisplaySync().width)
    let itemRect = this.scroller.getItemRect(index)
    let targetXOffset = this.scroller.currentOffset().xOffset + itemRect.x - (width - itemRect.width) / 2
    this.scroller.scrollTo({
      xOffset: targetXOffset, yOffset: 0, animation: {
        duration: 300
      }
    })
  }

  build() {
    Grid(this.scroller) {
      ForEach(this.getColorItems(), (item: ColorItem, index: number) => {
        GridItem() {
          Stack() {
            Row()
              .height('100%')
              .aspectRatio(1)

            if (item.title != undefined) {
              Row() {
                Text(item.title)
                  .fontSize(10)
                  .fontColor('#ffffff')
                  .fontWeight(FontWeight.Medium)
                  .textAlign(TextAlign.Center)
                  .textShadow({ radius: 2, color: '#99000000', offsetX: 0, offsetY: 1 })
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
            }

            if (this.isSelectedColor(item)) {
              Icon({
                name: Icons.CHECKED,
                iconSize: 24,
                color: Color.Green
              })
            }
          }
          .alignContent(Alignment.BottomEnd)
        }
        .width(40)
        .height(40)
        .backgroundColor(item.color)
        .border({
          width: 2,
          color: this.isSelectedColor(item) ? Color.Green : item.color,
          radius: 8
        })
        .onClick(() => {
          startVibration()
          this.selectedColor = item.color
          this.onSelected(item.color)
          this.scrollToCenter(index)
        })
      })
    }
    .height(40)
    .columnsGap(12)
    .rowsTemplate('1fr')
    .scrollBar(BarState.Off)
    .onAppear(() => {
      setTimeout(() => {
        const index = this.getColorItems().findIndex((item: ColorItem) => this.isSelectedColor(item))
        this.scroller.scrollToIndex(index)
      }, 100)
    })
  }
}
