import { ClockController, ClockListener } from './ClockController'
import { ClockColorsConfig, ClockStyle, DEFAULT_GLOBAL_CONFIG, GlobalClockConfig } from './ClockConfig';
import { chinesCalendar, DateUtils } from '../../common/utils/DateUtils';

const FONT_FAMILY = 'digital-num-font'

@Extend(Text)
function setTextStyles(fontSize: number, fontColor: ResourceColor) {
  .fontFamily(FONT_FAMILY)
  .fontSize(fontSize)
  .fontColor(fontColor)
}

@Component({ freezeWhenInactive: true })
export struct LunarCalendarClock {
  controller: ClockController = new ClockController()
  date: Date = new Date()
  @Prop style: ClockStyle = ClockStyle.Style1
  @Prop colorsConfig: ClockColorsConfig = {
    backgroundColor: $r('app.color.main_background_color'),
    cardColor: $r('app.color.flip_card_bg_color'),
    fontColor: $r('app.color.flip_text_color')
  }
  @Prop globalConfig: GlobalClockConfig = DEFAULT_GLOBAL_CONFIG
  @Prop isLandscape: boolean = false
  @State year: string = '----'
  @State month: string = ''
  @State day: string = ''
  @State week: string = '-'
  @State hours: string = '00'
  @State minutes: string = '00'
  @State seconds: string = '00'
  @State chineseMonth: string = '' // 农历月份
  @State chineseDay: string = '' // 农历日期
  private listener: ClockListener = {
    onUpdate: (date) => {
      this.year = date.getFullYear().toString()
      this.month = (date.getMonth() + 1).toString().padStart(2, '0')
      this.day = date.getDate().toString().padStart(2, '0')

      const hours = this.globalConfig.use24HourFormat ? date.getHours() : DateUtils.get12Hour(date)
      this.hours = hours.toString().padStart(2, '0')
      this.minutes = date.getMinutes().toString().padStart(2, '0')
      this.seconds = date.getSeconds().toString().padStart(2, '0')
      this.week = date.getDay().toString()

      chinesCalendar.setTime(date)
      this.chineseMonth = chinesCalendar.get('month').toString().padStart(2, '0')
      this.chineseDay = chinesCalendar.get('date').toString().padStart(2, '0')
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
    if (this.style == ClockStyle.Style1) {
      this.Style1()
    } else if (this.style == ClockStyle.Style2) {
      this.Style2()
    }
  }

  @Builder
  Style1() {
    Column({ space: 8 }) {
      Text(`${this.hours}:${this.minutes}`)
        .setTextStyles(100, this.colorsConfig.fontColor)
        .fontWeight(FontWeight.Medium)
        .minFontSize(60)
        .maxFontSize(120)
        .maxLines(1)

      Row() {
        Text() {
          Span('农历')
          Span(this.chineseMonth)
            .fontFamily(FONT_FAMILY)
            .fontSize(40)
          Span('月')
          Span(this.chineseDay)
            .fontFamily(FONT_FAMILY)
            .fontSize(40)
          Span('日')
        }
        .fontSize(28)
        .fontColor(this.colorsConfig.fontColor)

        Blank()
          .layoutWeight(1)

        Text() {
          Span('星期')
          Span(this.week)
            .fontFamily(FONT_FAMILY)
            .fontSize(40)
        }
        .fontSize(28)
        .fontColor(this.colorsConfig.fontColor)
      }
      .alignItems(VerticalAlign.Bottom)

      Text() {
        Span(this.year)
          .fontFamily(FONT_FAMILY)
          .fontSize(40)
        Span('年')
        Span(this.month)
          .fontFamily(FONT_FAMILY)
          .fontSize(40)
        Span('月')
        Span(this.day)
          .fontFamily(FONT_FAMILY)
          .fontSize(40)
        Span('日')
      }
      .fontSize(28)
      .fontColor(this.colorsConfig.fontColor)
      .width('100%')
    }
    .width('100%')
    .padding({ left: this.isLandscape ? 40 : 24, right: this.isLandscape ? 40 : 24 })
  }

  @Builder
  Style2() {
    Flex({
      justifyContent: FlexAlign.SpaceBetween,
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Center,
      wrap: FlexWrap.Wrap
    }) {
      Text(`${this.hours}:${this.minutes}`)
        .setTextStyles(100, this.colorsConfig.fontColor)
        .fontWeight(FontWeight.Medium)
        .maxFontSize(120)
        .minFontSize(60)
        .maxLines(1)

      Column({ space: 12 }) {
        Row() {
          Text('新\n历')
            .fontSize(24)
            .fontColor(this.colorsConfig.fontColor)
            .margin({ right: 8 })

          Text() {
            Span(this.month)
              .fontFamily(FONT_FAMILY)
              .fontSize(40)
            Span('月')
            Span(this.day)
              .fontFamily(FONT_FAMILY)
              .fontSize(40)
            Span('日')
          }
          .fontSize(28)
          .fontColor(this.colorsConfig.fontColor)
        }
        .alignItems(VerticalAlign.Bottom)

        Row() {
          Text('农\n历')
            .fontSize(24)
            .fontColor(this.colorsConfig.fontColor)
            .margin({ right: 8 })

          Text() {
            Span(this.chineseMonth)
              .fontFamily(FONT_FAMILY)
              .fontSize(40)
            Span('月')
            Span(this.chineseDay)
              .fontFamily(FONT_FAMILY)
              .fontSize(40)
            Span('日')
          }
          .fontSize(28)
          .fontColor(this.colorsConfig.fontColor)
        }

        Text() {
          Span('星期')
          Span(this.week)
            .fontFamily(FONT_FAMILY)
            .fontSize(40)
        }
        .fontSize(28)
        .fontColor(this.colorsConfig.fontColor)
      }
    }
    .padding({ left: this.isLandscape ? 40 : 24, right: this.isLandscape ? 40 : 24 })
  }
}