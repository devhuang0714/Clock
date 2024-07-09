import { AppConstants, Icons } from '../../common/constants/Constants'
import router from '@ohos.router';

@Entry
@Component
struct ClockTheme {
  @State styles: Resource[] = [
    $r('app.media.flip_clock_default'),
    $r('app.media.round_clock_default'),
    $r('app.media.digital_clock_default'),
    $r('app.media.rotate_clock_style1'),
    $r('app.media.rotate_clock_style2'),
    $r('app.media.rotate_clock_style3'),
    $r('app.media.lunar_calendar_clock_style1'),
    $r('app.media.lunar_calendar_clock_style2'),
  ]
  @State selectedStyleIndex: number = 0

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 300 })
      .slide(SlideEffect.Bottom)
    PageTransitionExit({ type: RouteType.Pop, duration: 300 })
      .slide(SlideEffect.Bottom)

    PageTransitionEnter({ type: RouteType.Pop, duration: 0 })
    PageTransitionExit({ type: RouteType.Push, duration: 1000 })
  }

  build() {
    Column() {
      Row() {
        Button('完成')
          .type(ButtonType.Normal)
          .padding(0)
          .fontSize(22)
          .fontColor($r('app.color.flip_text_color'))
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            router.back()
          })
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.End)
      .margin({ bottom: 24 })

      Grid() {
        ForEach(this.styles, (icon: Resource, index: number) => {
          GridItem() {
            Stack() {
              Image(icon)
                .objectFit(ImageFit.Contain)

              if (index == this.selectedStyleIndex) {
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
            color: this.selectedStyleIndex == index ? Color.Green : $r('app.color.flip_card_bg_color'),
            radius: 8
          })
          .onClick(() => {
            this.selectedStyleIndex = index
          })
        })
      }
      .rowsGap(12)
      .columnsGap(24)
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .scrollBar(BarState.Off)
      .layoutWeight(1)

      Button() {
        Text(Icons.PACK_UP)
          .fontFamily(Icons.FONT_FAMILY)
          .fontSize(40)
          .fontColor($r('app.color.flip_text_color'))
      }
      .type(ButtonType.Normal)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        router.back()
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
    .padding({
      // top: AppConstants.DEFAULT_STATUS_HEIGHT,
      bottom: AppConstants.DEFAULT_NAV_HEIGHT,
      left: 24,
      right: 24
    })
  }
}