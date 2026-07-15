import webview from '@ohos.web.webview'
import router from '@ohos.router';
import { NavigationBar } from '../../views/NavigationBar'

interface AgreementPageParams {
  title?: string
  url?: string
}

@Entry
@Component
struct PrivacyPage {
  webviewController: webview.WebviewController = new webview.WebviewController()
  @State title: string = '隐私协议'
  @State url: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as AgreementPageParams
    this.title = params?.title ?? '隐私协议'
    this.url = params?.url ?? ''
  }

  build() {
    Column() {
      NavigationBar({
        title: this.title,
        onBack: () => {
          if (!this.onBackPress()) {
            router.back()
          }
        }
      })

      Web({
        src: this.url.length > 0 ? this.url : $rawfile('html/privacy_policy.html'),
        controller: this.webviewController
      })
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
  }

  onBackPress(): boolean | void {
    if (this.webviewController.accessBackward()) {
      this.webviewController.backward()
      return true
    }
  }
}
