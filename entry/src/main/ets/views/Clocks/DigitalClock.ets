import { ClockController, ClockListener } from './ClockController'

@Extend(Text)
function setTextStyles(fontSize: number) {
  .fontFamily('digital-num-font')
  .fontSize(fontSize)
  .fontColor($r('app.color.flip_text_color'))
  .fontWeight(FontWeight.Bold)
  .textAlign(TextAlign.Center)
  .width('100%')
}

export class DigitalClockController {
  onChange: (date: Date) => void = () => {
  }

  public change(date: Date) {
    this.onChange(date)
  }
}

@Component
export struct DigitalClock {
  controller: ClockController = new ClockController()
  date: Date = new Date()
  @State canvasWidth: number = 300; // 300是表盘默认大小
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
      this.hours = date.getHours().toString().padStart(2, '0')
      this.minutes = date.getMinutes().toString().padStart(2, '0')
      this.seconds = date.getSeconds().toString().padStart(2, '0')
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
        .setTextStyles(28)

      Text(this.day)
        .setTextStyles(32)

      Text(this.week)
        .setTextStyles(36)

      Text(this.time)
        .setTextStyles(40)
    }
    .width('100%')
  }
}