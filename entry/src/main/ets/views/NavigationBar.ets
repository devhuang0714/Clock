import { AppConstants, Icons } from '../common/constants/Constants'
import router from '@ohos.router';

@Component
export struct NavigationBar {
  @Prop title: ResourceStr = ''
  onBack: (() => void) | undefined = undefined

  @Builder
  customBuilder() {
  }

  @BuilderParam
  builder: () => void = this.customBuilder

  build() {
    Row() {
      Button() {
        Text(Icons.BACK)
          .fontFamily(Icons.FONT_FAMILY)
          .fontSize(24)
          .onClick(() => {
            if (this.onBack != undefined) {
              this.onBack()
            } else {
              router.back()
            }
          })
      }
      .width(44)
      .height(44)
      .type(ButtonType.Normal)
      .backgroundColor(Color.Transparent)
      .borderRadius(3)
      .margin({ left: 12 })

      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)

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