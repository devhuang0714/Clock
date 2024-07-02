import { ClockController, ClockListener } from './ClockController'
import I18n from '@ohos.i18n';

const FONT_FAMILY = 'digital-num-font'

@Extend(Text)
function setTextStyles(fontSize: number) {
  .fontFamily(FONT_FAMILY)
  .fontSize(fontSize)
  .fontColor($r('app.color.flip_text_color'))
}

export enum LunarCalendarClockType {
  Style1,
  Style2
}

@Component({ freezeWhenInactive: true })
export struct LunarCalendarClock {
  controller: ClockController = new ClockController()
  date: Date = new Date()
  @Prop type: LunarCalendarClockType = LunarCalendarClockType.Style1
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
      this.hours = date.getHours().toString().padStart(2, '0')
      this.minutes = date.getMinutes().toString().padStart(2, '0')
      this.seconds = date.getSeconds().toString().padStart(2, '0')
      this.week = date.getDay().toString()

      // 获取农历日期
      let calendar: I18n.Calendar = I18n.getCalendar("zh-Hans", "chinese");
      //将公历信息设置到calendar对象
      calendar.setTime(date);
      //获取农历年月日
      // calendar.get("year"); // 返回干支纪年40，范围1-60
      this.chineseMonth = calendar.get("month").toString().padStart(2, '0'); // 结果为5，指6月
      this.chineseDay = calendar.get("date").toString().padStart(2, '0'); // 8日
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
    if (this.type == LunarCalendarClockType.Style1) {
      this.Style1()
    } else if (this.type == LunarCalendarClockType.Style2) {
      this.Style2()
    }
  }

  @Builder
  Style1() {
    Column({ space: 8 }) {
      Text(`${this.hours}:${this.minutes}`)
        .setTextStyles(100)
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

        Blank()
          .layoutWeight(1)

        Text() {
          Span('星期')
          Span(this.week)
            .fontFamily(FONT_FAMILY)
            .fontSize(40)
        }
        .fontSize(28)
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
        .setTextStyles(100)
        .fontWeight(FontWeight.Medium)
        .maxFontSize(120)
        .minFontSize(60)
        .maxLines(1)

      Column({ space: 12 }) {
        Row() {
          Text('新\n历')
            .fontSize(24)
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
        }
        .alignItems(VerticalAlign.Bottom)

        Row() {
          Text('农\n历')
            .fontSize(24)
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
        }

        Text() {
          Span('星期')
          Span(this.week)
            .fontFamily(FONT_FAMILY)
            .fontSize(40)
        }
        .fontSize(28)
      }
    }
    .padding({ left: this.isLandscape ? 40 : 24, right: this.isLandscape ? 40 : 24 })
  }
}