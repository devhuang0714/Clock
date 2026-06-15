import { ClockController, ClockListener } from './ClockController'

@Component({ freezeWhenInactive: true })
export struct MechanicalClock {
  controller: ClockController = new ClockController()
  date: Date = new Date()
  @Prop isLandscape: boolean = false
  @State hourAngle: number = 0
  @State minuteAngle: number = 0
  @State secondAngle: number = 0
  private listener: ClockListener = {
    onUpdate: (date) => {
      const milliseconds = date.getMilliseconds()
      const seconds = date.getSeconds() + milliseconds / 1000
      const minutes = date.getMinutes() + seconds / 60
      const hours = date.getHours() % 12 + minutes / 60

      this.secondAngle = seconds * 6
      this.minuteAngle = minutes * 6
      this.hourAngle = hours * 30
    }
  }

  aboutToAppear(): void {
    this.controller.registerListener(this.listener)
    this.listener.onUpdate(this.date)
  }

  aboutToDisappear(): void {
    this.controller.unregisterListener(this.listener)
  }

  getClockSize(): number {
    return this.isLandscape ? 360 : 360
  }

  build() {
    Stack() {
      Image($r('app.media.mechanical_clock_face'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)

      Image($r('app.media.mechanical_hour_hand'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
        .rotate({ angle: this.hourAngle })

      Image($r('app.media.mechanical_minute_hand'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
        .rotate({ angle: this.minuteAngle })

      Image($r('app.media.mechanical_second_hand'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
        .rotate({ angle: this.secondAngle })

      Image($r('app.media.mechanical_center_cap'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
    }
    .width(this.getClockSize())
    .height(this.getClockSize())
  }
}
