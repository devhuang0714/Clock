import router from '@ohos.router';
import bundleManager from '@ohos.bundle.bundleManager';
import { BusinessError } from '@ohos.base';
import hilog from '@ohos.hilog';
import common from '@ohos.app.ability.common'
import { AppConstants, Icons } from '../../common/constants/Constants';
import { NavigationBar } from '../../views/NavigationBar'
import Want from '@ohos.app.ability.Want';

interface AboutItem {
  title: string
  unicode: string
  url?: string
  action?: () => void
}

@Entry
@Component
export default struct AboutPage {
  private context?: common.UIAbilityContext
  @State versionName: string = '1.0.0'
  @State items: AboutItem[] = [
    {
      unicode: Icons.PRIVACY,
      title: '隐私协议',
      url: 'pages/Settings/PrivacyPage',
    },
    {
      unicode: Icons.FEEDBACK,
      title: '意见反馈',
      url: 'pages/Settings/FeedbackPage',
    },
    // {
    //   unicode: Icons.CHECK_UPDATE,
    //   title: '检查更新',
    //   action: () => {
    //     this.onCheckUpdate()
    //   }
    // },
  ]

  aboutToAppear(): void {
    this.context = getContext(this) as common.UIAbilityContext
    this.getAppVersion()
  }

  getAppVersion() {
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_ABILITY | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_REQUESTED_PERMISSION;

    try {
      bundleManager.getBundleInfoForSelf(bundleFlags, (err, data) => {
        if (err) {
          hilog.error(0x0000, 'testTag', 'getBundleInfoForSelf failed: %{public}s', err.message);
        } else {
          this.versionName = data.versionName
          hilog.info(0x0000, 'testTag', 'getBundleInfoForSelf successfully: %{public}s', JSON.stringify(data));
        }
      });
    } catch (err) {
      let message = (err as BusinessError).message;
      hilog.error(0x0000, 'testTag', 'getBundleInfoForSelf failed: %{public}s', message);
    }
  }

  onCheckUpdate() {
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    let want: Want = {
      uri: 'store://appgallery.huawei.com/app/detail?id=com.hyx.clock'
    }
    context.startAbility(want)
  }

  build() {
    Column() {
      NavigationBar({
        title: '关于我们'
      })
      List({ space: 12 }) {
        ListItem() {
          this.HeaderView()
        }

        ForEach(this.items, (item: AboutItem) => {
          ListItem() {
            Row() {
              Text(item.unicode)
                .fontFamily(Icons.FONT_FAMILY)
                .fontSize(24)
                .fontColor($r('app.color.main_text_color'))
                .margin(8)

              Text(item.title)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start)
                .fontColor($r('app.color.main_text_color'))
                .layoutWeight(1)

              Text(Icons.ARROW_RIGHT)
                .fontFamily(Icons.FONT_FAMILY)
                .fontSize(16)
            }
            .height(60)
            .padding({ left: 12, right: 12 })
            .margin({ left: 12, right: 12 })
            .borderRadius(12)
            .backgroundColor($r('app.color.flip_card_bg_color'))
          }
          .onClick(() => {
            if (item.action) {
              item.action()
            } else if (item.url) {
              router.pushUrl({ url: item.url })
            }
          })
        })

        ListItem()
          .height(AppConstants.DEFAULT_NAV_HEIGHT)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
  }

  @Builder
  HeaderView() {
    Column({ space: 10 }) {
      Image($r('app.media.logo'))
        .width(100)
        .height(100)
        .borderRadius(8)

      Text($r('app.string.EntryAbility_label'))
        .fontSize(16)
        .fontColor($r('app.color.main_text_color'))

      Text(`${this.versionName}`)
        .fontSize(16)
        .fontColor($r('app.color.main_text_color'))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 24, bottom: 24 })
  }
}