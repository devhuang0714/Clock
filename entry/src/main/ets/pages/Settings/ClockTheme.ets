import { AppConstants, Icons } from '../../common/constants/Constants'
import router from '@ohos.router';
import { ClockConfig, CLOCK_CONFIGS } from '../../views/Clocks/ClockConfig';

@Entry
@Component
struct ClockTheme {
  @State clockItems: ClockConfig[] = CLOCK_CONFIGS
  @State selectedConfig: ClockConfig = CLOCK_CONFIGS[0]
  @StorageProp('isLandscape') isLandscape: boolean = false

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
          .fontSize(22)
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
      .margin({ top: AppConstants.DEFAULT_STATUS_HEIGHT, bottom: 12 })

      Grid() {
        ForEach(this.clockItems, (item: ClockConfig) => {
          GridItem() {
            Stack() {
              Image(item.preview)
                .objectFit(ImageFit.Contain)

              if (this.isSelected(item)) {
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
            color: this.isSelected(item) ? Color.Green : $r('app.color.flip_card_bg_color'),
            radius: 8
          })
          .onClick(() => {
            this.selectedConfig = item
          })
        })
      }
      .rowsGap(12)
      .columnsGap(24)
      .columnsTemplate(this.isLandscape ? '1fr 1fr 1fr 1fr' : '1fr 1fr')
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
      bottom: AppConstants.DEFAULT_NAV_HEIGHT,
      left: 24,
      right: 24
    })
  }
}