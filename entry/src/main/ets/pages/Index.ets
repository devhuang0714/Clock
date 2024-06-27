import { ConfigurationConstant } from '@kit.AbilityKit';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import mediaquery from '@ohos.mediaquery';
import { Icons } from '../common/constants/Constants';
import { Toast } from 'utils/Index';
import { ClockController } from '../views/Clocks/ClockController'
import { RoundClock } from '../views/Clocks/RoundClock';
import { FlipClock } from '../views/Clocks/FlipClock';
import { DigitalClock } from '../views/Clocks/DigitalClock';

@Entry
@Component
struct Index {
  // 当设备横屏时条件成立
  listener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('(orientation: landscape)');
  @StorageProp('currentColorMode') @Watch('onColorModeChange') currentMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
  @State isDark: boolean = false // 是否暗黑模式
  @State isLandscape: boolean = false // 当前是否横屏
  @State isClean: boolean = false // 清屏
  private date: Date = new Date()
  private clockController: ClockController = new ClockController()
  private fontSize: number = 130
  private space: number = 4
  private intervalId: number = 0;

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

  aboutToDisappear(): void {
    clearInterval(this.intervalId)
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
        Tabs() {
          TabContent() {
            DigitalClock({
              controller: this.clockController,
              date: this.date
            })
          }

          TabContent() {
            FlipClock({
              controller: this.clockController,
              date: this.date,
              isLandscape: this.isLandscape
            })
          }

          TabContent() {
            RoundClock({
              controller: this.clockController,
              date: this.date
            })
          }
        }
        .height('100%')
        .height('100%')
        .barHeight(0)
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

      Text(this.isLandscape ? 'Landscape' : 'Portrait')
        .textAlign(TextAlign.Center)
        .width('100%')
        .fontSize(30)
        .opacity(this.isClean ? 0 : 1)
        .onClick(() => {
          this.changeOrientation(!this.isLandscape);
        })
        .alignRules({
          top: { anchor: "__container__", align: VerticalAlign.Top },
          left: { anchor: "__container__", align: HorizontalAlign.Start }
        })
        .id("text")

      this.BottomTools()
    }
    .height('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
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
    .opacity(this.isClean ? 0 : 1)
    .backgroundColor(Color.Transparent)
    .alignRules({
      left: { anchor: "__container__", align: HorizontalAlign.Start },
      right: { anchor: "__container__", align: HorizontalAlign.End },
      bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
    })
    .id("tools")
  }
}