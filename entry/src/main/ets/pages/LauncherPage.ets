import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';
import router from '@ohos.router';
import { AppConstants } from '../common/constants/Constants';
import { UT } from '../common/usertrack/UserTrack';
import { GlobalContext } from 'utils/Index'
import Logger from '../common/utils/HYLogger';
import PrivacyDialog from '../views/PrivacyDialog'

@Entry
@Component
struct LauncherPage {
  private context?: common.UIAbilityContext;
  dialogController: CustomDialogController = new CustomDialogController({
    builder: PrivacyDialog(
      {
        cancel: () => {
          this.onCancel();
        },
        confirm: () => {
          this.onConfirm();
        }
      }),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -24 },
    customStyle: true,
    autoCancel: false
  });

  onCancel() {
    this.context?.terminateSelf();
  }

  onConfirm() {
    this.saveAgreedPrivacy();
    this.jumpToRootPage();
  }

  onPageHide() {
    GlobalContext.getContext().setObject('isJumpPrivacy', true);
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
    this.context = getContext(this) as common.UIAbilityContext;
    this.getDataPreferences(this).then((preferences: preferences.Preferences) => {
      preferences.get('agreedPrivacy', false).then((value: preferences.ValueType) => {
        Logger.info('onPageShow value: ' + value);
        if (!value) {
          let isJumpPrivacy: boolean = (GlobalContext.getContext().getObject('isJumpPrivacy') as boolean) ?? false;
          Logger.info('onPageShow isJumpPrivacy: ' + isJumpPrivacy);
          if (!isJumpPrivacy) {
            this.dialogController.open();
          }
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
    Stack() {
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
      }
      .height('100%')
      .width('100%')
    }
  }
}