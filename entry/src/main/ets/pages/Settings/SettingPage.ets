import { AppConstants, Icons } from '../../common/constants/Constants';
import router from '@ohos.router';

interface SettingItem {
  title: string,
  unicode: string,
  url: string
}

@Entry
@Component
export struct SettingPage {
  @State items: SettingItem[] = [
    {
      title: '表盘风格',
      unicode: Icons.CLOCK,
      url: 'pages/Settings/ClockThemesPage'
    },
    {
      title: '自定义',
      unicode: Icons.CUSTOM,
      url: 'pages/Settings/CustomPage'
    },
    {
      title: '意见反馈',
      unicode: Icons.FEEDBACK,
      url: 'pages/Settings/FeedbackPage'
    },
    {
      title: '分享',
      unicode: Icons.SHARE,
      url: 'pages/Settings/SharePage'
    },
    {
      title: '关于我们',
      unicode: Icons.ABOUT,
      url: 'pages/Settings/AboutPage'
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

  build() {
    Column() {
      Grid() {
        ForEach(this.items, (item: SettingItem) => {
          GridItem() {
            this.SettingItem(item.unicode, item.title)
          }
          .onClick(() => {
            router.pushUrl({
              url: item.url
            })
          })
        })
      }
      .columnsGap(12)
      .rowsGap(12)
      .padding({ left: 12, right: 12 })

      Blank()
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
      top: AppConstants.DEFAULT_STATUS_HEIGHT,
      bottom: AppConstants.DEFAULT_NAV_HEIGHT
    })
  }

  @Builder
  SettingItem(unicode: string, title: string) {
    Column({ space: 24 }) {
      Text(unicode)
        .fontFamily(Icons.FONT_FAMILY)
        .fontSize(36)
        .fontColor($r('app.color.flip_text_color'))

      Text(title)
        .fontSize(16)
        .fontColor($r('app.color.flip_text_color'))
    }
    .width(120)
    .aspectRatio(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .borderRadius(12)
    .backgroundColor($r('app.color.flip_card_bg_color'))
  }
}