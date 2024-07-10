import { ClockColorsConfig } from './ClockConfig'
import { ClockController, ClockListener } from './ClockController'

@Extend(Text)
function setTextStyles(fontSize: number, fontColor: ResourceColor) {
  .fontFamily('digital-num-font')
  .fontSize(fontSize)
  .fontColor(fontColor)
  .fontWeight(FontWeight.Bold)
  .textAlign(TextAlign.Center)
  .width('100%')
}

@Component({ freezeWhenInactive: true })
export struct DigitalClock {
  controller: ClockController = new ClockController()
  date: Date = new Date()
  @Prop colorsConfig: ClockColorsConfig = {
    backgroundColor: $r('app.color.main_background_color'),
    cardColor: '',
    fontColor: $r('app.color.flip_text_color')
  }
  @State year: string = '----'
  @State day: string = '-----'
  @State week: string = '--'
  @State time: string = '--:--:--'
  @State hours: string = '00'
  @State minutes: string = '00'
  @State seconds: string = '00'
  private listener: ClockListener = {
    onUpdate: (date) => {
      this.year = date.getFullYear().toString()
      this.day = `${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`
      this.week = this.getWeek_EN(date.getDay())
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

  getWeek_EN(weekDay: number): string {
    switch (weekDay) {
      case 1:
        return 'MONDAY'
      case 2:
        return 'TUESDAY'
      case 3:
        return 'WEDNESDAY'
      case 4:
        return 'THURSDAY'
      case 5:
        return 'FRIDAY'
      case 6:
        return 'SATURDAY'
      case 7:
        return 'SUNDAY'
    }
    return ''
  }

  getWeek_ZH(weekDay: number): string {
    switch (weekDay) {
      case 1:
        return '星期一'
      case 2:
        return '星期二'
      case 3:
        return '星期三'
      case 4:
        return '星期四'
      case 5:
        return '星期五'
      case 6:
        return '星期六'
      case 7:
        return '星期日'
    }
    return ''
  }

  build() {
    Column({ space: 8 }) {
      Text(this.year)
        .setTextStyles(32, this.colorsConfig.fontColor)

      Text(this.day)
        .setTextStyles(36, this.colorsConfig.fontColor)

      Text(this.week)
        .setTextStyles(40, this.colorsConfig.fontColor)

      Text(this.time)
        .setTextStyles(50, this.colorsConfig.fontColor)
    }
    .width('100%')
  }
}