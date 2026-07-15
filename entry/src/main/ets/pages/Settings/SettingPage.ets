import { AppConstants, Icons } from '../../common/constants/Constants';
import router from '@ohos.router';
import Want from '@ohos.app.ability.Want';
import common from '@ohos.app.ability.common';
import { DEBUG } from 'utils/BuildProfile';
import { AppInfo } from '../../common/utils/AppInfo';
import { NavigationBar } from '../../views/NavigationBar';
import Icon from '../../common/icons/Icon';

interface SettingItem {
  title: string
  iconName: string
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
      iconName: Icons.CLOCK,
      url: 'pages/Settings/ClockThemesPage'
    },
    {
      title: '桌面小组件',
      iconName: Icons.MINI_WINDOW,
      url: 'pages/Settings/ClockWidgetsPage'
    },
    {
      title: '字体预览',
      iconName: Icons.FLIP,
      url: 'pages/Settings/FontPreviewPage',
      debugOnly: true
    },
    {
      title: '自定义',
      iconName: Icons.CUSTOM,
      url: 'pages/Settings/CustomPage'
    },
    {
      title: '意见反馈',
      iconName: Icons.FEEDBACK,
      url: 'pages/Settings/FeedbackPage'
    },
    {
      title: '分享',
      iconName: Icons.SHARE,
      url: 'pages/Settings/SharePage'
    },
    {
      iconName: Icons.CHECK_UPDATE,
      title: '检查更新',
      action: () => {
        AppInfo.goStore()
      }
    },
    {
      title: '关于我们',
      iconName: Icons.ABOUT,
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
        title: '',
        largeBackIcon: true
      })

      Blank()
        .height(12)

      Grid() {
        ForEach(this.items, (item: SettingItem) => {
          if (!item.debugOnly || DEBUG) {
            GridItem() {
              this.SettingItem(item.iconName, item.title)
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
    .padding({
      bottom: AppConstants.DEFAULT_NAV_HEIGHT
    })
  }

  @Builder
  SettingItem(iconName: string, title: string) {
    Column({ space: 24 }) {
      Icon({
        name: iconName,
        iconSize: 36,
        color: $r('app.color.flip_text_color')
      })

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
