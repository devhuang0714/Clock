import { Icons } from '../../common/constants/Constants'
import { ClockConfig, CLOCK_CONFIGS } from './ClockConfig'

const CONTENT_HEIGHT = 160

@Extend(Text)
function setTabTextStyles(selected: boolean) {
  .fontSize(22)
  .fontColor($r('app.color.flip_text_color'))
  .borderWidth({
    top: 0,
    left: 0,
    right: 0,
    bottom: 2
  })
  .borderColor(selected ? $r('app.color.flip_text_color') : Color.Transparent)
  .height(36)
}

@CustomDialog
export struct ClockStyleDialog {
  controller: CustomDialogController
  onSelected: (config: ClockConfig) => void = () => {
  }
  @State offsetY: number = CONTENT_HEIGHT
  @State tabItems: string[] = ['主题皮肤', '背景', '字体', '字体颜色', '卡片颜色']
  @State clockItems: ClockConfig[] = CLOCK_CONFIGS
  @State selectedConfig: ClockConfig = CLOCK_CONFIGS[0]
  @State selectedTabIndex: number = 0
  @State selectedColor: string = '#ffcccc'
  private colors: string[] = [
    '#ffcccc', '#ffe6cc', '#ffffcc', '#ccffcc', '#ccffe6', '#ccffff', '#cce6ff', '#ccccff', '#e6ccff', '#ffccff',
    '#ff9999', '#ffcc99', '#ffff99', '#99ff99', '#99ffcc', '#99ffff', '#99ccff', '#9999ff', '#cc99ff', '#ff99ff',
    '#ff6666', '#ffb366', '#ffff66', '#66ff66', '#66ffb3', '#66ffff', '#66b3ff', '#6666ff', '#b366ff', '#ff66ff',
    '#ff3333', '#ff9933', '#ffff33', '#33ff33', '#33ff99', '#33ffff', '#3399ff', '#3333ff', '#9933ff', '#ff33ff',
    '#ff0000', '#ff8000', '#ffff00', '#00ff00', '#00ff80', '#00ffff', '#0080ff', '#0000ff', '#8000ff', '#ff00ff',
    '#f50000', '#f57b00', '#f5f500', '#00f500', '#00f57b', '#00f5f5', '#007bf5', '#0000f5', '#7b00f5', '#f500f5',
    '#d60000', '#d66c00', '#d6d600', '#00d600', '#00d66c', '#00d6d6', '#006cd6', '#0000d6', '#6c00d6', '#d600d6',
    '#a30000', '#a35200', '#a3a300', '#00a300', '#00a352', '#00a3a3', '#0052a3', '#0000a3', '#5200a3', '#a300a3',
    '#5c0000', '#5c2e00', '#5c5c00', '#005c00', '#005c2e', '#005c5c', '#002e5c', '#00005c', '#2e005c', '#5c005c',
    '#ffffff', '#cdcdcd', '#b2b2b2', '#999999', '#7f7f7f', '#666666', '#4c4c4c', '#333333', '#191919', '#000000'
  ];

  aboutToAppear(): void {
    // 深拷贝，防止直接修改原数据
    this.selectedConfig = JSON.parse(JSON.stringify(this.selectedConfig))
  }

  build() {
    Column() {
      Column() {
        Scroll() {
          Row({ space: 24 }) {
            ForEach(this.tabItems, (item: string, index: number) => {
              Text(item)
                .setTabTextStyles(this.selectedTabIndex == index)
                .onClick(() => {
                  this.selectedTabIndex = index
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

        if (this.selectedTabIndex == 1 || this.selectedTabIndex >= 3) {
          this.ColorsView()
        } else {
          this.ClockStylesView()
        }
      }
      .height(CONTENT_HEIGHT)
      .width('100%')
      .padding(12)
      .backgroundColor($r('app.color.cover_bg_color'))
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
  ClockStylesView() {
    Grid() {
      ForEach(this.clockItems, (item: ClockConfig) => {
        GridItem() {
          Stack() {
            Image(item.preview)
              .objectFit(ImageFit.Contain)

            if (item.style == this.selectedConfig.style) {
              Text(Icons.CHECKED)
                .fontFamily(Icons.FONT_FAMILY)
                .fontSize(24)
                .fontColor(Color.Green)
            }
          }
          .alignContent(Alignment.BottomEnd)
        }
        .border({
          width: 3,
          color: item.style == this.selectedConfig.style ? Color.Green : $r('app.color.flip_card_bg_color'),
          radius: 8
        })
        .onClick(() => {
          if (this.selectedConfig.style != item.style) {
            this.selectedConfig = item
            this.onSelected(item)
          }
        })
      })
    }
    .height(60)
    .columnsGap(12)
    .rowsTemplate('1fr')
    .scrollBar(BarState.Off)
  }

  @Builder
  ColorsView() {
    Grid() {
      ForEach(this.colors, (color: string) => {
        GridItem() {
          Stack() {
            Row()
              .height('100%')
              .aspectRatio(1)
              .backgroundColor(color)

            if (this.selectedColor == color) {
              Text(Icons.CHECKED)
                .fontFamily(Icons.FONT_FAMILY)
                .fontSize(24)
                .fontColor(Color.Green)
            }
          }
          .alignContent(Alignment.BottomEnd)
        }
        .border({
          width: 3,
          color: this.selectedColor == color ? Color.Green : color,
          radius: 8
        })
        .onClick(() => {
          this.selectedColor = color
          if (this.selectedTabIndex == 1) {
            this.selectedConfig.backgroundColor = color
          }
          if (this.selectedTabIndex == 3) {
            this.selectedConfig.fontColor = color
          }
          if (this.selectedTabIndex == 4) {
            this.selectedConfig.cardColor = color
          }
          this.onSelected(this.selectedConfig)
        })
      })
    }
    .height(46)
    .columnsGap(12)
    .rowsTemplate('1fr')
    .scrollBar(BarState.Off)
  }
}