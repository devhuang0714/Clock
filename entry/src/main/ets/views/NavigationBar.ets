import { AppConstants, Icons } from '../common/constants/Constants'
import router from '@ohos.router';

@Component
export struct NavigationBar {
  @Prop backIcon: ResourceStr = Icons.BACK
  @Prop title: ResourceStr = ''
  @Prop largeBackIcon: boolean = false
  onBack: (() => void) | undefined = undefined

  @Builder
  customBuilder() {
  }

  @BuilderParam
  builder: () => void = this.customBuilder

  build() {
    Row() {
      Row() {
        if (this.largeBackIcon) {
          Text(this.backIcon)
            .fontFamily(Icons.FONT_FAMILY)
            .fontSize(30)
            .width(44)
            .height(44)
            .textAlign(TextAlign.Center)
        } else {
          Text(this.backIcon)
            .fontFamily(Icons.FONT_FAMILY)
            .fontSize(24)
        }

        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
      }
      .height(44)
      .backgroundColor(Color.Transparent)
      .margin({ left: this.largeBackIcon ? 8 : 12 })
      .onClick(() => {
        if (this.onBack != undefined) {
          this.onBack()
        } else {
          router.back()
        }
      })

      Blank()
        .layoutWeight(1)

      this.builder()
    }
    .width('100%')
    .height(44)
    .justifyContent(FlexAlign.Start)
    .margin({ top: AppConstants.DEFAULT_STATUS_HEIGHT })
  }
}
