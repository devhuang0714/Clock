import router from '@ohos.router';
import { GlobalContext } from 'utils/Index'
import Logger from '../common/utils/HYLogger';

@CustomDialog
export default struct PrivacyDialog {
  controller: CustomDialogController = new CustomDialogController({'builder': ''});
  cancel: Function = () => {};
  confirm: Function = () => {};

  build() {
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
        .fontSize(18)
        .fontColor('#182431')
        .width('90%')
      Text($r('app.string.dialog_text_privacy_statement'))
        .width('90%')
        .fontColor('#007DFF')
        .fontSize(18)
        .onClick(() => {
          GlobalContext.getContext().setObject('isJumpPrivacy', true);
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
            this.controller.close();
            this.cancel();
          })
        Blank()
          .backgroundColor('#F5F5F5')
          .width(1)
          .height(32)
        Text($r('app.string.dialog_button_agree'))
          .fancy()
          .onClick(() => {
            this.controller.close();
            this.confirm();
          })
      }
      .margin({ bottom: '3.1%' })
    }
    .width('93.3%')
    .borderRadius(24)
    .backgroundColor(Color.White)
  }
}

@Extend(Text)
function fancy () {
  .fontColor('#007DFF')
  .fontSize(16)
  .textAlign(TextAlign.Center)
  .fontWeight(FontWeight.Medium)
  .layoutWeight(1)
}