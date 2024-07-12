import { ConfigurationConstant } from '@kit.AbilityKit';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import mediaQuery from '@ohos.mediaquery';
import router from '@ohos.router';
import { AppConstants, Icons } from '../common/constants/Constants';
import { ClockController } from '../views/Clocks/ClockController'
import { RoundClock } from '../views/Clocks/RoundClock';
import { FlipClock } from '../views/Clocks/FlipClock';
import { DigitalClock } from '../views/Clocks/DigitalClock';
import { LunarCalendarClock } from '../views/Clocks/LunarCalendarClock'
import { RotateClock } from '../views/Clocks/RotateClock'
import { ClockStyleDialog } from '../views/Clocks/ClockStyleDialog'
import { ClockConfig, ClockType, CLOCK_CONFIGS, DEFAULT_GLOBAL_CONFIG,
  GlobalClockConfig } from '../views/Clocks/ClockConfig'
import { NormalDigitalClock } from '../views/Clocks/NormalDigitalClock';

// 持久化存储UI状态
PersistentStorage.persistProp('defaultClockConfig', CLOCK_CONFIGS[0])
PersistentStorage.persistProp('globalClockConfig', DEFAULT_GLOBAL_CONFIG)

@Entry
@Component
struct Index {
  // 当设备横屏时条件成立
  listener: mediaQuery.MediaQueryListener = mediaQuery.matchMediaSync('(orientation: landscape)');
  @StorageProp('currentColorMode') @Watch('onColorModeChange') currentMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
  @State isDark: boolean = false // 是否暗黑模式
  @State isLandscape: boolean = false // 当前是否横屏
  @Watch('onCleanChange') @State isClean: boolean = false // 清屏
  @State isPresentSetting: boolean = false
  @State selectedTabIndex: number = 0
  @StorageLink('defaultClockConfig') clockConfig: ClockConfig = CLOCK_CONFIGS[0]
  @StorageLink('globalClockConfig') globalConfig: GlobalClockConfig = DEFAULT_GLOBAL_CONFIG
  private date: Date = new Date()
  private clockController: ClockController = new ClockController()
  private intervalId: number = 0;
  private cleanTimeoutId: number = 0;
  private clockStyleDialog: CustomDialogController = new CustomDialogController({
    builder: ClockStyleDialog({
      selectedConfig: this.clockConfig,
      onSelected: (config) => {
        this.clockConfig = config
      }
    }),
    customStyle: true,
    maskColor: Color.Transparent,
    openAnimation: {
      duration: 0
    },
    closeAnimation: {
      duration: 0
    },
    offset: {
      dx: 0,
      dy: AppConstants.DEFAULT_NAV_HEIGHT
    },
  })

  aboutToAppear(): void {
    // 绑定横竖屏切换回调函数
    this.listener.on('change', (mediaQueryResult: mediaQuery.MediaQueryResult) => {
      console.log(`mediaQueryResult: ${mediaQueryResult.matches as boolean}`)
      this.isLandscape = mediaQueryResult.matches as boolean
      AppStorage.setOrCreate('isLandscape', this.isLandscape)
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
    if (this.cleanTimeoutId != 0) {
      clearTimeout(this.cleanTimeoutId)
    }
    if (!this.isClean) {
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
        this.ClockView()
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.clockConfig.colors.backgroundColor)
      .alignRules({
        top: { anchor: "__container__", align: VerticalAlign.Top },
        left: { anchor: "__container__", align: HorizontalAlign.Start },
        right: { anchor: "__container__", align: HorizontalAlign.End },
        bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
      })
      .id("clock")

      this.TopTools()
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
  ClockView() {
    if (this.clockConfig.type == ClockType.Flip) {
      FlipClock({
        controller: this.clockController,
        date: this.date,
        colorsConfig: this.clockConfig.colors,
        globalConfig: this.globalConfig,
        isLandscape: this.isLandscape
      })
    } else if (this.clockConfig.type == ClockType.Round) {
      RoundClock({
        controller: this.clockController,
        date: this.date
      })
    } else if (this.clockConfig.type == ClockType.Digital) {
      DigitalClock({
        controller: this.clockController,
        date: this.date,
        colorsConfig: this.clockConfig.colors,
        globalConfig: this.globalConfig,
      })
    } else if (this.clockConfig.type == ClockType.Rotate) {
      RotateClock({
        controller: this.clockController,
        date: this.date,
        style: this.clockConfig.style,
        colorsConfig: this.clockConfig.colors,
        globalConfig: this.globalConfig,
        lightOn: this.clockConfig.ext.lightOn,
        isLandscape: this.isLandscape,
      })
    } else if (this.clockConfig.type == ClockType.LunarCalendar) {
      LunarCalendarClock({
        controller: this.clockController,
        date: this.date,
        style: this.clockConfig.style,
        colorsConfig: this.clockConfig.colors,
        globalConfig: this.globalConfig,
        isLandscape: this.isLandscape,
      })
    } else if (this.clockConfig.type == ClockType.NormalDigital) {
      NormalDigitalClock({
        controller: this.clockController,
        date: this.date,
        colorsConfig: this.clockConfig.colors,
        globalConfig: this.globalConfig,
      })
    }
  }

  @Builder
  TopTools() {
    Row() {
      ToolItem({
        unicode: this.isDark ? Icons.THEME_LIGHT : Icons.THEME_DARK,
        fontSize: this.isDark ? 28 : 32
      })
        .onClick(() => {
          let mode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK
          if (this.isDark) {
            mode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
          }
          getContext().getApplicationContext().setColorMode(mode);
        })

      Blank()
        .layoutWeight(1)

      ToolItem({
        unicode: Icons.SETTINGS,
        fontSize: 32
      })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/Settings/SettingPage'
          })
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .visibility(this.isClean ? Visibility.Hidden : Visibility.Visible)
    .alignRules({
      top: { anchor: "__container__", align: VerticalAlign.Top },
      left: { anchor: "__container__", align: HorizontalAlign.Start }
    })
    .offset({
      y: AppConstants.DEFAULT_STATUS_HEIGHT
    })
    .padding({ left: 24, right: 24 })
    .id('previews')
  }

  @Builder
  BottomTools() {
    Row({ space: 24 }) {
      ToolItem({
        unicode: Icons.SCREEN_ORIENTATION,
        fontSize: 28
      })
        .onClick(() => {
          this.changeOrientation(!this.isLandscape)
        })

      Blank()
        .layoutWeight(1)

      ToolItem({
        unicode: Icons.THEME_FILL_ICON,
        fontSize: 32
      })
        .onClick(() => {
          this.clockStyleDialog.open()
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

@Component
struct ToolItem {
  @Prop unicode: string = Icons.SETTINGS
  @Prop fontSize: number = 28

  build() {
    Button() {
      Text(this.unicode)
        .fontFamily(Icons.FONT_FAMILY)
        .fontSize(this.fontSize)
        .fontColor($r('app.color.tool_item_color'))
    }
    .backgroundColor($r('app.color.tool_item_bg_color'))
    .width(54)
    .height(54)
    .borderRadius(27)
  }
}