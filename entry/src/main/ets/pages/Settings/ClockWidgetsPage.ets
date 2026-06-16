import { Want } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { AddFormMenuItem } from '@kit.ArkUI'
import { formBindingData, formInfo } from '@kit.FormKit'
import { Toast } from 'utils'
import { AppConstants, Icons } from '../../common/constants/Constants'
import router from '@ohos.router'
import {
  CLOCK_WIDGET_STYLE_PARAM,
  ClockWidgetConfigManager
} from '../../models/ClockWidgetConfigManager'
import {
  ClockWidgetConfig,
  ClockWidgetSize,
  ClockWidgetStyleType,
  CLOCK_WIDGET_CONFIGS,
  CLOCK_WIDGET_SIZES,
  DEFAULT_CLOCK_WIDGET_ID,
  getClockWidgetDimension,
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
  @State defaultWidgetId: string = DEFAULT_CLOCK_WIDGET_ID
  @State isAddFormMenuShown: boolean = false
  @StorageProp('isLandscape') isLandscape: boolean = false

  private readonly formName: string = 'clock_widget'
  private readonly moduleName: string = 'entry'
  private readonly formAbilityName: string = 'ClockWidgetAbility'
  private readonly previewComponentIdPrefix: string = 'clock_widget_preview_'
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
    this.defaultWidgetId = ClockWidgetConfigManager.getDefaultWidgetId(getContext(this))
    this.selectedWidgetId = this.defaultWidgetId
    this.ensureSelectedWidgetSupportsSize()
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

  private isDefault(item: ClockWidgetConfig): boolean {
    return this.defaultWidgetId == item.id
  }

  private getSelectedDimension(): number {
    return getClockWidgetDimension(this.selectedSize)
  }

  private ensureSelectedWidgetSupportsSize(): void {
    const selectedConfig = CLOCK_WIDGET_CONFIGS.find((item: ClockWidgetConfig) => item.id == this.selectedWidgetId)
    if (selectedConfig != undefined && isClockWidgetSizeSupported(selectedConfig, this.selectedSize)) {
      return
    }

    const firstConfig = this.getCurrentItems()[0]
    this.selectedWidgetId = firstConfig.id
  }

  private selectSize(widgetSize: ClockWidgetSize): void {
    this.selectedSize = widgetSize
    this.ensureSelectedWidgetSupportsSize()
  }

  private selectWidget(item: ClockWidgetConfig): void {
    this.selectedWidgetId = item.id
  }

  private setDefaultWidget(widgetId: string): void {
    this.defaultWidgetId = widgetId
    ClockWidgetConfigManager.setDefaultWidgetId(widgetId, getContext(this))
    Toast.show('已设为下次添加的默认样式')
  }

  private createAddFormWant(widgetId: string): Want {
    let parameters: Record<string, Object> = {}
    parameters[formInfo.FormParam.DIMENSION_KEY] = this.getSelectedDimension()
    parameters[formInfo.FormParam.NAME_KEY] = this.formName
    parameters[formInfo.FormParam.MODULE_NAME_KEY] = this.moduleName
    parameters[CLOCK_WIDGET_STYLE_PARAM] = widgetId

    return {
      bundleName: AppConstants.BUNDLE_NAME,
      abilityName: this.formAbilityName,
      parameters: parameters
    }
  }

  private createPreviewFormData(widgetId: string): Object {
    return ClockWidgetConfigManager.createFormData(
      getContext(this),
      'preview',
      this.getSelectedDimension(),
      widgetId
    )
  }

  private getPreviewComponentId(widgetId: string): string {
    return `${this.previewComponentIdPrefix}${widgetId}`
  }

  private showAddFormMenu(widgetId: string): void {
    this.selectedWidgetId = widgetId
    this.isAddFormMenuShown = false
    setTimeout(() => {
      ClockWidgetConfigManager.savePendingWidgetId(getContext(this), widgetId, this.getSelectedDimension())
      this.isAddFormMenuShown = true
    }, 0)
  }

  build() {
    Column() {
      if (this.isLandscape) {
        Row({ space: 18 }) {
          Column({ space: 16 }) {
            this.Header()
            this.LeftSizeTabs()
          }
          .width(220)
          .height('100%')
          .alignItems(HorizontalAlign.Start)

          this.WidgetList()
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        this.Header()
        this.SizeTabs()
        this.WidgetList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
    .padding({
      top: this.isLandscape ? 16 : 40,
      bottom: this.isLandscape ? 12 : AppConstants.DEFAULT_NAV_HEIGHT,
      left: this.isLandscape ? 18 : 24,
      right: this.isLandscape ? 18 : 24
    })
  }

  @Builder
  Header() {
    Column({ space: 8 }) {
      Row() {
        Button() {
          Text(Icons.CLOSE)
            .fontFamily(Icons.FONT_FAMILY)
            .fontSize(22)
            .fontColor($r('app.color.flip_text_color'))
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .padding(4)
        .onClick(() => {
          router.back()
        })
      }
      .width('100%')
      .height(32)
      .alignItems(VerticalAlign.Center)

      Column({ space: 4 }) {
        Text('桌面小组件')
          .fontSize(this.isLandscape ? 22 : 24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.flip_text_color'))

        Text('选择尺寸和样式，添加到桌面后每个组件会保持独立样式')
          .fontSize(13)
          .fontColor($r('app.color.flip_text_color'))
          .opacity(0.58)
          .maxLines(2)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
  }

  @Builder
  SelectedAddFormMenu() {
    Menu() {
      AddFormMenuItem(
        this.createAddFormWant(this.selectedWidgetId),
        this.getPreviewComponentId(this.selectedWidgetId),
        {
          formBindingData: formBindingData.createFormBindingData(this.createPreviewFormData(this.selectedWidgetId)),
          callback: (error: BusinessError, formId: string) => {
            if (error?.code === 0) {
              Toast.show('已添加到桌面')
            } else {
              Toast.show('添加失败，请从桌面卡片管理中添加')
            }
          },
          style: {
            options: {
              content: '添加到桌面'
            }
          }
        }
      )
    }
  }

  @Builder
  WidgetList() {
    List({ space: this.isLandscape ? 18 : 24 }) {
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
    .margin({ top: 18 })
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
    .width('100%')
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
    Column({ space: 9 }) {
      Stack() {
        ClockWidgetView({
          config: item,
          widgetSize: this.selectedSize
        })
      }
      .id(this.getPreviewComponentId(item.id))
      .alignContent(Alignment.BottomEnd)
      .width(this.getPreviewWidth())
      .aspectRatio(getClockWidgetSizeAspectRatio(this.selectedSize))
      .border({
        width: 2,
        color: this.isSelected(item) ? Color.Green : Color.Transparent,
        radius: 18
      })
      .clip(true)
      .shadow({
        radius: 10,
        color: '#20000000',
        offsetY: 4
      })
      .onClick(() => {
        this.selectWidget(item)
      })
      .bindContextMenu(this.isAddFormMenuShown && this.isSelected(item), this.SelectedAddFormMenu, {
        placement: Placement.Bottom,
        aboutToDisappear: () => {
          this.isAddFormMenuShown = false
        }
      })
      .gesture(
        LongPressGesture()
          .onAction(() => {
            this.showAddFormMenu(item.id)
          })
      )

      Column({ space: 3 }) {
        Row() {
          Text(item.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.flip_text_color'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (this.isDefault(item)) {
            Text('默认')
              .fontSize(11)
              .fontColor($r('app.color.blue'))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
              .backgroundColor('#22347FF1')
              .margin({ left: 6 })
          }
        }
        .width(this.getPreviewWidth())

        Text(item.subtitle)
          .fontSize(12)
          .fontColor($r('app.color.flip_text_color'))
          .opacity(0.5)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width(this.getPreviewWidth())
      .alignItems(HorizontalAlign.Start)

      Row({ space: 8 }) {
        Button('添加')
          .type(ButtonType.Normal)
          .height(32)
          .layoutWeight(1)
          .fontSize(13)
          .fontColor(Color.White)
          .borderRadius(10)
          .backgroundColor($r('app.color.blue'))
          .onClick(() => {
            this.showAddFormMenu(item.id)
          })

        Button('默认')
          .type(ButtonType.Normal)
          .height(32)
          .layoutWeight(1)
          .fontSize(13)
          .fontColor($r('app.color.flip_text_color'))
          .borderRadius(10)
          .backgroundColor($r('app.color.flip_card_bg_color'))
          .onClick(() => {
            this.selectWidget(item)
            this.setDefaultWidget(item.id)
          })
      }
      .width(this.getPreviewWidth())
    }
    .width('100%')
    .alignItems(this.selectedSize == ClockWidgetSize.Size2x2 ? HorizontalAlign.Start : HorizontalAlign.Center)
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
      return '1fr 1fr 1fr'
    }
    if (this.selectedSize == ClockWidgetSize.Size4x4) {
      return '1fr 1fr'
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
    return this.isLandscape ? 16 : 20
  }
}
