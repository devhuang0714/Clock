import { ConfigurationConstant } from '@kit.AbilityKit';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import mediaquery from '@ohos.mediaquery';
import { AppConstants, Icons } from '../common/constants/Constants';
import { ClockController } from '../views/Clocks/ClockController'
import { RoundClock } from '../views/Clocks/RoundClock';
import { FlipClock } from '../views/Clocks/FlipClock';
import { DigitalClock } from '../views/Clocks/DigitalClock';
import { LunarCalendarClock, LunarCalendarClockType } from '../views/Clocks/LunarCalendarClock'
import { RotateClock, RotateClockType } from '../views/Clocks/RotateClock'
import { ClockStyleDialog } from '../views/Clocks/ClockStyleDialog'
import router from '@ohos.router';

interface ClockItem {
  previewIcon: Resource,
  type: string
}

@Entry
@Component
struct Index {
  // 当设备横屏时条件成立
  listener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('(orientation: landscape)');
  @StorageProp('currentColorMode') @Watch('onColorModeChange') currentMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
  @State isDark: boolean = false // 是否暗黑模式
  @State isLandscape: boolean = false // 当前是否横屏
  @Watch('onCleanChange') @State isClean: boolean = false // 清屏
  @State isPresentSetting: boolean = false
  @State selectedTabIndex: number = 0
  private clockItems: ClockItem[] = []
  private date: Date = new Date()
  private clockController: ClockController = new ClockController()
  private tabsController: TabsController = new TabsController()
  private intervalId: number = 0;
  private cleanTimeoutId: number = 0;
  private clockStyleDialog: CustomDialogController = new CustomDialogController({
    builder: ClockStyleDialog(),
    customStyle: true,
    offset: {
      dx: 0,
      dy: 0
    },
    openAnimation: {
      duration: 0
    },
    closeAnimation: {
      duration: 0
    }
  })

  aboutToAppear(): void {
    this.clockItems = [
      {
        previewIcon: $r('app.media.rotate_clock'),
        type: 'lunarCalendarClock_style2'
      },
      {
        previewIcon: $r('app.media.rotate_clock'),
        type: 'lunarCalendarClock'
      },
      {
        previewIcon: $r('app.media.rotate_clock'),
        type: 'rotateClock'
      },
      {
        previewIcon: $r('app.media.rotate_clock'),
        type: 'rotateClock_style2'
      },
      {
        previewIcon: $r('app.media.rotate_clock'),
        type: 'rotateClock_style3'
      },
      {
        previewIcon: $r('app.media.flip_clock'),
        type: 'flipClock'
      },
      {
        previewIcon: $r('app.media.round_clock'),
        type: 'roundClock'
      },
      {
        previewIcon: $r('app.media.digital_clock'),
        type: 'digitalClock'
      },
    ]

    // 绑定横竖屏切换回调函数
    this.listener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      console.log(`mediaQueryResult: ${mediaQueryResult.matches as boolean}`)
      this.isLandscape = mediaQueryResult.matches as boolean
    })
    this.isDark = this.currentMode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK

    this.updateTimes()
    this.startClock()
    this.onCleanChange()
  }

  aboutToDisappear(): void {
    clearInterval(this.intervalId)
    clearTimeout(this.cleanTimeoutId)
  }

  onPageShow(): void {
    this.onCleanChange()
  }

  onPageHide(): void {
    clearTimeout(this.cleanTimeoutId)
  }

  pageTransition() {
    PageTransitionEnter({ duration: 0 })
    PageTransitionExit({ duration: 1000 })
  }

  onCleanChange() {
    if (!this.isClean) {
      clearTimeout(this.cleanTimeoutId)
      this.cleanTimeoutId = setTimeout(() => {
        this.isClean = true
      }, 8000)
    }
  }

  onColorModeChange(): void {
    this.isDark = this.currentMode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK
  }

  // 改变设备横竖屏状态函数
  changeOrientation(isLandscape: boolean) {
    // 获取UIAbility实例的上下文信息
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    // 调用该接口手动改变设备横竖屏状态
    window.getLastWindow(context).then((lastWindow) => {
      lastWindow.setPreferredOrientation(isLandscape ? window.Orientation.LANDSCAPE : window.Orientation.PORTRAIT)
    });
  }

  startClock() {
    this.intervalId = setInterval(() => {
      this.updateTimes()
    }, 1000);
  }

  updateTimes() {
    this.date = new Date()
    this.clockController.update(this.date)
  }

  build() {
    RelativeContainer() {
      Column() {
        Tabs({ controller: this.tabsController }) {
          ForEach(this.clockItems, (item: ClockItem) => {
            TabContent() {
              if (item.type == 'flipClock') {
                FlipClock({
                  controller: this.clockController,
                  date: this.date,
                  isLandscape: this.isLandscape
                })
              } else if (item.type == 'roundClock') {
                RoundClock({
                  controller: this.clockController,
                  date: this.date
                })
              } else if (item.type == 'digitalClock') {
                DigitalClock({
                  controller: this.clockController,
                  date: this.date
                })
              } else if (item.type == 'rotateClock') {
                RotateClock({
                  controller: this.clockController,
                  date: this.date,
                  isLandscape: this.isLandscape,
                  lightOn: true
                })
              } else if (item.type == 'rotateClock_style2') {
                RotateClock({
                  controller: this.clockController,
                  date: this.date,
                  isLandscape: this.isLandscape,
                  type: RotateClockType.Style2,
                  lightOn: true
                })
              } else if (item.type == 'rotateClock_style3') {
                RotateClock({
                  controller: this.clockController,
                  date: this.date,
                  isLandscape: this.isLandscape,
                  type: RotateClockType.Style3
                })
              } else if (item.type == 'lunarCalendarClock') {
                LunarCalendarClock({
                  controller: this.clockController,
                  date: this.date,
                  isLandscape: this.isLandscape
                })
              } else if (item.type == 'lunarCalendarClock_style2') {
                LunarCalendarClock({
                  controller: this.clockController,
                  date: this.date,
                  isLandscape: this.isLandscape,
                  type: LunarCalendarClockType.Style2
                })
              }
            }
          })
        }
        .width('100%')
        .height('100%')
        .barHeight(0)
        .animationDuration(0)
        .onChange((index) => {
          this.selectedTabIndex = index
        })
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.main_background_color'))
      .alignRules({
        top: { anchor: "__container__", align: VerticalAlign.Top },
        left: { anchor: "__container__", align: HorizontalAlign.Start },
        right: { anchor: "__container__", align: HorizontalAlign.End },
        bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
      })
      .id("clock")

      this.TopPreviews()

      this.BottomTools()
    }
    .height('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      this.isClean = !this.isClean
    })
    .onAppear(() => {
      this.changeOrientation(true)
    })
  }

  @Builder
  TopPreviews() {
    Row() {
      Text(Icons.THEME_FILL_ICON)
        .fontFamily(Icons.FONT_FAMILY)
        .fontSize(36)
        .onClick(() => {
          // router.pushUrl({
          //   url: 'pages/Settings/ClockStyle'
          // })
          this.clockStyleDialog.open()
        })

      Grid() {
        ForEach(this.clockItems, (item: ClockItem, index: number) => {
          GridItem() {
            Image(item.previewIcon)
              .size({ width: 60, height: 60 })
              .border({
                width: 2,
                color: this.selectedTabIndex == index ? $r('app.color.flip_text_color') : Color.Transparent,
                radius: 12
              })
          }
          .onClick(() => {
            this.tabsController.changeIndex(index)
          })
        })
      }
      .backgroundColor($r('app.color.flip_card_bg_color'))
      .padding(12)
      .margin({ left: 24, right: 24 })
      .borderRadius(12)
      .columnsGap(12)
      .rowsGap(12)
      .maxCount(this.clockItems.length)

      // .rowsTemplate('1fr')
      // .scrollBar(BarState.Off)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .visibility(this.isClean ? Visibility.Hidden : Visibility.Visible)
    .alignRules({
      top: { anchor: "__container__", align: VerticalAlign.Top },
      left: { anchor: "__container__", align: HorizontalAlign.Start }
    })
    .offset({
      y: AppConstants.DEFAULT_STATUS_HEIGHT
    })
    .id('previews')
  }

  @Builder
  BottomTools() {
    Row({ space: 24 }) {
      Text(this.isDark ? Icons.THEME_LIGHT : Icons.THEME_DARK)
        .fontSize(36)
        .fontFamily(Icons.FONT_FAMILY)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          let mode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK
          if (this.isDark) {
            mode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
          }
          getContext().getApplicationContext().setColorMode(mode);
        })

      Text(Icons.SCREEN_ORIENTATION)
        .fontSize(36)
        .fontFamily(Icons.FONT_FAMILY)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.changeOrientation(!this.isLandscape)
        })

      Blank()
        .layoutWeight(1)

      Text(Icons.SETTINGS)
        .fontSize(36)
        .fontFamily(Icons.FONT_FAMILY)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/Settings/SettingPage'
          })
        })
    }
    .padding({ left: 24, right: 24, bottom: 36 })
    .visibility(this.isClean ? Visibility.Hidden : Visibility.Visible)
    .backgroundColor(Color.Transparent)
    .alignRules({
      left: { anchor: "__container__", align: HorizontalAlign.Start },
      right: { anchor: "__container__", align: HorizontalAlign.End },
      bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
    })
    .id("tools")
  }
}