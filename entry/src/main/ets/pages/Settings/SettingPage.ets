import { AppConstants, Icons } from '../../common/constants/Constants';
import router from '@ohos.router';
import Want from '@ohos.app.ability.Want';
import common from '@ohos.app.ability.common';
import { DEBUG } from 'utils/BuildProfile';
import { AppInfo } from '../../common/utils/AppInfo';
import { NavigationBar } from '../../views/NavigationBar';

interface SettingItem {
  title: string
  unicode: string
  url?: string
  action?: () => void
  debugOnly?: boolean
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
      title: '字体预览',
      unicode: Icons.FLIP,
      url: 'pages/Settings/FontPreviewPage',
      debugOnly: true
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
      unicode: Icons.CHECK_UPDATE,
      title: '检查更新',
      action: () => {
        AppInfo.goStore()
      }
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
      NavigationBar({
        backIcon: Icons.CLOSE,
        title: ''
      })

      Blank()
        .height(12)

      Grid() {
        ForEach(this.items, (item: SettingItem) => {
          if (!item.debugOnly || DEBUG) {
            GridItem() {
              this.SettingItem(item.unicode, item.title)
            }
            .onClick(() => {
              if (item.action) {
                item.action()
              } else if (item.url) {
                router.pushUrl({ url: item.url })
              }
            })
          }
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
