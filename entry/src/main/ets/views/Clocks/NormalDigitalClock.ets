import { ClockColorsConfig } from './ClockConfig'
import { ClockController, ClockListener } from './ClockController'
import { DateUtils } from '../../common/utils/DateUtils'

@Extend(Text)
function setTextStyles(fontSize: number, fontColor: ResourceColor) {
  .fontFamily('digital-num-font')
  .fontColor(fontColor)
  .fontWeight(FontWeight.Medium)
  .textAlign(TextAlign.Center)
  .minFontSize(50)
  .maxFontSize(fontSize)
  .maxLines(1)
  .width('100%')
}

@Component({ freezeWhenInactive: true })
export struct NormalDigitalClock {
  controller: ClockController = new ClockController()
  date: Date = new Date()
  @Prop colorsConfig: ClockColorsConfig = {
    backgroundColor: $r('app.color.main_background_color'),
    cardColor: '',
    fontColor: $r('app.color.flip_text_color')
  }
  @State dateStr: string = '0000-00-00'
  @State lunarDate: string = '甲子年一月一日'
  @State time: string = '00:00:00'
  private listener: ClockListener = {
    onUpdate: (date) => {
      this.dateStr = `${DateUtils.formatDate(date, 'yyyy-MM-dd')} ${DateUtils.getWeek_ZH(date.getDay())}`
      this.lunarDate = DateUtils.formatLunarDate(date)
      this.time = `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes()
        .toString()
        .padStart(2, '0')}:${date.getSeconds().toString().padStart(2, '0')}`
    }
  }

  aboutToAppear(): void {
    this.controller.registerListener(this.listener)
    this.listener.onUpdate(this.date)
  }

  aboutToDisappear(): void {
    this.controller.unregisterListener(this.listener)
  }

  build() {
    Column({ space: 8 }) {
      Column({ space: 8 }) {
        Text(this.dateStr)
          .minFontSize(18)
          .maxFontSize(24)
          .fontColor(this.colorsConfig.fontColor)
          .maxLines(1)

        Text(this.lunarDate)
          .fontSize(18)
          .fontColor(this.colorsConfig.fontColor)
          .opacity(0.7)
      }
      .height('25%')
      .justifyContent(FlexAlign.Center)

      Text(this.time)
        .setTextStyles(130, this.colorsConfig.fontColor)

      Column()
        .height('25%')
        .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(12)
  }
}