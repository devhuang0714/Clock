import { AppConstants, Icons } from '../../common/constants/Constants'
import router from '@ohos.router'
import { ClockWidgetConfigManager } from '../../models/ClockWidgetConfigManager'
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
import { ClockWidgetView } from '../../views/Widgets/ClockWidgetView'

interface ClockWidgetGroup {
  title: string
  types: ClockWidgetStyleType[]
}

@Entry
@Component
struct ClockWidgetsPage {
  @State selectedSize: ClockWidgetSize = ClockWidgetSize.Size2x2
  @State selectedWidgetId: string = DEFAULT_CLOCK_WIDGET_ID
  @StorageProp('isLandscape') isLandscape: boolean = false

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

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 300 })
      .slide(SlideEffect.Bottom)
    PageTransitionExit({ type: RouteType.Pop, duration: 300 })
      .slide(SlideEffect.Bottom)

    PageTransitionEnter({ type: RouteType.Pop, duration: 0 })
    PageTransitionExit({ type: RouteType.Push, duration: 1000 })
  }

  aboutToAppear(): void {
    this.selectedWidgetId = ClockWidgetConfigManager.getDefaultWidgetId(getContext(this))
    const selectedConfig = CLOCK_WIDGET_CONFIGS.find((item: ClockWidgetConfig) => item.id == this.selectedWidgetId)
    if (selectedConfig != undefined && !isClockWidgetSizeSupported(selectedConfig, this.selectedSize)) {
      this.selectedSize = selectedConfig.supportedSizes[0]
    }
  }

  private getCurrentItems(): ClockWidgetConfig[] {
    return CLOCK_WIDGET_CONFIGS.filter((item: ClockWidgetConfig) => {
      return isClockWidgetSizeSupported(item, this.selectedSize)
    })
  }

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

  private isSelected(item: ClockWidgetConfig): boolean {
    return this.selectedWidgetId == item.id
  }

  private saveSelection() {
    const selectedConfig = CLOCK_WIDGET_CONFIGS.find((item: ClockWidgetConfig) => item.id == this.selectedWidgetId)
    if (selectedConfig == undefined || !isClockWidgetSizeSupported(selectedConfig, this.selectedSize)) {
      const firstConfig = this.getCurrentItems()[0]
      this.selectedWidgetId = firstConfig.id
    }

    ClockWidgetConfigManager.setDefaultWidgetId(this.selectedWidgetId, getContext(this))
    ClockWidgetConfigManager.updateAllForms(getContext(this))
  }

  private selectSize(widgetSize: ClockWidgetSize): void {
    this.selectedSize = widgetSize
    const selectedConfig = CLOCK_WIDGET_CONFIGS.find((item: ClockWidgetConfig) => item.id == this.selectedWidgetId)
    if (selectedConfig == undefined || !isClockWidgetSizeSupported(selectedConfig, widgetSize)) {
      this.selectedWidgetId = this.getCurrentItems()[0].id
    }
  }

  build() {
    Column() {
      Row() {
        Button('完成')
          .type(ButtonType.Normal)
          .padding(0)
          .fontSize(18)
          .fontColor($r('app.color.flip_text_color'))
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.saveSelection()
            router.back()
          })
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.End)
      .margin({
        top: this.isLandscape ? 16 : 40,
        bottom: this.isLandscape ? 8 : 12,
        right: 12
      })

      if (this.isLandscape) {
        Row({ space: 14 }) {
          this.LeftSizeTabs()
          this.WidgetList()
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        this.SizeTabs()
        this.WidgetList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
    .padding({
      bottom: this.isLandscape ? 12 : AppConstants.DEFAULT_NAV_HEIGHT,
      left: this.isLandscape ? 18 : 24,
      right: this.isLandscape ? 18 : 24
    })
  }

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
    .margin({ top: this.isLandscape ? 0 : 18 })
  }

  @Builder
  SizeTabs() {
    Row({ space: 6 }) {
      ForEach(CLOCK_WIDGET_SIZES, (widgetSize: ClockWidgetSize) => {
        this.HorizontalSizeTabButton(widgetSize)
      }, (widgetSize: ClockWidgetSize) => getClockWidgetSizeLabel(widgetSize))
    }
    .width('100%')
    .padding(4)
    .borderRadius(18)
    .backgroundColor($r('app.color.flip_card_bg_color'))
  }

  @Builder
  LeftSizeTabs() {
    Column({ space: 6 }) {
      ForEach(CLOCK_WIDGET_SIZES, (widgetSize: ClockWidgetSize) => {
        this.VerticalSizeTabButton(widgetSize)
      }, (widgetSize: ClockWidgetSize) => getClockWidgetSizeLabel(widgetSize))
    }
    .width(68)
    .padding(4)
    .borderRadius(18)
    .backgroundColor($r('app.color.flip_card_bg_color'))
  }

  @Builder
  HorizontalSizeTabButton(widgetSize: ClockWidgetSize) {
    Button(getClockWidgetSizeLabel(widgetSize))
      .type(ButtonType.Normal)
      .layoutWeight(1)
      .fontSize(15)
      .fontWeight(this.selectedSize == widgetSize ? FontWeight.Bold : FontWeight.Medium)
      .fontColor($r('app.color.flip_text_color'))
      .backgroundColor(this.selectedSize == widgetSize ? $r('app.color.main_background_color') : Color.Transparent)
      .borderRadius(14)
      .padding({ top: 8, bottom: 8 })
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
        this.selectSize(widgetSize)
      })
  }

  @Builder
  VerticalSizeTabButton(widgetSize: ClockWidgetSize) {
    Button(getClockWidgetSizeLabel(widgetSize))
      .type(ButtonType.Normal)
      .width('100%')
      .fontSize(14)
      .fontWeight(this.selectedSize == widgetSize ? FontWeight.Bold : FontWeight.Medium)
      .fontColor($r('app.color.flip_text_color'))
      .backgroundColor(this.selectedSize == widgetSize ? $r('app.color.main_background_color') : Color.Transparent)
      .borderRadius(14)
      .padding({ top: 12, bottom: 12 })
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
        this.selectSize(widgetSize)
      })
  }

  @Builder
  WidgetGroupSection(group: ClockWidgetGroup) {
    Column({ space: this.getGroupSpacing() }) {
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
    }
    .width('100%')
  }

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

  private getGroupSpacing(): number {
    return this.isLandscape ? 10 : 12
  }

  private getGridColumnsGap(): number {
    return this.isLandscape ? 12 : 16
  }

  private getGridRowsGap(): number {
    return this.isLandscape ? 14 : 18
  }
}
