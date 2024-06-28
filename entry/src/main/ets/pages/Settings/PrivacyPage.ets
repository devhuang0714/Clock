import webview from '@ohos.web.webview'
import { GlobalContext } from 'utils/Index'
import { ConfigurationConstant } from '@kit.AbilityKit';

@Entry
@Component
struct PrivacyPage {
  webviewController: webview.WebviewController = new webview.WebviewController()
  @State mode: WebDarkMode = WebDarkMode.Auto
  @State access: boolean = true

  build() {
    Navigation() {
      Web({ src: $rawfile('html/privacy_policy.html'), controller: this.webviewController })
        .darkMode(this.mode)
        .forceDarkAccess(this.access)
    }
    .width('100%')
    .height('100%')
    .title('隐私协议')
    .titleMode(NavigationTitleMode.Mini)
    .backgroundColor($r('app.color.main_background_color'))
  }

  onBackPress(): boolean | void {
    if (this.webviewController.accessBackward()) {
      this.webviewController.backward()
      return true
    }
    GlobalContext.getContext().setObject('isJumpPrivacy', false);
  }
}