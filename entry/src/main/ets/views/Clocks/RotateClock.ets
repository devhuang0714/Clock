import { ClockController, ClockListener } from './ClockController'
import animator, { AnimatorResult } from '@ohos.animator';
import measure from '@ohos.measure'
import { ClockColorsConfig, ClockStyle, DEFAULT_GLOBAL_CONFIG, GlobalClockConfig } from './ClockConfig';
import { DateUtils } from '../../common/utils/DateUtils';

@Extend(Text)
function setTextStyles(fontSize: number, fontColor: ResourceColor) {
  .fontSize(fontSize)
  .fontColor(fontColor)
  .fontWeight(FontWeight.Medium)
  .textAlign(TextAlign.Center)
  .width('100%')
}

@Component({ freezeWhenInactive: true })
export struct RotateClock {
  controller: ClockController = new ClockController()
  date: Date = new Date()
  /**
   * Style1 时分秒
   * Style2 mini秒
   * Style3 不显示秒
   */
  @Prop style: ClockStyle = ClockStyle.Style1
  @Prop colorsConfig: ClockColorsConfig = {
    backgroundColor: $r('app.color.main_background_color'),
    cardColor: $r('app.color.flip_card_bg_color'),
    fontColor: $r('app.color.flip_text_color')
  }
  @Prop globalConfig: GlobalClockConfig = DEFAULT_GLOBAL_CONFIG
  @Prop isLandscape: boolean = false
  @Prop lightOn: boolean = false
  @State isPM: boolean = false
  @State hoursTens: number = 0 // 十位
  @State hoursUnits: number = 0 // 个位
  @State minutesTens: number = 0
  @State minutesUnits: number = 0
  @State secondsTens: number = 0
  @State secondsUnits: number = 0
  @State seconds: number = 0
  private listener: ClockListener = {
    onUpdate: (date) => {
      const hours = this.globalConfig.use24HourFormat ? date.getHours() : DateUtils.get12Hour(date)
      this.hoursTens = Math.floor(hours / 10) % 10
      this.hoursUnits = hours % 10

      this.minutesTens = Math.floor(date.getMinutes() / 10) % 10
      this.minutesUnits = date.getMinutes() % 10

      this.secondsTens = Math.floor(date.getSeconds() / 10) % 10
      this.secondsUnits = date.getSeconds() % 10

      this.seconds = date.getSeconds()

      this.hoursTensController.change(this.hoursTens)
      this.hoursUnitsController.change(this.hoursUnits)
      this.minutesTensController.change(this.minutesTens)
      this.minutesUnitsController.change(this.minutesUnits)
      this.secondsTensController.change(this.secondsTens)
      this.secondsUnitsController.change(this.secondsUnits)
      this.secondsController.change(this.seconds)

      this.isPM = date.getHours() >= 12
    }
  }
  private hoursTensController: RotateCardController = new RotateCardController()
  private hoursUnitsController: RotateCardController = new RotateCardController()
  private minutesTensController: RotateCardController = new RotateCardController()
  private minutesUnitsController: RotateCardController = new RotateCardController()
  private secondsTensController: RotateCardController = new RotateCardController()
  private secondsUnitsController: RotateCardController = new RotateCardController()
  private secondsController: RotateCardController = new RotateCardController()

  aboutToAppear(): void {
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

      this.RotateCards()

      // 为了让时钟居中，所以放个空元素
      Row()
        .width(50)
        .height(50)
    }
  }

  @Builder
  RotateCards() {
    Row({ space: 12 }) {
      RotateCard({
        controller: this.hoursTensController,
        num: this.hoursTens,
        lightOn: this.lightOn,
        fontColor: this.colorsConfig.fontColor,
        color: this.colorsConfig.cardColor
      })

      RotateCard({
        controller: this.hoursUnitsController,
        num: this.hoursUnits,
        lightOn: this.lightOn,
        fontColor: this.colorsConfig.fontColor,
        color: this.colorsConfig.cardColor
      })
    }

    Blank()
      .width(0)
      .height(24)

    if (this.isLandscape) {
      Text(':')
        .fontSize(120)
        .fontColor(this.colorsConfig.fontColor)
        .margin({ left: 8, right: 8 })
    }

    Row({ space: 12 }) {
      RotateCard({
        controller: this.minutesTensController,
        num: this.minutesTens,
        lightOn: this.lightOn,
        fontColor: this.colorsConfig.fontColor,
        color: this.colorsConfig.cardColor
      })

      RotateCard({
        controller: this.minutesUnitsController,
        num: this.minutesUnits,
        lightOn: this.lightOn,
        fontColor: this.colorsConfig.fontColor,
        color: this.colorsConfig.cardColor
      })
    }

    Blank()
      .width(0)
      .height(24)

    if (this.style == ClockStyle.Style1) {
      if (this.isLandscape) {
        Text(':')
          .fontSize(120)
          .fontColor(this.colorsConfig.fontColor)
          .margin({ left: 8, right: 8 })
      }

      Row({ space: 12 }) {
        RotateCard({
          controller: this.secondsTensController,
          num: this.secondsTens,
          lightOn: this.lightOn,
          fontColor: this.colorsConfig.fontColor,
          color: this.colorsConfig.cardColor,
          duration: 900
        })

        RotateCard({
          controller: this.secondsUnitsController,
          num: this.secondsUnits,
          lightOn: this.lightOn,
          fontColor: this.colorsConfig.fontColor,
          color: this.colorsConfig.cardColor,
          duration: 900
        })
      }
    } else if (this.style == ClockStyle.Style2) {
      Blank()
        .width(36)
        .aspectRatio(1)

      RotateCard({
        controller: this.secondsController,
        num: this.seconds,
        lightOn: this.lightOn,
        fontColor: this.colorsConfig.fontColor,
        color: this.colorsConfig.cardColor,
        fontSize: 30,
        horizontalMargin: 3,
        verticalMargin: 5,
        duration: 950,
        maxLength: 2
      })
    }
  }
}

class RotateCardController {
  onChange: (next: number) => void = () => {
  }

  public change(next: number) {
    this.onChange(next)
  }
}

@Component
struct RotateCard {
  controller: RotateCardController = new RotateCardController()
  duration: number = 1000
  @Prop fontSize: number = 130
  @Prop fontColor: ResourceColor = $r('app.color.flip_text_color')
  @Prop color: ResourceColor = $r('app.color.flip_card_bg_color')
  @State num: number = 0
  @State next: number = 0
  @State horizontalMargin: number = 10
  @State verticalMargin: number = 0
  @Prop lightOn: boolean = false
  @State maxLength: number = 1
  @State angle: number = 0
  @State cardWidth: number = 100
  @State cardHeight: number = 100
  private animator: AnimatorResult | null = null

  aboutToAppear(): void {
    const size = measure.measureTextSize({
      textContent: '0'.repeat(this.maxLength),
      fontSize: `${this.fontSize}px`,
      fontWeight: FontWeight.Medium
    })

    this.cardWidth = size.width as number + this.horizontalMargin * 2
    this.cardHeight = size.height as number + this.verticalMargin * 2

    this.animator = animator.create({
      duration: this.duration,
      easing: 'linear',
      delay: 0,
      fill: 'none',
      direction: 'normal',
      iterations: 1,
      begin: 0,
      end: 1
    })

    this.controller.onChange = (next) => {
      if (this.num == next) {
        return
      }
      this.next = next
      this.startAnimator()
    }
  }

  startAnimator() {
    if (this.animator == null) {
      return
    }

    this.animator.onframe = (progress: number) => {
      this.angle = -60 * progress
    };
    this.animator.onfinish = () => {
      this.num = this.next
      this.angle = 0
    }
    this.animator.play();
  }

  build() {
    Stack() {
      Row() {
        Text(this.next.toString().padStart(this.maxLength, '0'))
          .setTextStyles(this.fontSize, this.fontColor)
      }
      .width('100%')
      .height(this.cardHeight)
      .backgroundColor(this.color)
      .borderRadius(8)
      .rotate({
        x: 1,
        centerZ: this.cardHeight * 3,
        angle: this.angle + 60
      })

      Row() {
        Text(this.num.toString().padStart(this.maxLength, '0'))
          .setTextStyles(this.fontSize, this.fontColor)
      }
      .width('100%')
      .height(this.cardHeight)
      .backgroundColor(this.color)
      .borderRadius(8)
      .rotate({
        x: 1,
        centerZ: this.cardHeight * 3,
        angle: this.angle
      })

      if (this.lightOn) {
        Row()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Top,
            colors: [
              [0x997E1F11, 0.0],
              [0x337E1F11, 0.2],
              [0x117E1F11, 0.4],
              [Color.Transparent, 0.6],
              [Color.Transparent, 0.7],
              [0x777E1F11, 1.0],
            ]
          })
      } else {
        Row()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            repeating: false, // 渐变颜色是否重复
            colors: [
              [0x77000000, 0.0],
              [Color.Transparent, 0.2],
              [Color.Transparent, 0.8],
              [0x77000000, 1]
            ]
          })
      }
    }
    .width(this.cardWidth)
    .height(this.cardHeight)
    .backgroundColor(Color.Transparent)
    .borderRadius(8)
    .clip(true)
  }
}