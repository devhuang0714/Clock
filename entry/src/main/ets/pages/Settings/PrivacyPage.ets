// import webview from '@ohos.web.webview'
import router from '@ohos.router';
import { NavigationBar } from '../../views/NavigationBar'

@Entry
@Component
struct PrivacyPage {
  topRectHeight: string = AppStorage.get<number>('topRectHeight') + 'px'
  // webviewController: webview.WebviewController = new webview.WebviewController()

  build() {
    // Column() {
    //   NavigationBar({
    //     title: $r('app.string.privacy_text_title'),
    //     onBack: () => {
    //       if (!this.onBackPress()) {
    //         router.back()
    //       }
    //     }
    //   })
    //
    //   // Web({ src: $rawfile('html/privacy_policy.html'), controller: this.webviewController })
    //   //   .layoutWeight(1)
    // }
    // .width('100%')
    // .height('100%')
    // .backgroundColor($r('app.color.main_background_color'))
  }

  // onBackPress(): boolean | void {
  //   if (this.webviewController.accessBackward()) {
  //     this.webviewController.backward()
  //     return true
  //   }
  // }
}