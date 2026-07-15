import router from '@ohos.router';
import bundleManager from '@ohos.bundle.bundleManager';
import { BusinessError } from '@ohos.base';
import hilog from '@ohos.hilog';
import common from '@ohos.app.ability.common'
import { AppConstants, Icons } from '../../common/constants/Constants';
import { NavigationBar } from '../../views/NavigationBar'
import { privacyManager } from '@kit.StoreKit';
import Logger from '../../common/utils/HYLogger'
import Icon from '../../common/icons/Icon'

interface AboutItem {
  title: string
  iconName: string
  url?: string
  action?: () => void
}

const DEFAULT_PRIVACY = "https://agreement-drcn.hispace.dbankcloud.cn/index.html?lang=zh&agreementId=1565146210803664192"
const DEFAULT_USER_AGREEMENT = "https://devhuang0714.cn/apps/clock/v1/user_ageement.html"

@Entry
@Component
export default struct AboutPage {
  private context?: common.UIAbilityContext
  @State versionName: string = 'v1.0.0'
  @State items: AboutItem[] = [
    {
      iconName: Icons.PRIVACY,
      title: '隐私协议',
      action: () => {
        this.openPrivacy()
      }
    },
    {
      iconName: Icons.USER_AGREEMENT,
      title: '用户协议',
      action: () => {
        this.openUserAgreement()
      }
    },
    {
      iconName: Icons.FEEDBACK,
      title: '意见反馈',
      url: 'pages/Settings/FeedbackPage',
    },
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
          this.versionName = `v${data.versionName}`
          hilog.info(0x0000, 'testTag', 'getBundleInfoForSelf successfully: %{public}s', JSON.stringify(data));
        }
      });
    } catch (err) {
      let message = (err as BusinessError).message;
      hilog.error(0x0000, 'testTag', 'getBundleInfoForSelf failed: %{public}s', message);
    }
  }

  openPrivacy() {
    // 隐私协议
    let privacyStatementUrl = this.getPrivacyUrl(privacyManager.AppPrivacyLinkType.PRIVACY_STATEMENT_LINK) ?? DEFAULT_PRIVACY
    this.openAgreement('隐私协议', privacyStatementUrl)
  }

  openUserAgreement() {
    // 用户协议
    let userAgreementUrl = this.getPrivacyUrl(privacyManager.AppPrivacyLinkType.USER_AGREEMENT_LINK) ?? DEFAULT_USER_AGREEMENT
    this.openAgreement('用户协议', userAgreementUrl)
  }

  openAgreement(title: string, url: string) {
    router.pushUrl({
      url: 'pages/Settings/PrivacyPage',
      params: {
        title,
        url
      }
    }).catch((error: Error) => {
      Logger.error(`Open agreement failed: ${JSON.stringify(error)}`)
    })
  }

  getPrivacyUrl(type: privacyManager.AppPrivacyLinkType): string | null {
    try {
      let appPrivacyManageInfo: privacyManager.AppPrivacyMgmtInfo = privacyManager.getAppPrivacyMgmtInfo();
      let privacyLinkInfoArray : privacyManager.AppPrivacyLink[] = appPrivacyManageInfo.privacyInfo;
      for (let i = 0; i < privacyLinkInfoArray.length; i++) {
        const privacyLinkInfo = privacyLinkInfoArray[i]
        if (privacyLinkInfo.type == type) {
          return privacyLinkInfo.url
        }
      }
    } catch (error) {
      Logger.error("GetAppPrivacyManageInfoPublic exception code: " + error.code + ", exception message: " + error.message);
    }
    return null
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
              Icon({
                name: item.iconName,
                iconSize: 24,
                color: $r('app.color.main_text_color')
              })
                .margin(8)

              Text(item.title)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start)
                .fontColor($r('app.color.main_text_color'))
                .layoutWeight(1)

              Icon({
                name: Icons.ARROW_RIGHT,
                iconSize: 16,
                color: $r('app.color.main_text_color')
              })
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
