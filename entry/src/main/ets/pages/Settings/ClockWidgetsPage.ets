import { Want } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { AddFormMenuItem, ColorMetrics, LengthMetrics, SegmentButtonV2Items, TabSegmentButtonV2 } from '@kit.ArkUI'
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
import Icon from '../../common/icons/Icon'

interface ClockWidgetGroup {
  title: string
  types: ClockWidgetStyleType[]
}

@Entry
@Component
struct ClockWidgetsPage {
  @State selectedSize: ClockWidgetSize = ClockWidgetSize.Size2x2
  @State selectedSizeTabIndex: number = 0
  @State selectedWidgetId: string = DEFAULT_CLOCK_WIDGET_ID
  @State defaultWidgetId: string = DEFAULT_CLOCK_WIDGET_ID
  @State isAddFormMenuShown: boolean = false
  @State pageWidth: number = 0
  @StorageProp('isLandscape') isLandscape: boolean = false

  private readonly formName: string = 'clock_widget'
  private readonly moduleName: string = 'entry'
  private readonly formAbilityName: string = 'ClockWidgetAbility'
  private readonly previewComponentIdPrefix: string = 'clock_widget_preview_'
  private readonly landscapeSideWidth: number = 156
  private readonly landscapeContentGap: number = 14
  private readonly landscapeLeftPadding: number = 4
  private readonly landscapeRightPadding: number = 18
  private readonly landscapeWideWidgetMinWidth: number = 360
  private readonly tabAnimationDuration: number = 260
  private readonly sizeTabItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { text: '2x2' },
    { text: '2x4' },
    { text: '4x4' }
  ])
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
    this.selectedSizeTabIndex = this.getSelectedSizeIndex()
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

  private selectSizeIndex(index: number): void {
    const widgetSize = CLOCK_WIDGET_SIZES[index]
    if (widgetSize == undefined || this.selectedSizeTabIndex == index) {
      return
    }

    animateTo({ duration: this.tabAnimationDuration, curve: Curve.EaseInOut }, () => {
      this.selectedSizeTabIndex = index
      this.selectSize(widgetSize)
    })
  }

  private getSelectedSizeIndex(): number {
    const index = CLOCK_WIDGET_SIZES.indexOf(this.selectedSize)
    return index >= 0 ? index : 0
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
        Row({ space: this.landscapeContentGap }) {
          Column({ space: 14 }) {
            this.Header()
            this.LeftSizeTabs()
          }
          .width(this.landscapeSideWidth)
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
      left: this.isLandscape ? this.landscapeLeftPadding : 24,
      right: this.isLandscape ? this.landscapeRightPadding : 24
    })
    .onAreaChange((oldArea: Area, newArea: Area) => {
      this.pageWidth = Number(newArea.width)
    })
  }

  @Builder
  Header() {
    Column({ space: 8 }) {
      Row() {
        Button() {
          Icon({
            name: Icons.CLOSE,
            iconSize: 30,
            color: $r('app.color.flip_text_color')
          })
        }
        .type(ButtonType.Normal)
        .width(44)
        .height(44)
        .backgroundColor(Color.Transparent)
        .padding(0)
        .margin({ left: this.isLandscape ? -4 : -16 })
        .onClick(() => {
          router.back()
        })
      }
      .width('100%')
      .height(44)
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
              if (formId.length > 0) {
                ClockWidgetConfigManager.addFormId(getContext(this), formId)
                ClockWidgetConfigManager.saveFormDimension(getContext(this), formId, this.getSelectedDimension())
                ClockWidgetConfigManager.saveFormWidgetId(getContext(this), formId, this.selectedWidgetId)
              }
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
    Row() {
      this.SizeSegmentButton()
    }
      .width('100%')
      .margin({ top: 18 })
  }

  @Builder
  LeftSizeTabs() {
    Row() {
      this.SizeSegmentButton()
    }
    .width(148)
  }

  @Builder
  SizeSegmentButton() {
    Row() {
      TabSegmentButtonV2({
        items: this.sizeTabItems,
        selectedIndex: this.selectedSizeTabIndex,
        $selectedIndex: (index: number) => {
          this.selectSizeIndex(index)
        },
        onItemClicked: (index: number) => {
          this.selectSizeIndex(index)
        },
        buttonBackgroundColor: ColorMetrics.resourceColor($r('app.color.flip_card_bg_color')),
        buttonBorderRadius: LengthMetrics.vp(this.isLandscape ? 13 : 14),
        buttonMinHeight: LengthMetrics.vp(this.isLandscape ? 38 : 42),
        buttonPadding: LengthMetrics.vp(3),
        itemBorderRadius: LengthMetrics.vp(11),
        itemMinHeight: LengthMetrics.vp(this.isLandscape ? 32 : 36),
        itemFontSize: LengthMetrics.fp(this.isLandscape ? 13 : 15),
        itemSelectedFontSize: LengthMetrics.fp(this.isLandscape ? 13 : 15),
        itemFontColor: ColorMetrics.resourceColor($r('app.color.flip_text_color')),
        itemSelectedFontColor: ColorMetrics.resourceColor($r('app.color.flip_text_color')),
        itemFontWeight: FontWeight.Medium,
        itemSelectedFontWeight: FontWeight.Bold,
        itemSelectedBackgroundColor: ColorMetrics.resourceColor($r('app.color.main_background_color')),
        itemShadow: {
          radius: 0,
          color: Color.Transparent
        }
      })
    }
    .width('100%')
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
      .animation({
        duration: this.tabAnimationDuration,
        curve: Curve.EaseInOut
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
              .fontColor(Color.Green)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
              .backgroundColor('#2200FF00')
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
          .backgroundColor(Color.Green)
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
    .animation({
      duration: this.tabAnimationDuration,
      curve: Curve.EaseInOut
    })
  }

  private getPreviewWidth(): Length {
    if (this.selectedSize == ClockWidgetSize.Size2x2) {
      return '100%'
    }
    if (this.isLandscape) {
      if (this.selectedSize == ClockWidgetSize.Size4x4) {
        return 300
      }
      return this.landscapeWideWidgetMinWidth
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
      return '1fr'
    }
    return this.canUseTwoWideColumns() ? '1fr 1fr' : '1fr'
  }

  private getLandscapeListWidth(): number {
    if (this.pageWidth <= 0) {
      return 0
    }
    return this.pageWidth - this.landscapeLeftPadding - this.landscapeRightPadding -
      this.landscapeSideWidth - this.landscapeContentGap
  }

  private canUseTwoWideColumns(): boolean {
    return this.getLandscapeListWidth() >= this.landscapeWideWidgetMinWidth * 2 + this.getGridColumnsGap()
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
