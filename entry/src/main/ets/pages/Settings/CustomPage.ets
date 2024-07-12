import { AppConstants } from '../../common/constants/Constants'
import { DEFAULT_GLOBAL_CONFIG, GlobalClockConfig } from '../../views/Clocks/ClockConfig'
import { NavigationBar } from '../../views/NavigationBar'

interface CustomOptions {
  title: string,
  isOn: boolean
}

@Entry
@Component
struct CustomPage {
  @StorageLink('globalClockConfig') globalConfig: GlobalClockConfig = DEFAULT_GLOBAL_CONFIG

  build() {
    Column() {
      // Text('字体大小')
      //   .fontSize(16)
      //
      // Row({ space: 12 }) {
      //   Button('中')
      //     .fontSize(16)
      //
      //   Button('大')
      //     .fontSize(20)
      //
      //   Button('超大')
      //     .fontSize(24)
      // }
      // .width('100%')
      // .justifyContent(FlexAlign.Start)
      NavigationBar({
        title: '自定义'
      })

      List({ space: 12 }) {
        this.CustomItem({
          title: '24小时制',
          isOn: this.globalConfig.use24HourFormat
        }, (isOn) => {
          this.globalConfig.use24HourFormat = isOn
        })

        this.CustomItem({
          title: '显示AM/PM',
          isOn: this.globalConfig.showAMPM
        }, (isOn) => {
          this.globalConfig.showAMPM = isOn
        })

        this.CustomItem({
          title: '显示日期',
          isOn: this.globalConfig.showDate
        }, (isOn) => {
          this.globalConfig.showDate = isOn
        })

        this.CustomItem({
          title: '显示农历',
          isOn: this.globalConfig.showLunarCalendar
        }, (isOn) => {
          this.globalConfig.showLunarCalendar = isOn
        })

        this.CustomItem({
          title: '显示周',
          isOn: this.globalConfig.showWeek
        }, (isOn) => {
          this.globalConfig.showWeek = isOn
        })

        ListItem()
          .height(AppConstants.DEFAULT_NAV_HEIGHT)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  CustomItem(options: CustomOptions, onChange: (isOn: boolean) => void = () => {
  }) {
    ListItem() {
      Row() {
        Text(options.title)
          .fontSize(18)
          .fontColor($r('app.color.flip_text_color'))

        Blank()

        Toggle({
          type: ToggleType.Switch,
          isOn: options.isOn
        })
          .selectedColor(Color.Green)
          .onChange(onChange)
      }
      .width('100%')
      .height(60)
      .padding({ left: 12, right: 12 })
    }
    .margin({ left: 24, right: 24 })
    .borderRadius(8)
    .backgroundColor($r('app.color.flip_card_bg_color'))
  }
}