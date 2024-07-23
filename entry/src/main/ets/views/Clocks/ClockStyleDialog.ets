import { Icons } from '../../common/constants/Constants'
import { ClockConfig, CLOCK_CONFIGS } from './ClockConfig'
import display from '@ohos.display';
import { startVibration } from '../../common/utils/Vibrator'

const CONTENT_HEIGHT = 180

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
}

interface TabItem {
  title: string,
  type: TabType
}

@CustomDialog
export struct ClockStyleDialog {
  controller: CustomDialogController
  onSelected: (config: ClockConfig) => void = () => {
  }
  @State offsetY: number = CONTENT_HEIGHT
  @State tabItems: TabItem[] = [{
    title: '主题皮肤',
    type: TabType.Theme
  }]
  @State clockItems: ClockConfig[] = CLOCK_CONFIGS
  @Watch('changeConfig') @Prop selectedConfig: ClockConfig = CLOCK_CONFIGS[0]
  @State selectedTabItem: TabItem = this.tabItems[0]
  private scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    // 深拷贝，防止直接修改原数据
    this.selectedConfig = this.deepCopy(this.selectedConfig)
  }

  deepCopy<T>(item: T): T {
    return JSON.parse(JSON.stringify(item))
  }

  changeConfig() {
    const tabItems: TabItem[] = [
      {
        title: '主题皮肤',
        type: TabType.Theme
      },
      {
        title: '背景',
        type: TabType.Background
      }
    ]
    if (this.selectedConfig.colors.fontColor != '') {
      tabItems.push({
        title: '字体颜色',
        type: TabType.FontColor
      })
    }
    if (this.selectedConfig.colors.cardColor != '') {
      tabItems.push({
        title: '卡片颜色',
        type: TabType.CardColor
      })
    }
    this.tabItems = tabItems
    this.selectedTabItem = tabItems[0]
  }

  isSelected(item: ClockConfig): boolean {
    return this.selectedConfig.id == item.id
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
    Column() {
      Column() {
        Scroll() {
          Row({ space: 16 }) {
            ForEach(this.tabItems, (item: TabItem) => {
              Text(item.title)
                .setTabTextStyles(this.selectedTabItem.type == item.type)
                .onClick(() => {
                  this.selectedTabItem = item
                })
            })
          }
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .align(Alignment.Start)
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)

        Blank()
          .height(12)

        Stack() {
          ForEach(this.tabItems, (item: TabItem) => {
            if (item.type == TabType.Theme) {
              this.ClockStylesView(TabType.Theme)
            } else if (item.type == TabType.Background) {
              ColorsView({
                selectedColor: this.selectedConfig.colors.backgroundColor as string,
                onSelected: (color) => {
                  this.selectedConfig.colors.backgroundColor = color
                  this.onSelected(this.selectedConfig)
                }
              })
                .visibility(this.selectedTabItem.type == TabType.Background ? Visibility.Visible : Visibility.Hidden)
            } else if (item.type == TabType.CardColor) {
              ColorsView({
                selectedColor: this.selectedConfig.colors.cardColor as string,
                onSelected: (color) => {
                  this.selectedConfig.colors.cardColor = color
                  this.onSelected(this.selectedConfig)
                }
              })
                .visibility(this.selectedTabItem.type == TabType.CardColor ? Visibility.Visible : Visibility.Hidden)
            } else if (item.type == TabType.FontColor) {
              ColorsView({
                selectedColor: this.selectedConfig.colors.fontColor as string,
                onSelected: (color) => {
                  this.selectedConfig.colors.fontColor = color
                  this.onSelected(this.selectedConfig)
                }
              })
                .visibility(this.selectedTabItem.type == TabType.FontColor ? Visibility.Visible : Visibility.Hidden)
            }
          })
        }
      }
      .height(CONTENT_HEIGHT)
      .width('100%')
      .padding(12)
      .backgroundColor($r('app.color.cover_bg_color'))
      .backdropBlur(20) // 高斯模糊
      .offset({
        y: this.offsetY
      })
      .animation({
        duration: 400,
        onFinish: () => {
          if (this.offsetY == CONTENT_HEIGHT) {
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
      this.offsetY = 0
    })
    .onClick(() => {
      this.offsetY = CONTENT_HEIGHT
    })
  }

  @Builder
  ClockStylesView(type: TabType) {
    Grid(this.scroller) {
      ForEach(this.clockItems, (item: ClockConfig) => {
        GridItem() {
          Stack() {
            Image(item.preview)
              .objectFit(ImageFit.Contain)

            if (this.isSelected(item)) {
              Text(Icons.CHECKED)
                .fontFamily(Icons.FONT_FAMILY)
                .fontSize(24)
                .fontColor(Color.Green)
            }
          }
          .alignContent(Alignment.BottomEnd)
        }
        .border({
          width: 2,
          color: this.isSelected(item) ? Color.Green : $r('app.color.flip_card_bg_color'),
          radius: 8
        })
        .onClick(() => {
          if (!this.isSelected(item)) {
            startVibration()

            this.selectedConfig = this.deepCopy(item)
            this.onSelected(item)

            let index = this.clockItems.indexOf(item)
            this.scrollToCenter(index)
          }
        })
      })
    }
    .height(60)
    .columnsGap(12)
    .rowsTemplate('1fr')
    .scrollBar(BarState.Off)
    .visibility(this.selectedTabItem.type == type ? Visibility.Visible : Visibility.Hidden)
    .onAppear(() => {
      setTimeout(() => {
        const index = this.clockItems.findIndex(item => item.id === this.selectedConfig.id)
        this.scroller.scrollToIndex(index)
      }, 100)
    })
  }
}

@Component
struct ColorsView {
  @Prop selectedColor: string = '#ffcccc'
  onSelected: (color: string) => void = () => {
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
      ForEach(this.colors, (color: string) => {
        GridItem() {
          Stack() {
            Row()
              .height('100%')
              .aspectRatio(1)

            if (this.selectedColor == color) {
              Text(Icons.CHECKED)
                .fontFamily(Icons.FONT_FAMILY)
                .fontSize(24)
                .fontColor(Color.Green)
            }
          }
          .alignContent(Alignment.BottomEnd)
        }
        .backgroundColor(color)
        .border({
          width: 2,
          color: this.selectedColor == color ? Color.Green : color,
          radius: 8
        })
        .onClick(() => {
          startVibration()
          this.selectedColor = color
          this.onSelected(color)

          let index = this.colors.indexOf(this.selectedColor)
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
        const index = this.colors.findIndex(color => color === this.selectedColor)
        this.scroller.scrollToIndex(index)
      }, 100)
    })
  }
}