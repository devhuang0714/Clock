import webview from '@ohos.web.webview'
import { GlobalContext } from 'utils/Index'
import { Icons } from '../../common/constants/Constants';
import router from '@ohos.router';

@Entry()
@Component
struct PrivacyPage {
  topRectHeight: string = AppStorage.get<number>('topRectHeight') + 'px'
  webviewController: webview.WebviewController = new webview.WebviewController()

  build() {
    Column() {
      Row() {
        Button() {
          Text(Icons.BACK)
            .fontFamily(Icons.FONT_FAMILY)
            .fontSize(24)
            .fontColor(Color.Black)
            .onClick(() => {
              if (!this.onBackPress()) {
                router.back()
              }
            })
        }
        .width(44)
        .height(44)
        .type(ButtonType.Normal)
        .borderRadius(3)
        .backgroundColor(Color.White)
        .margin({ left: 12 })

        Text($r('app.string.privacy_text_title'))
          .fontSize(18)
          .fontColor(Color.Black)
      }
      .width('100%')
      .height(44)
      .justifyContent(FlexAlign.Start)
      .margin({ top: this.topRectHeight })

      Web({ src: $rawfile('html/privacy_policy.html'), controller: this.webviewController })
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  onBackPress(): boolean | void {
    if (this.webviewController.accessBackward()) {
      this.webviewController.backward()
      return true
    }
    GlobalContext.getContext().setObject('isJumpPrivacy', false);
  }
}