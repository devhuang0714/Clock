import { AppConstants, Icons } from '../../common/constants/Constants'
import router from '@ohos.router';
import mediaQuery from '@ohos.mediaquery';
import { ClockConfig, ClockThemeGroupItems, CLOCK_CONFIGS, getClockThemeGroupItems } from '../../views/Clocks/ClockConfig';
import {
  ClockPreviewCanvas,
  getCurrentPreviewCanvasHeight,
  getCurrentPreviewCanvasWidth,
  getCurrentPreviewItemHeight,
  getCurrentPreviewItemWidth,
  getCurrentPreviewScale,
  isCurrentPreviewLandscape
} from '../../views/Clocks/ClockPreviewCanvas';
import { NavigationBar } from '../../views/NavigationBar';

@Entry
@Component
struct ClockThemesPage {
  listener: mediaQuery.MediaQueryListener = mediaQuery.matchMediaSync('(orientation: landscape)');
  @State themeGroups: ClockThemeGroupItems[] = getClockThemeGroupItems()
  @State selectedConfig: ClockConfig = CLOCK_CONFIGS[0]
  @StorageLink('isLandscape') isLandscape: boolean = false
  private previewDate: Date = new Date('2022-09-22 00:22:00')
  private isListeningOrientation: boolean = false

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 300 })
      .slide(SlideEffect.Bottom)
    PageTransitionExit({ type: RouteType.Pop, duration: 300 })
      .slide(SlideEffect.Bottom)

    PageTransitionEnter({ type: RouteType.Pop, duration: 0 })
    PageTransitionExit({ type: RouteType.Push, duration: 1000 })
  }

  aboutToAppear(): void {
    let config = AppStorage.get<ClockConfig>('defaultClockConfig')
    if (config != undefined) {
      this.selectedConfig = config
    }
    this.syncPreviewOrientation(isCurrentPreviewLandscape())
    if (!this.isListeningOrientation) {
      this.listener.on('change', (mediaQueryResult: mediaQuery.MediaQueryResult) => {
        this.syncPreviewOrientation(mediaQueryResult.matches as boolean)
      })
      this.isListeningOrientation = true
    }
  }

  syncPreviewOrientation(isLandscape: boolean) {
    this.isLandscape = isLandscape
    AppStorage.setOrCreate('isLandscape', isLandscape)
  }

  saveAndBack() {
    AppStorage.setOrCreate('defaultClockConfig', this.selectedConfig)
    router.back({
      url: 'pages/Index'
    })
  }

  isSelected(item: ClockConfig): boolean {
    return this.selectedConfig.id == item.id
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

  getGridColumnsTemplate(): string {
    return `repeat(auto-fill, ${this.getClockStyleItemWidth()})`
  }

  build() {
    Column() {
      NavigationBar({
        backIcon: Icons.CLOSE,
        title: '',
        largeBackIcon: true,
        onBack: () => {
          router.back()
        },
        builder: (): void => {
          this.DoneButton()
        }
      })

      List({ space: 18 }) {
        ForEach(this.themeGroups, (group: ClockThemeGroupItems) => {
          ListItem() {
            Column({ space: 10 }) {
              Text(group.title)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.flip_text_color'))
                .width('100%')

              Grid() {
                ForEach(group.items, (item: ClockConfig) => {
                  this.ThemeGridItem(item)
                }, (item: ClockConfig) => item.id)
              }
              .rowsGap(12)
              .columnsGap(24)
              .columnsTemplate(this.getGridColumnsTemplate())
              .scrollBar(BarState.Off)
            }
            .width('100%')
          }
        })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .padding({ left: 24, right: 24, top: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
    .padding({
      bottom: AppConstants.DEFAULT_NAV_HEIGHT
    })
  }

  @Builder
  DoneButton() {
    Button() {
      Text('完成')
        .fontSize(18)
        .fontColor($r('app.color.flip_text_color'))
    }
    .type(ButtonType.Normal)
    .padding(8)
    .backgroundColor(Color.Transparent)
    .margin({ right: 12 })
    .onClick(() => {
      this.saveAndBack()
    })
  }

  @Builder
  ThemeGridItem(item: ClockConfig) {
    GridItem() {
      Stack() {
        this.PreviewClockView(item)

        if (this.isSelected(item)) {
          Text(Icons.CHECKED)
            .fontFamily(Icons.FONT_FAMILY)
            .fontSize(24)
            .fontColor(Color.Green)
        }
      }
      .alignContent(Alignment.BottomEnd)
    }
    .height(this.getClockStyleItemHeight())
    .width(this.getClockStyleItemWidth())
    .border({
      width: 2,
      color: this.isSelected(item) ? Color.Green : $r('app.color.flip_card_bg_color'),
      radius: 8
    })
    .clip(true)
    .onClick(() => {
      this.selectedConfig = item
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
