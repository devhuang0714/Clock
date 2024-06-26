import { FlipCard, FlipCardController } from '../views/FlipCard'
import { ConfigurationConstant } from '@kit.AbilityKit';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import mediaquery from '@ohos.mediaquery';
import { Icons } from '../common/constants/Constants';
import { Toast } from 'utils/Index';
import { RoundClock } from '../views/RoundClock'

@Entry
@Component
struct Index {
  // 当设备横屏时条件成立
  listener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('(orientation: landscape)');
  @StorageProp('currentColorMode') @Watch('onColorModeChange') currentMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
  @State isDark: boolean = false // 是否暗黑模式
  @State isLandscape: boolean = false // 当前是否横屏
  @State isClean: boolean = false // 清屏
  @State hours: string = ''
  @State minutes: string = ''
  @State seconds: string = ''
  private hourController: FlipCardController = new FlipCardController()
  private minuteController: FlipCardController = new FlipCardController()
  private secondController: FlipCardController = new FlipCardController()
  fontSize: number = 130
  space: number = 4

  aboutToAppear(): void {
    // 绑定横竖屏切换回调函数
    this.listener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      console.log(`mediaQueryResult: ${mediaQueryResult.matches as boolean}`)
      this.isLandscape = mediaQueryResult.matches as boolean
    })
    this.isDark = this.currentMode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK

    this.updateTimes()
    this.startClock()
  }

  onColorModeChange(): void {
    this.isDark = this.currentMode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK
  }

  // 改变设备横竖屏状态函数
  private changeOrientation(isLandscape: boolean) {
    // 获取UIAbility实例的上下文信息
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    // 调用该接口手动改变设备横竖屏状态
    window.getLastWindow(context).then((lastWindow) => {
      lastWindow.setPreferredOrientation(isLandscape ? window.Orientation.LANDSCAPE : window.Orientation.PORTRAIT)
    });
  }

  startClock() {
    setInterval(() => {
      this.updateTimes()
    }, 1000);
  }

  updateTimes() {
    const date = new Date()
    this.hours = date.getHours().toString().padStart(2, '0')
    this.minutes = date.getMinutes().toString().padStart(2, '0')
    this.seconds = date.getSeconds().toString().padStart(2, '0')

    this.hourController.change(this.hours)
    this.minuteController.change(this.minutes)
    this.secondController.change(this.seconds)
  }

  build() {
    Stack() {
      Column() {
        // if (this.isLandscape) {
        //   this.LandscapeLayout()
        // } else {
        //   this.PortraitLayout()
        // }
        RoundClock()
      }
      .height('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.main_background_color'))

      Column() {
        Text(this.isLandscape ? 'Landscape' : 'Portrait')
          .fontSize(30)
          .onClick(() => {
            this.changeOrientation(!this.isLandscape);
          })

        Blank()
          .layoutWeight(1)

        this.BottomTools()
      }
      .height('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.Transparent)
      .opacity(this.isClean ? 0 : 1)
      .onClick(() => {
        this.isClean = !this.isClean
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  PortraitLayout() {
    Column({ space: 24 }) {
      this.FlipCards()
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  LandscapeLayout() {
    Row({ space: 24 }) {
      this.FlipCards()
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  FlipCards() {
    FlipCard({
      fontSize: this.fontSize,
      space: this.space,
      current: this.hours,
      controller: this.hourController
    })

    FlipCard({
      fontSize: this.fontSize,
      space: this.space,
      current: this.minutes,
      controller: this.minuteController
    })

    FlipCard({
      fontSize: this.fontSize,
      space: this.space,
      current: this.seconds,
      next: this.seconds,
      controller: this.secondController
    })
  }

  @Builder
  BottomTools() {
    Row() {
      Text(this.isDark ? Icons.THEME_LIGHT : Icons.THEME_DARK)
        .fontSize(40)
        .fontFamily(Icons.FONT_FAMILY)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          if (this.isDark) {
            getContext().getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
          } else {
            getContext().getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
          }
        })

      Blank()
        .layoutWeight(1)

      Text(Icons.SETTINGS)
        .fontSize(40)
        .fontFamily(Icons.FONT_FAMILY)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          Toast.show('setting action')
        })
    }
    .padding({ left: 24, right: 24, bottom: 36 })
  }
}