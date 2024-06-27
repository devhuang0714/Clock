import router from '@ohos.router';

@Entry
@Component
struct SettingPage {

  onBackPress(): boolean | void {
  }

  build() {
    Text('Setting Page')
      .fontSize(20)
      .onClick(() => {
        router.back()
      })
  }
}