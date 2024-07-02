import { AppConstants, Icons } from '../../common/constants/Constants';
import router from '@ohos.router';
import { Router } from '@ohos.arkui.UIContext';

@Entry
@Component
export struct SettingPage {
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
      Grid() {
        GridItem() {
          this.SettingItem(Icons.CUSTOM, '自定义')
        }

        GridItem() {
          this.SettingItem(Icons.CLOCK, '表盘风格')
        }

        GridItem() {
          this.SettingItem(Icons.FEEDBACK, '意见反馈')
        }

        GridItem() {
          this.SettingItem(Icons.PRIVACY, '隐私协议')
        }
        .onClick(() => {
          router.pushUrl({
            url: 'pages/Settings/PrivacyPage'
          })
        })

        GridItem() {
          this.SettingItem(Icons.ABOUT, '关于我们')
        }
        .onClick(() => {
          router.pushUrl({
            url: 'pages/Settings/PrivacyPage'
          })
        })
      }
      .columnsGap(24)
      .rowsGap(24)
      .padding({ left: 24, right: 24 })

      Blank()
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
      top: AppConstants.DEFAULT_STATUS_HEIGHT,
      bottom: AppConstants.DEFAULT_NAV_HEIGHT
    })
  }

  @Builder
  SettingItem(unicode: string, title: string) {
    Column({ space: 24 }) {
      Text(unicode)
        .fontFamily(Icons.FONT_FAMILY)
        .fontSize(40)
        .fontColor($r('app.color.flip_text_color'))

      Text(title)
        .fontSize(20)
        .fontColor($r('app.color.flip_text_color'))
    }
    .width(140)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .aspectRatio(1)
    .borderRadius(12)
    .backgroundColor($r('app.color.flip_card_bg_color'))
  }
}