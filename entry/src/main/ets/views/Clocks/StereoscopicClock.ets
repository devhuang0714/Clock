import { ClockController, ClockListener } from './ClockController'
import { ClockColorsConfig, DEFAULT_GLOBAL_CONFIG, GlobalClockConfig } from './ClockConfig'
import { DateUtils } from '../../common/utils/DateUtils';
import { LengthUnit } from '@ohos.arkui.node';

@Extend(Text)
function setTextStyles(fontSize: number, fontColor: ResourceColor, space: number) {
  .fontSize(fontSize)
  .fontColor(fontColor)
  .fontWeight(FontWeight.Medium)
  .textAlign(TextAlign.Center)
  .padding(space)
}

@Extend(Text)
function setCardStyles(backgroundColor?: ResourceColor, shadowColor?: ResourceColor) {
  .shadow({ radius: 30, color: shadowColor ?? Color.Transparent, offsetY: 10 })
  .borderRadius(12)
  .backgroundColor(backgroundColor ?? $r('app.color.flip_card_bg_color'))
}

@Component({ freezeWhenInactive: true })
export struct StereoscopicClock {
  controller: ClockController = new ClockController()
  date: Date = new Date()
  @Prop colorsConfig: ClockColorsConfig = {
    backgroundColor: $r('app.color.main_background_color'),
    cardColor: $r('app.color.flip_card_bg_color'),
    fontColor: $r('app.color.flip_text_color')
  }
  @Prop globalConfig: GlobalClockConfig = DEFAULT_GLOBAL_CONFIG
  @Prop isLandscape: boolean = false
  @Prop fontSize: number = 130
  @Prop space: number = 4
  @State hours: string = '00'
  @State minutes: string = '00'
  @State seconds: string = '00'
  @State isPM: boolean = false
  private listener: ClockListener = {
    onUpdate: (date) => {
      const hours = this.globalConfig.use24HourFormat ? date.getHours() : DateUtils.get12Hour(date)
      this.hours = hours.toString().padStart(2, '0')
      this.minutes = date.getMinutes().toString().padStart(2, '0')
      this.seconds = date.getSeconds().toString().padStart(2, '0')
      this.isPM = date.getHours() >= 12
    }
  }

  aboutToAppear(): void {
    this.hours = this.date.getHours().toString().padStart(2, '0')
    this.minutes = this.date.getMinutes().toString().padStart(2, '0')
    this.seconds = this.date.getSeconds().toString().padStart(2, '0')

    this.controller.registerListener(this.listener)
    this.listener.onUpdate(this.date)
  }

  aboutToDisappear(): void {
    this.controller.unregisterListener(this.listener)
  }

  getPeriodVisible(): Visibility {
    return this.globalConfig.showAMPM && !this.globalConfig.use24HourFormat ? Visibility.Visible : Visibility.Hidden
  }

  build() {
    Flex({
      direction: this.isLandscape ? FlexDirection.Row : FlexDirection.Column,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Center,
    }) {
      Text(this.isPM ? 'PM' : 'AM')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.colorsConfig.fontColor)
        .textAlign(TextAlign.Center)
        .width(50)
        .height(50)
        .offset({
          x: this.isLandscape ? 0 : (this.isPM ? 24 : -24),
          y: this.isLandscape ? (this.isPM ? 24 : -24) : 0
        })
        .visibility(this.getPeriodVisible())

      Text(this.hours)
        .setTextStyles(this.fontSize, this.colorsConfig.fontColor, 8)
        .setCardStyles(this.colorsConfig.cardColor, this.colorsConfig.shadowColor)

      this.Colon()

      Text(this.minutes)
        .setTextStyles(this.fontSize, this.colorsConfig.fontColor, 8)
        .setCardStyles(this.colorsConfig.cardColor, this.colorsConfig.shadowColor)

      this.Colon()

      Text(this.seconds)
        .setTextStyles(this.fontSize, this.colorsConfig.fontColor, 8)
        .setCardStyles(this.colorsConfig.cardColor, this.colorsConfig.shadowColor)

      // 为了让时钟居中，所以放个空元素
      Row()
        .width(50)
        .height(50)
    }
  }

  @Builder
  Colon() {
    if (this.isLandscape) {
      Text(':')
        .setTextStyles(this.fontSize, this.colorsConfig.fontColor, 8)
    } else {
      Blank()
        .height(30)
    }
  }
}