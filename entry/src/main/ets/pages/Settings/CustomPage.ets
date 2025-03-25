import { AppConstants } from '../../common/constants/Constants'
import { DEFAULT_GLOBAL_CONFIG, GlobalClockConfig } from '../../views/Clocks/ClockConfig'
import { NavigationBar } from '../../views/NavigationBar'
import { ConfigurationConstant } from '@kit.AbilityKit'

interface CustomOptions {
  title: string,
  isOn: boolean
}

@Entry
@Component
struct CustomPage {
  @StorageLink('currentColorMode') currentMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  @StorageLink('globalClockConfig') globalConfig: GlobalClockConfig = DEFAULT_GLOBAL_CONFIG

  build() {
    Column() {
      NavigationBar({
        title: '自定义'
      })

      List({ space: 12 }) {
        this.ThemeItem()

        this.CustomItem({
          title: '横竖屏切换（跟随系统）',
          isOn: this.globalConfig.autoRotation
        }, (isOn) => {
          this.globalConfig.autoRotation = isOn
        })

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
          title: '显示星期',
          isOn: this.globalConfig.showWeek
        }, (isOn) => {
          this.globalConfig.showWeek = isOn
        })

        this.CustomItem({
          title: '显示毫秒',
          isOn: this.globalConfig.showMilliseconds
        }, (isOn) => {
          this.globalConfig.showMilliseconds = isOn
        })

        // this.FontSizeItem()

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
  ThemeItem() {
    ListItem() {
      Row() {
        Text('主题样式')
          .fontSize(16)
          .fontColor($r('app.color.flip_text_color'))

        Blank()

        Row() {
          Text('跟随系统')
            .fontSize(14)
            .fontColor($r('app.color.flip_text_color'))
            .padding(6)
            .height('100%')
            .fontColor(this.globalConfig.themeMode === ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET ? Color.White : $r('app.color.flip_text_color'))
            .backgroundColor(this.globalConfig.themeMode === ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET ? Color.Green : Color.Transparent)
            .onClick(() => {
              this.globalConfig.themeMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
              getContext().getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
            })

          Text('深色')
            .fontSize(14)
            .padding(6)
            .height('100%')
            .fontColor(this.globalConfig.themeMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? Color.White : $r('app.color.flip_text_color'))
            .backgroundColor(this.globalConfig.themeMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? Color.Green : Color.Transparent)
            .onClick(() => {
              this.globalConfig.themeMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK
              getContext().getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
            })

          Text('浅色')
            .fontSize(14)
            .fontColor($r('app.color.flip_text_color'))
            .padding(6)
            .height('100%')
            .fontColor(this.globalConfig.themeMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT ? Color.White : $r('app.color.flip_text_color'))
            .backgroundColor(this.globalConfig.themeMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT ? Color.Green : Color.Transparent)
            .onClick(() => {
              this.globalConfig.themeMode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
              getContext().getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
            })
        }
        .borderRadius(6)
        .height(32)
        .clip(true)
        .backgroundColor($r('app.color.main_background_color'))
      }
      .width('100%')
      .height(60)
      .padding({ left: 12, right: 12 })
    }
    .margin({ left: 24, right: 24 })
    .borderRadius(8)
    .backgroundColor($r('app.color.flip_card_bg_color'))
  }

  @Builder
  FontSizeItem() {
    ListItem() {
      Row() {
        Text('表盘字体')
          .fontSize(16)
          .fontColor($r('app.color.flip_text_color'))

        Blank()

        Row() {
          Text('中号')
            .fontSize(16)
            .fontColor($r('app.color.flip_text_color'))
            .padding(6)
            .height('100%')
            .backgroundColor(Color.Green)

          Text('大号')
            .fontSize(18)
            .fontColor($r('app.color.flip_text_color'))
            .padding(6)
            .height('100%')

          Text('超大号')
            .fontSize(20)
            .fontColor($r('app.color.flip_text_color'))
            .padding(6)
            .height('100%')
        }
        .borderRadius(6)
        .height(40)
        .clip(true)
        .backgroundColor($r('app.color.main_background_color'))
      }
      .width('100%')
      .height(60)
      .padding({ left: 12, right: 12 })
    }
    .margin({ left: 24, right: 24 })
    .borderRadius(8)
    .backgroundColor($r('app.color.flip_card_bg_color'))
  }

  @Builder
  CustomItem(options: CustomOptions, onChange: (isOn: boolean) => void = () => {
  }) {
    ListItem() {
      Row() {
        Text(options.title)
          .fontSize(16)
          .fontColor($r('app.color.flip_text_color'))

        Blank()

        Toggle({
          type: ToggleType.Switch,
          isOn: options.isOn
        })
          .width(60)
          .height(40)
          .padding(8)
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