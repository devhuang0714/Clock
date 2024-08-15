import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';
import router from '@ohos.router';
import { AppConstants } from '../common/constants/Constants';
import { UT } from '../common/usertrack/UserTrack';
import { GlobalContext } from 'utils/Index'
import Logger from '../common/utils/HYLogger';

@Extend(Text)
function fancy() {
  .fontColor('#007DFF')
  .fontSize(16)
  .textAlign(TextAlign.Center)
  .fontWeight(FontWeight.Medium)
  .layoutWeight(1)
}

@Entry
@Component
struct LauncherPage {
  @State showPrivacy: boolean = false

  onCancel() {
    let context = GlobalContext.getContext().getObject('entryContext') as common.UIAbilityContext;
    context.terminateSelf()
  }

  onConfirm() {
    this.saveAgreedPrivacy();
    this.jumpToRootPage();
  }

  jumpToRootPage() {
    // 初始化统计SDK
    UT.init()

    router.replaceUrl({
      url: 'pages/Index'
    }).catch((error: Error) => {
      Logger.error('LauncherPage pushUrl error ' + JSON.stringify(error));
    });
  }

  saveAgreedPrivacy() {
    let preferences: Promise<preferences.Preferences> = this.getDataPreferences(this);
    preferences.then((result: preferences.Preferences) => {
      let privacyPut = result.put('agreedPrivacy', true);
      result.flush();
      privacyPut.then(() => {
        Logger.info('Put the value of startup Successfully.');
      }).catch((err: Error) => {
        Logger.error('Put the value of startup Failed, err: ' + err);
      });
    }).catch((err: Error) => {
      Logger.error('Get the preferences Failed, err: ' + err);
    });
  }

  onPageShow() {
    this.getDataPreferences(this).then((preferences: preferences.Preferences) => {
      preferences.get('agreedPrivacy', false).then((value: preferences.ValueType) => {
        Logger.info('onPageShow value: ' + value);
        if (!value) {
          this.showPrivacy = true
        } else {
          this.jumpToRootPage();
        }
      });
    });
  }

  getDataPreferences(common: Object) {
    return preferences.getPreferences(getContext(common), AppConstants.BUNDLE_NAME);
  }

  build() {
    Column() {
      Image($r('app.media.startIcon'))
        .width(120)
        .height(120)
        .margin({ top: '16.2%' })
      Text($r('app.string.EntryAbility_label'))
        .height(35)
        .fontWeight(FontWeight.Bold)
        .letterSpacing(0.1)
        .fontSize(26)
        .fontColor('#182431')
        .margin({ top: '0.5%' })
      Text($r('app.string.introduce'))
        .height('2.7%')
        .fontWeight(FontWeight.Normal)
        .letterSpacing(3.4)
        .fontSize(16)
        .fontColor('#182431')
        .opacity(0.6)
        .margin({ top: '1.3%' })

      Blank()
        .layoutWeight(1)

      this.PrivacyDialog()
    }
    .height('100%')
    .width('100%')
    .backgroundColor(Color.Gray)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  PrivacyDialog() {
    Column() {
      Text($r('app.string.dialog_text_title'))
        .width('90%')
        .fontColor('#182431')
        .fontSize(20)
        .textAlign(TextAlign.Center)
        .fontWeight('3.1%')
        .margin({
          top: 24,
          bottom: 12
        })
      Text($r('app.string.dialog_text_privacy_content'))
        .fontColor('#333333')
        .fontSize(18)
        .width('90%')
      Text($r('app.string.dialog_text_privacy_statement'))
        .width('90%')
        .fontColor('#007DFF')
        .fontSize(18)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/Settings/PrivacyPage'
          }).catch((error: Error) => {
            Logger.error('CustomDialog pushUrl error ' + JSON.stringify(error));
          });
        })
      Text($r('app.string.dialog_text_declaration_prompt'))
        .width('90%')
        .fontColor('#182431')
        .fontSize(18)
        .opacity(0.6)
        .margin({ bottom: 24 })
      Row() {
        Text($r('app.string.dialog_button_disagree'))
          .fancy()
          .onClick(() => {
            this.onCancel();
          })
        Blank()
          .backgroundColor('#F5F5F5')
          .width(1)
          .height(32)
        Text($r('app.string.dialog_button_agree'))
          .fancy()
          .onClick(() => {
            this.onConfirm();
          })
      }
      .margin({ bottom: '3.1%' })
    }
    .width('93.3%')
    .borderRadius(24)
    .backgroundColor(Color.White)
    .visibility(this.showPrivacy ? Visibility.Visible : Visibility.Hidden)
    .margin({ bottom: 34 })
  }
}