import { AppConstants, Icons } from '../../common/constants/Constants'
import router from '@ohos.router';
import { ClockConfig, ClockType, CLOCK_CONFIGS } from '../../views/Clocks/ClockConfig';
import { FlipClock } from '../../views/Clocks/FlipClock';
import { RoundClock } from '../../views/Clocks/RoundClock';
import { DigitalClock } from '../../views/Clocks/DigitalClock';
import { RotateClock } from '../../views/Clocks/RotateClock';
import { LunarCalendarClock } from '../../views/Clocks/LunarCalendarClock';
import { NormalDigitalClock } from '../../views/Clocks/NormalDigitalClock';
import { StereoscopicClock } from '../../views/Clocks/StereoscopicClock';

@Entry
@Component
struct ClockTheme {
  @State clockItems: ClockConfig[] = CLOCK_CONFIGS
  @State selectedConfig: ClockConfig = CLOCK_CONFIGS[0]
  @StorageProp('isLandscape') isLandscape: boolean = false
  private previewDate: Date = new Date('2022-09-22 09:22:00')

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
  }

  isSelected(item: ClockConfig): boolean {
    return this.selectedConfig.id == item.id
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
            AppStorage.setOrCreate('defaultClockConfig', this.selectedConfig)
            router.back({
              url: 'pages/Index'
            })
          })
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.End)
      .margin({ top: 12, bottom: 12 })

      Grid() {
        ForEach(this.clockItems, (item: ClockConfig) => {
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
          .height(60)
          .width(60 * 1150 / 534)
          .border({
            width: 2,
            color: this.isSelected(item) ? Color.Green : $r('app.color.flip_card_bg_color'),
            radius: 8
          })
          .clip(true)
          .onClick(() => {
            this.selectedConfig = item
          })
        })
      }
      .rowsGap(12)
      .columnsGap(24)
      .columnsTemplate(this.isLandscape ? '1fr 1fr 1fr 1fr 1fr' : '1fr 1fr')
      .scrollBar(BarState.Off)
      .layoutWeight(1)

      Button() {
        Text(Icons.PACK_UP)
          .fontFamily(Icons.FONT_FAMILY)
          .fontSize(28)
          .fontColor($r('app.color.flip_text_color'))
      }
      .type(ButtonType.Normal)
      .padding(8)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        router.back()
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
    .padding({
      bottom: AppConstants.DEFAULT_NAV_HEIGHT,
      left: 24,
      right: 24
    })
  }

  @Builder
  PreviewClockView(clockConfig: ClockConfig) {
    RelativeContainer() {
      Column() {
        if (clockConfig.type == ClockType.Flip) {
          FlipClock({
            date: this.previewDate,
            colorsConfig: clockConfig.colors,
            isLandscape: true
          })
        } else if (clockConfig.type == ClockType.Round) {
          RoundClock({
            date: this.previewDate
          })
        } else if (clockConfig.type == ClockType.Digital) {
          DigitalClock({
            date: this.previewDate,
            colorsConfig: clockConfig.colors,
          })
        } else if (clockConfig.type == ClockType.Rotate) {
          RotateClock({
            date: this.previewDate,
            style: clockConfig.style,
            colorsConfig: clockConfig.colors,
            lightOn: clockConfig.ext?.lightOn ?? false,
            isLandscape: true,
          })
        } else if (clockConfig.type == ClockType.LunarCalendar) {
          LunarCalendarClock({
            date: this.previewDate,
            style: clockConfig.style,
            colorsConfig: clockConfig.colors,
            isLandscape: true,
          })
        } else if (clockConfig.type == ClockType.NormalDigital) {
          NormalDigitalClock({
            date: this.previewDate,
            colorsConfig: clockConfig.colors,
            isLandscape: true,
          })
        } else if (clockConfig.type == ClockType.Stereoscopic) {
          StereoscopicClock({
            date: this.previewDate,
            colorsConfig: clockConfig.colors,
            isLandscape: true,
          })
        }
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor(clockConfig.colors.backgroundColor)
      .alignRules({
        top: { anchor: "__container__", align: VerticalAlign.Top },
        left: { anchor: "__container__", align: HorizontalAlign.Start },
        right: { anchor: "__container__", align: HorizontalAlign.End },
        bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
      })
      .id("preview_clock")
      .height(534)
      .width(1150)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
    .scale({
      x: 60 / 534,
      y: 60 / 534
    })
  }
}