import { ClockColorsConfig, DEFAULT_GLOBAL_CONFIG, GlobalClockConfig } from './ClockConfig'
import { ClockController, ClockListener } from './ClockController'
import { DateUtils } from '../../common/utils/DateUtils'
import { Icons } from '../../common/constants/Constants'

@Extend(Text)
function setTextStyles(fontSize: number, fontColor: ResourceColor) {
  .fontFamily(Icons.DIGITAL_NUM_FONT_FAMILY)
  .fontColor(fontColor)
  .fontWeight(FontWeight.Medium)
  .textAlign(TextAlign.Center)
  .minFontSize(36)
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
  @Prop globalConfig: GlobalClockConfig = DEFAULT_GLOBAL_CONFIG
  @Prop isLandscape: boolean = false
  @State dateStr: string = '0000-00-00'
  @State lunarDate: string = '甲子年一月一日'
  @State time: string = '00:00:00'
  @State milliseconds: string = '000'
  private listener: ClockListener = {
    onUpdate: (date) => {
      if (this.globalConfig.showWeek) {
        this.dateStr = `${DateUtils.formatDate(date, 'yyyy-MM-dd')} ${DateUtils.getWeek_ZH(date.getDay())}`
      } else {
        this.dateStr = DateUtils.formatDate(date, 'yyyy-MM-dd')
      }
      this.lunarDate = DateUtils.formatLunarDate(date)
      const hours = this.globalConfig.use24HourFormat ? date.getHours() : DateUtils.get12Hour(date)
      this.time = `${hours.toString().padStart(2, '0')}:${date.getMinutes()
        .toString()
        .padStart(2, '0')}:${date.getSeconds().toString().padStart(2, '0')}`

      if (this.globalConfig.showMilliseconds) {
        this.milliseconds = `.${date.getMilliseconds().toString().padStart(3, '0')}`
      } else {
        this.milliseconds = ''
      }
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
          .visibility(this.globalConfig.showDate ? Visibility.Visible : Visibility.Hidden)

        Text(this.lunarDate)
          .fontSize(18)
          .fontColor(this.colorsConfig.fontColor)
          .opacity(0.7)
          .visibility(this.globalConfig.showLunarCalendar ? Visibility.Visible : Visibility.Hidden)
      }
      .height('25%')
      .justifyContent(FlexAlign.Center)

      Text(this.time + this.milliseconds)
        .setTextStyles(130, this.colorsConfig.fontColor)

      Column()
        .height('25%')
        .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(12)
  }
}