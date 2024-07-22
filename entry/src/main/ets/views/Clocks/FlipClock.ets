import animator, { AnimatorResult } from '@ohos.animator';
import measure from '@ohos.measure'
import { ClockController, ClockListener } from './ClockController'
import { ClockColorsConfig, DEFAULT_GLOBAL_CONFIG, GlobalClockConfig } from './ClockConfig'
import { DateUtils } from '../../common/utils/DateUtils';

// const fontStyle = 'flip-num-font'
const fontStyle = ''

@Extend(Text)
function setTextStyles(fontSize: number, fontColor: ResourceColor, baselineOffset: number, space: number) {
  .fontFamily(fontStyle)
  .fontSize(fontSize)
  .fontColor(fontColor)
  .fontWeight(FontWeight.Medium)
  .textAlign(TextAlign.Center)
  .lineHeight(fontSize * 0.5)
  .baselineOffset(baselineOffset)
  .height((fontSize - space) * 0.5)
}

export class FlipCardController {
  onChange: (next: string) => void = () => {
  }

  public change(next: string) {
    this.onChange(next)
  }
}

@Component({ freezeWhenInactive: true })
export struct FlipClock {
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
  private hourController: FlipCardController = new FlipCardController()
  private minuteController: FlipCardController = new FlipCardController()
  private secondController: FlipCardController = new FlipCardController()
  private listener: ClockListener = {
    onUpdate: (date) => {
      const hours = this.globalConfig.use24HourFormat ? date.getHours() : DateUtils.get12Hour(date)
      this.hourController.change(hours.toString().padStart(2, '0'))
      this.minuteController.change(date.getMinutes().toString().padStart(2, '0'))
      this.secondController.change(date.getSeconds().toString().padStart(2, '0'))
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
      alignItems: ItemAlign.Center
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

      this.FlipCards()

      // 为了让时钟居中，所以放个空元素
      Row()
        .width(50)
        .height(50)
    }
  }

  @Builder
  FlipCards() {
    FlipCard({
      fontSize: this.fontSize,
      fontColor: this.colorsConfig.fontColor,
      color: this.colorsConfig.cardColor,
      space: this.space,
      current: this.hours,
      controller: this.hourController
    })

    Blank()
      .width(24)
      .height(24)

    FlipCard({
      fontSize: this.fontSize,
      fontColor: this.colorsConfig.fontColor,
      color: this.colorsConfig.cardColor,
      space: this.space,
      current: this.minutes,
      controller: this.minuteController
    })

    Blank()
      .width(24)
      .height(24)

    FlipCard({
      fontSize: this.fontSize,
      fontColor: this.colorsConfig.fontColor,
      color: this.colorsConfig.cardColor,
      space: this.space,
      current: this.seconds,
      next: this.seconds,
      controller: this.secondController
    })
  }
}

@Component
export struct FlipCard {
  @State space: number = 6
  @Prop fontSize: number = 60
  @Prop fontColor: ResourceColor = $r('app.color.flip_text_color')
  @Prop color: ResourceColor = $r('app.color.flip_card_bg_color')
  @State horizontalMargin: number = 12
  @State verticalMargin: number = 20
  @State prev: string = '00'
  @State current: string = '00'
  @State next: string = '00'
  @State isFlipping: boolean = false
  @State angle: number = 0
  private animator: AnimatorResult = animator.create({
    duration: 900,
    easing: 'ease',
    delay: 0,
    fill: 'none',
    direction: 'normal',
    iterations: 1,
    begin: 0,
    end: 1
  })
  private controller: FlipCardController = new FlipCardController()

  aboutToAppear(): void {
    this.prev = this.current

    this.controller.onChange = (next) => {
      if (this.current == next) {
        return
      }
      this.next = next
      this.current = this.next
      this.startAnimator()
    }
  }

  startAnimator() {
    this.animator.onframe = (progress: number) => {
      this.angle = -180 * progress
      this.isFlipping = true
    };
    this.animator.onfinish = () => {
      this.angle = -180
      this.isFlipping = false

      this.prev = this.current
      this.next = (parseInt(this.next) + 1).toString()
    }
    this.animator.play();
  }

  build() {
    Column({ space: this.space }) {
      Stack() {
        HalfCard({
          text: this.current,
          fontSize: this.fontSize,
          fontColor: this.fontColor,
          color: this.color,
          space: this.space,
          type: HalfCardType.Top,
          horizontalMargin: this.horizontalMargin,
          verticalMargin: this.verticalMargin
        })

        Column() {
          Stack() {
            HalfCard({
              text: this.current,
              fontSize: this.fontSize,
              fontColor: this.fontColor,
              color: this.color,
              space: this.space,
              type: HalfCardType.Bottom,
              horizontalMargin: this.horizontalMargin,
              verticalMargin: this.verticalMargin
            })
              .opacity(this.angle <= -90 ? 1 : 0)
              .rotate({
                x: 1,
                centerY: '50%',
                angle: 180
              })

            HalfCard({
              text: this.prev,
              fontSize: this.fontSize,
              fontColor: this.fontColor,
              color: this.color,
              space: this.space,
              type: HalfCardType.Top,
              horizontalMargin: this.horizontalMargin,
              verticalMargin: this.verticalMargin
            })
              .opacity(this.angle > -90 ? 1 : 0)
          }
          .zIndex(1)
          .rotate({
            x: 1,
            centerY: this.fontSize * 0.5 + this.verticalMargin,
            angle: this.angle
          })
          .visibility(this.isFlipping ? Visibility.Visible : Visibility.Hidden)
        }
      }
      .zIndex(1)

      Stack() {
        HalfCard({
          text: this.current,
          fontSize: this.fontSize,
          fontColor: this.fontColor,
          color: this.color,
          space: this.space,
          type: HalfCardType.Bottom,
          horizontalMargin: this.horizontalMargin,
          verticalMargin: this.verticalMargin
        })

        HalfCard({
          text: this.prev,
          fontSize: this.fontSize,
          fontColor: this.fontColor,
          color: this.color,
          space: this.space,
          type: HalfCardType.Bottom,
          horizontalMargin: this.horizontalMargin,
          verticalMargin: this.verticalMargin
        })
          .visibility(this.isFlipping ? Visibility.Visible : Visibility.Hidden)
      }
    }
  }
}

enum HalfCardType {
  Top,
  Bottom
}

@Component
export struct HalfCard {
  @Prop color: ResourceColor = $r('app.color.flip_card_bg_color')
  @Prop fontColor: ResourceColor = $r('app.color.flip_text_color')
  @Prop fontSize: number = 60
  @Prop horizontalMargin: number = 0
  @Prop verticalMargin: number = 0
  @Prop type: HalfCardType = HalfCardType.Top
  @Prop space: number = 0
  @Prop text: string = ''
  @Prop radius: number = 8
  @State textWidth: number = this.fontSize

  aboutToAppear(): void {
    let maxWidth = 0
    for (let i = 0; i < 10; i++) {
      const text = `${i}${i}`
      const size = measure.measureTextSize({
        textContent: text,
        fontSize: `${this.fontSize}px`,
        fontFamily: fontStyle,
        fontWeight: FontWeight.Medium
      })
      let width = Math.max(size.width as number, size.height as number)
      if (width > maxWidth) {
        maxWidth = width
      }
    }
    this.textWidth = maxWidth
  }

  build() {
    Column() {
      Text(this.text)
        .setTextStyles(this.fontSize, this.fontColor, this.type === HalfCardType.Top ? this.fontSize * 0.5 : 0, this.space)
        .width(this.textWidth)
    }
    .padding({
      left: this.horizontalMargin,
      right: this.horizontalMargin,
      top: this.type == HalfCardType.Top ? this.verticalMargin : 0,
      bottom: this.type == HalfCardType.Bottom ? this.verticalMargin : 0
    })
    .backgroundColor(this.color)
    .justifyContent(this.type == HalfCardType.Top ? FlexAlign.End : FlexAlign.Start)
    .borderRadius({
      topLeft: this.type == HalfCardType.Top ? this.radius : 0,
      topRight: this.type == HalfCardType.Top ? this.radius : 0,
      bottomLeft: this.type == HalfCardType.Bottom ? this.radius : 0,
      bottomRight: this.type == HalfCardType.Bottom ? this.radius : 0,
    })
  }
}