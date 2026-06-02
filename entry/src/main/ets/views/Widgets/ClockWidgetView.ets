import { DateUtils } from '../../common/utils/DateUtils'
import {
  ClockWidgetConfig,
  ClockWidgetRoundStyle,
  ClockWidgetSize,
  ClockWidgetStyleType,
  CLOCK_WIDGET_CONFIGS
} from './ClockWidgetConfig'

const CLOCK_WIDGET_TICKS: number[] = [
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
  20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
  30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
  40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
  50, 51, 52, 53, 54, 55, 56, 57, 58, 59
]
const CLOCK_WIDGET_HOURS: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
const CLOCK_WIDGET_DOTS: number[] = [
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23
]
const CLOCK_WIDGET_NUMBER_LABELS: string[] = ['12', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11']
const CLOCK_WIDGET_ROMAN_LABELS: string[] = ['XII', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI']
const CLOCK_WIDGET_PASTEL_COLORS: ResourceColor[] = ['#FF8FC7', '#7FD9FF', '#FFF08A', '#B9EFA7']

@Component
export struct ClockWidgetView {
  @Prop config: ClockWidgetConfig = CLOCK_WIDGET_CONFIGS[0]
  @Prop widgetSize: ClockWidgetSize = ClockWidgetSize.Size2x2
  @State nowTime: number = new Date().getTime()

  private onMinuteChange(timestamp: number) {
    this.nowTime = this.createValidTime(timestamp)
  }

  private createValidTime(timestamp: number): number {
    if (timestamp > 0) {
      let milliseconds = timestamp
      if (milliseconds < 100000000000) {
        milliseconds = milliseconds * 1000
      }
      if (this.isValidTime(new Date(milliseconds).getTime())) {
        return milliseconds
      }
    }
    return new Date().getTime()
  }

  private isValidTime(time: number): boolean {
    return time >= 0 || time < 0
  }

  private getCurrentDate(): Date {
    const date = new Date(this.nowTime)
    if (this.isValidTime(date.getTime())) {
      return date
    }
    return new Date()
  }

  private getDateText(): string {
    const date = this.getCurrentDate()
    return `${DateUtils.formatDate(date, 'MM-dd')} ${DateUtils.getWeek_ZH(date.getDay())}`
  }

  private getLunarText(): string {
    return DateUtils.formatLunarDate(this.getCurrentDate())
  }

  private getPeriodText(): string {
    return DateUtils.getPeriod(this.getCurrentDate().getHours())
  }

  private getHourAngle(): number {
    const date = this.getCurrentDate()
    return (date.getHours() % 12) * 30 + date.getMinutes() * 0.5
  }

  private getMinuteAngle(): number {
    return this.getCurrentDate().getMinutes() * 6
  }

  private getRoundStyle(): ClockWidgetRoundStyle {
    return this.config.roundStyle ?? ClockWidgetRoundStyle.Classic
  }

  private getRoundDialSize(): number {
    if (this.widgetSize == ClockWidgetSize.Size4x4) {
      return 192
    }
    if (this.widgetSize == ClockWidgetSize.Size2x4) {
      return 132
    }
    return 118
  }

  private getRoundRadius(): number {
    return this.getRoundDialSize() * 0.5
  }

  private getRoundTickOuterRadius(): number {
    return this.getRoundRadius() - (this.widgetSize == ClockWidgetSize.Size4x4 ? 8 : 6)
  }

  private getRoundMajorTickLength(): number {
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Classic) {
      return this.getRoundRadius() * 0.12
    }
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Retro) {
      return this.getRoundRadius() * 0.18
    }
    return this.getRoundRadius() * 0.14
  }

  private getRoundMinorTickLength(): number {
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Classic) {
      return this.getRoundRadius() * 0.08
    }
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Retro) {
      return this.getRoundRadius() * 0.09
    }
    return this.getRoundRadius() * 0.07
  }

  private getRoundHourLabelRadius(): number {
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Classic) {
      return this.getRoundRadius() * 0.62
    }
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Cyberpunk) {
      return this.getRoundRadius() * 0.5
    }
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Cute) {
      return this.getRoundRadius() * 0.6
    }
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Retro || this.getRoundStyle() == ClockWidgetRoundStyle.ArtDeco) {
      return this.getRoundRadius() * 0.54
    }
    return this.getRoundRadius() * 0.64
  }

  private getRoundHourLabelSize(): number {
    if (this.widgetSize == ClockWidgetSize.Size4x4) {
      return this.getRoundStyle() == ClockWidgetRoundStyle.Classic || this.getRoundStyle() == ClockWidgetRoundStyle.Cute ? 16 : 13
    }
    if (this.widgetSize == ClockWidgetSize.Size2x4) {
      return this.getRoundStyle() == ClockWidgetRoundStyle.Classic || this.getRoundStyle() == ClockWidgetRoundStyle.Cute ? 12 : 10
    }
    return this.getRoundStyle() == ClockWidgetRoundStyle.Classic || this.getRoundStyle() == ClockWidgetRoundStyle.Cute ? 11 : 9
  }

  private getRoundHourHandLength(): number {
    return this.getRoundRadius() * 0.46
  }

  private getRoundMinuteHandLength(): number {
    return this.getRoundRadius() * 0.58
  }

  private getRoundHourHandWidth(): number {
    return this.widgetSize == ClockWidgetSize.Size4x4 ? 7 : 5
  }

  private getRoundMinuteHandWidth(): number {
    return this.widgetSize == ClockWidgetSize.Size4x4 ? 4 : 3
  }

  private getRoundSecondaryColor(): ResourceColor {
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Cyberpunk) {
      return '#00F6FF'
    }
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Cute) {
      return '#7FD9FF'
    }
    if (this.getRoundStyle() == ClockWidgetRoundStyle.ArtDeco) {
      return '#62D0BB'
    }
    return this.config.colors.accentColor ?? this.config.colors.fontColor
  }

  private getRoundMajorTickColor(): ResourceColor {
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Classic) {
      return '#111111'
    }
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Cyberpunk) {
      return '#00F6FF'
    }
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Cute) {
      return '#FF8FC7'
    }
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Retro) {
      return '#6D3F1D'
    }
    return this.config.colors.accentColor ?? this.config.colors.fontColor
  }

  private getRoundMinorTickColor(): ResourceColor {
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Classic) {
      return '#C9C9C9'
    }
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Cyberpunk) {
      return '#FF2BD6'
    }
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Cute) {
      return '#EFBAD7'
    }
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Retro) {
      return '#B78B47'
    }
    return this.config.colors.mutedColor ?? this.config.colors.fontColor
  }

  private getRoundHourHandColor(): ResourceColor {
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Classic) {
      return '#111111'
    }
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Cyberpunk) {
      return '#00F6FF'
    }
    return this.config.colors.fontColor
  }

  private getRoundMinuteHandColor(): ResourceColor {
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Classic) {
      return '#111111'
    }
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Cyberpunk) {
      return '#FF2BD6'
    }
    return this.config.colors.accentColor ?? this.config.colors.fontColor
  }

  private getRoundCenterColor(): ResourceColor {
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Classic) {
      return this.config.colors.accentColor ?? '#D94D3D'
    }
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Cyberpunk) {
      return '#FF2BD6'
    }
    return this.config.colors.accentColor ?? this.config.colors.fontColor
  }

  private getPastelDotColor(index: number): ResourceColor {
    return CLOCK_WIDGET_PASTEL_COLORS[index % CLOCK_WIDGET_PASTEL_COLORS.length]
  }

  private getHorizontalPadding(): number {
    return this.widgetSize == ClockWidgetSize.Size2x2 ? 16 : 22
  }

  private getTimeFontSize(): number {
    if (this.widgetSize == ClockWidgetSize.Size2x2) {
      return 46
    }
    if (this.widgetSize == ClockWidgetSize.Size2x4) {
      return 58
    }
    return 72
  }

  build() {
    Stack() {
      if (this.config.type == ClockWidgetStyleType.Minimal) {
        this.MinimalWidget()
      } else if (this.config.type == ClockWidgetStyleType.Flip) {
        this.FlipWidget()
      } else if (this.config.type == ClockWidgetStyleType.Digital) {
        this.DigitalWidget()
      } else if (this.config.type == ClockWidgetStyleType.Round) {
        this.RoundWidget()
      } else if (this.config.type == ClockWidgetStyleType.Lunar) {
        this.LunarWidget()
      }
    }
    .width('100%')
    .height('100%')
    .clip(true)
    .borderRadius(24)
    .backgroundColor(this.config.colors.backgroundColor)
  }

  @Builder
  TimeText(fontSize: number, color: ResourceColor = this.config.colors.fontColor) {
    TextClock()
      .format('HH:mm')
      .onDateChange((value: number) => {
        this.onMinuteChange(value)
      })
      .fontSize(fontSize)
      .fontWeight(FontWeight.Bold)
      .fontColor(color)
      .width('100%')
  }

  @Builder
  MinimalWidget() {
    Column() {
      Text('FLIP CLOCK')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.config.colors.mutedColor ?? this.config.colors.fontColor)
        .width('100%')

      Blank()

      this.TimeText(this.getTimeFontSize())

      Text(this.getDateText())
        .fontSize(this.widgetSize == ClockWidgetSize.Size2x2 ? 13 : 16)
        .fontColor(this.config.colors.mutedColor ?? this.config.colors.fontColor)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      Blank()
    }
    .width('100%')
    .height('100%')
    .padding({
      top: 18,
      bottom: 16,
      left: this.getHorizontalPadding(),
      right: this.getHorizontalPadding()
    })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  FlipWidget() {
    Column() {
      Row() {
        Text(this.getDateText())
          .fontSize(this.widgetSize == ClockWidgetSize.Size4x4 ? 16 : 13)
          .fontColor(this.config.colors.mutedColor ?? this.config.colors.fontColor)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Blank()

        Text(this.getPeriodText())
          .fontSize(this.widgetSize == ClockWidgetSize.Size4x4 ? 16 : 13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.config.colors.accentColor ?? this.config.colors.fontColor)
      }
      .width('100%')

      Blank()

      Row({ space: this.widgetSize == ClockWidgetSize.Size4x4 ? 14 : 10 }) {
        this.FlipUnit('HH')
        Text(':')
          .fontSize(this.widgetSize == ClockWidgetSize.Size4x4 ? 42 : 32)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.config.colors.fontColor)
        this.FlipUnit('mm')
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')

      Blank()

      if (this.widgetSize == ClockWidgetSize.Size4x4) {
        Text('MINUTE CLOCK')
          .fontSize(13)
          .fontColor(this.config.colors.mutedColor ?? this.config.colors.fontColor)
      }
    }
    .width('100%')
    .height('100%')
    .padding({
      top: this.widgetSize == ClockWidgetSize.Size4x4 ? 26 : 18,
      bottom: this.widgetSize == ClockWidgetSize.Size4x4 ? 24 : 18,
      left: this.getHorizontalPadding(),
      right: this.getHorizontalPadding()
    })
  }

  @Builder
  FlipUnit(format: string) {
    Stack() {
      TextClock()
        .format(format)
        .onDateChange((value: number) => {
          this.onMinuteChange(value)
        })
        .fontSize(this.widgetSize == ClockWidgetSize.Size4x4 ? 58 : 46)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.config.colors.fontColor)
        .width('100%')

      Divider()
        .strokeWidth(this.widgetSize == ClockWidgetSize.Size4x4 ? 5 : 4)
        .color('#000000')
        .width('100%')
    }
    .width(this.widgetSize == ClockWidgetSize.Size4x4 ? 96 : 76)
    .height(this.widgetSize == ClockWidgetSize.Size4x4 ? 100 : 78)
    .borderRadius(12)
    .backgroundColor(this.config.colors.cardColor ?? '#EFEFEF')
    .shadow({
      radius: 10,
      color: '#22000000',
      offsetY: 4
    })
  }

  @Builder
  DigitalWidget() {
    Column() {
      Row() {
        Text('TIME')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.config.colors.accentColor ?? this.config.colors.fontColor)

        Blank()

        Text(this.getDateText())
          .fontSize(12)
          .fontColor(this.config.colors.mutedColor ?? this.config.colors.fontColor)
          .maxLines(1)
      }
      .width('100%')

      Blank()

      this.TimeText(this.widgetSize == ClockWidgetSize.Size2x2 ? 36 : this.getTimeFontSize(), this.config.colors.fontColor)

      Blank()

      if (this.widgetSize != ClockWidgetSize.Size2x2) {
        Row({ space: 8 }) {
          this.StatusPill('SYNC')
          this.StatusPill('MIN')
          this.StatusPill('24H')
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .padding({
      top: 18,
      bottom: 18,
      left: this.getHorizontalPadding(),
      right: this.getHorizontalPadding()
    })
  }

  @Builder
  StatusPill(label: string) {
    Text(label)
      .fontSize(11)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.config.colors.fontColor)
      .padding({ left: 9, right: 9, top: 4, bottom: 4 })
      .borderRadius(12)
      .backgroundColor(this.config.colors.cardColor ?? '#111A16')
  }

  @Builder
  RoundWidget() {
    if (this.widgetSize == ClockWidgetSize.Size2x4) {
      Row({ space: 16 }) {
        this.RoundFace()

        Column({ space: 8 }) {
          Text(this.config.title)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.config.colors.mutedColor ?? this.config.colors.fontColor)
            .maxLines(1)

          this.TimeText(40, this.config.colors.fontColor)

          Text(this.getDateText())
            .fontSize(13)
            .fontColor(this.config.colors.mutedColor ?? this.config.colors.fontColor)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height('100%')
      .padding({
        left: this.getHorizontalPadding(),
        right: this.getHorizontalPadding(),
        top: 18,
        bottom: 18
      })
      .alignItems(VerticalAlign.Center)
    } else {
      Column({ space: 12 }) {
        this.RoundFace()

        if (this.widgetSize == ClockWidgetSize.Size4x4) {
          Text(this.getDateText())
            .fontSize(14)
            .fontColor(this.config.colors.mutedColor ?? this.config.colors.fontColor)
            .maxLines(1)
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .padding(16)
    }
  }

  @Builder
  RoundFace() {
    Stack() {
      this.RoundFaceBase()

      if (this.getRoundStyle() == ClockWidgetRoundStyle.Classic) {
        this.RoundTicks()
        this.RoundHourLabels(CLOCK_WIDGET_NUMBER_LABELS)
      } else if (this.getRoundStyle() == ClockWidgetRoundStyle.Cool) {
        this.RoundTicks()
        this.RoundDotMarkers()
      } else if (this.getRoundStyle() == ClockWidgetRoundStyle.Cyberpunk) {
        this.RoundCyberpunkMarks()
        this.RoundHourLabels(CLOCK_WIDGET_NUMBER_LABELS)
      } else if (this.getRoundStyle() == ClockWidgetRoundStyle.Cute) {
        this.RoundPastelDots()
        this.RoundTicks()
        this.RoundHourLabels(CLOCK_WIDGET_NUMBER_LABELS)
      } else if (this.getRoundStyle() == ClockWidgetRoundStyle.Retro) {
        this.RoundTicks()
        this.RoundHourLabels(CLOCK_WIDGET_ROMAN_LABELS)
      } else if (this.getRoundStyle() == ClockWidgetRoundStyle.ArtDeco) {
        this.RoundDecoSpokes()
        this.RoundDiamondMarkers()
        this.RoundHourLabels(CLOCK_WIDGET_ROMAN_LABELS)
      }

      this.RoundHand(this.getHourAngle(), this.getRoundHourHandWidth(), this.getRoundHourHandLength(),
        this.getRoundHourHandColor())
      this.RoundHand(this.getMinuteAngle(), this.getRoundMinuteHandWidth(), this.getRoundMinuteHandLength(),
        this.getRoundMinuteHandColor())

      Circle()
        .width(this.widgetSize == ClockWidgetSize.Size4x4 ? 24 : 18)
        .height(this.widgetSize == ClockWidgetSize.Size4x4 ? 24 : 18)
        .fill(this.config.colors.cardColor ?? this.config.colors.backgroundColor)
        .stroke(this.getRoundCenterColor())
        .strokeWidth(this.widgetSize == ClockWidgetSize.Size4x4 ? 4 : 3)

      Circle()
        .width(this.widgetSize == ClockWidgetSize.Size4x4 ? 12 : 9)
        .height(this.widgetSize == ClockWidgetSize.Size4x4 ? 12 : 9)
        .fill(this.getRoundCenterColor())

      TextClock()
        .format('HH:mm')
        .onDateChange((value: number) => {
          this.onMinuteChange(value)
        })
        .fontSize(1)
        .fontColor(Color.Transparent)
    }
    .width(this.getRoundDialSize())
    .height(this.getRoundDialSize())
  }

  @Builder
  RoundFaceBase() {
    if (this.getRoundStyle() == ClockWidgetRoundStyle.Classic) {
      Circle()
        .width(this.getRoundDialSize())
        .height(this.getRoundDialSize())
        .fill(this.config.colors.cardColor ?? '#FFFFFF')
        .stroke('#FFFFFF')
        .strokeWidth(this.getRoundRadius() * 0.04)

      Circle()
        .width(this.getRoundDialSize() * 0.94)
        .height(this.getRoundDialSize() * 0.94)
        .fill(Color.Transparent)
        .stroke('#EEEEEE')
        .strokeWidth(this.getRoundRadius() * 0.02)
    } else if (this.getRoundStyle() == ClockWidgetRoundStyle.Cool) {
      Circle()
        .width(this.getRoundDialSize())
        .height(this.getRoundDialSize())
        .fill(this.config.colors.cardColor ?? '#0B1E2A')
        .stroke('#8FF7FF')
        .strokeWidth(this.getRoundRadius() * 0.035)

      Circle()
        .width(this.getRoundDialSize() * 0.88)
        .height(this.getRoundDialSize() * 0.88)
        .fill(Color.Transparent)
        .stroke('#304A56')
        .strokeWidth(this.getRoundRadius() * 0.018)

      Circle()
        .width(this.getRoundDialSize() * 0.52)
        .height(this.getRoundDialSize() * 0.52)
        .fill(Color.Transparent)
        .stroke('#20313A')
        .strokeWidth(1)
    } else if (this.getRoundStyle() == ClockWidgetRoundStyle.Cyberpunk) {
      Circle()
        .width(this.getRoundDialSize())
        .height(this.getRoundDialSize())
        .fill(this.config.colors.cardColor ?? '#11071F')
        .stroke('#FF2BD6')
        .strokeWidth(this.getRoundRadius() * 0.028)

      Circle()
        .width(this.getRoundDialSize() * 0.88)
        .height(this.getRoundDialSize() * 0.88)
        .fill(Color.Transparent)
        .stroke('#00F6FF')
        .strokeWidth(this.getRoundRadius() * 0.018)
    } else if (this.getRoundStyle() == ClockWidgetRoundStyle.Cute) {
      Circle()
        .width(this.getRoundDialSize())
        .height(this.getRoundDialSize())
        .fill(this.config.colors.cardColor ?? '#FFE1F0')
        .stroke('#FF8FC7')
        .strokeWidth(this.getRoundRadius() * 0.04)

      Circle()
        .width(this.getRoundDialSize() * 0.86)
        .height(this.getRoundDialSize() * 0.86)
        .fill(Color.Transparent)
        .stroke('#FFF8C8')
        .strokeWidth(this.getRoundRadius() * 0.05)
    } else if (this.getRoundStyle() == ClockWidgetRoundStyle.Retro) {
      Circle()
        .width(this.getRoundDialSize())
        .height(this.getRoundDialSize())
        .fill(this.config.colors.cardColor ?? '#F7E8C7')
        .stroke('#6D3F1D')
        .strokeWidth(this.getRoundRadius() * 0.05)

      Circle()
        .width(this.getRoundDialSize() * 0.86)
        .height(this.getRoundDialSize() * 0.86)
        .fill(Color.Transparent)
        .stroke('#C99742')
        .strokeWidth(this.getRoundRadius() * 0.025)
    } else if (this.getRoundStyle() == ClockWidgetRoundStyle.ArtDeco) {
      Circle()
        .width(this.getRoundDialSize())
        .height(this.getRoundDialSize())
        .fill(this.config.colors.cardColor ?? '#0B3A35')
        .stroke('#E5BD62')
        .strokeWidth(this.getRoundRadius() * 0.035)

      Circle()
        .width(this.getRoundDialSize() * 0.84)
        .height(this.getRoundDialSize() * 0.84)
        .fill(Color.Transparent)
        .stroke('#8D6B2F')
        .strokeWidth(this.getRoundRadius() * 0.018)
    }
  }

  @Builder
  RoundTicks() {
    ForEach(CLOCK_WIDGET_TICKS, (index: number) => {
      Stack() {
        Column()
          .width(index % 5 == 0 ? 3 : 1)
          .height(index % 5 == 0 ? this.getRoundMajorTickLength() : this.getRoundMinorTickLength())
          .borderRadius(2)
          .backgroundColor(index % 5 == 0 ? this.getRoundMajorTickColor() : this.getRoundMinorTickColor())
          .offset({
            y: -this.getRoundTickOuterRadius() + (index % 5 == 0 ? this.getRoundMajorTickLength() : this.getRoundMinorTickLength()) * 0.5
          })
      }
      .width(this.getRoundDialSize())
      .height(this.getRoundDialSize())
      .rotate({ angle: index * 6 })
    }, (index: number) => index.toString())
  }

  @Builder
  RoundHourLabels(labels: string[]) {
    ForEach(CLOCK_WIDGET_HOURS, (index: number) => {
      Stack() {
        Text(labels[index])
          .fontSize(this.getRoundHourLabelSize())
          .fontWeight(FontWeight.Bold)
          .fontColor(this.config.colors.fontColor)
          .offset({ y: -this.getRoundHourLabelRadius() })
          .rotate({ angle: -index * 30 })
      }
      .width(this.getRoundDialSize())
      .height(this.getRoundDialSize())
      .rotate({ angle: index * 30 })
    }, (index: number) => index.toString())
  }

  @Builder
  RoundDotMarkers() {
    ForEach(CLOCK_WIDGET_HOURS, (index: number) => {
      Stack() {
        Circle()
          .width(index % 3 == 0 ? 8 : 5)
          .height(index % 3 == 0 ? 8 : 5)
          .fill(this.config.colors.accentColor ?? this.config.colors.fontColor)
          .offset({ y: -this.getRoundRadius() * 0.72 })
      }
      .width(this.getRoundDialSize())
      .height(this.getRoundDialSize())
      .rotate({ angle: index * 30 })
    }, (index: number) => index.toString())
  }

  @Builder
  RoundCyberpunkMarks() {
    ForEach(CLOCK_WIDGET_HOURS, (index: number) => {
      Stack() {
        Column()
          .width(index % 2 == 0 ? 14 : 8)
          .height(4)
          .borderRadius(2)
          .backgroundColor(index % 2 == 0 ? '#FF2BD6' : '#00F6FF')
          .offset({ y: -this.getRoundDialSize() * 0.34 })
      }
      .width(this.getRoundDialSize())
      .height(this.getRoundDialSize())
      .rotate({ angle: index * 30 + 15 })
    }, (index: number) => index.toString())
  }

  @Builder
  RoundPastelDots() {
    ForEach(CLOCK_WIDGET_DOTS, (index: number) => {
      Stack() {
        Circle()
          .width(index % 2 == 0 ? 7 : 4)
          .height(index % 2 == 0 ? 7 : 4)
          .fill(this.getPastelDotColor(index))
          .offset({ y: -this.getRoundDialSize() * 0.34 })
      }
      .width(this.getRoundDialSize())
      .height(this.getRoundDialSize())
      .rotate({ angle: index * 15 })
    }, (index: number) => index.toString())
  }

  @Builder
  RoundDecoSpokes() {
    ForEach(CLOCK_WIDGET_HOURS, (index: number) => {
      Stack() {
        Column()
          .width(index % 3 == 0 ? 2 : 1)
          .height(this.getRoundDialSize() * 0.23)
          .borderRadius(1)
          .backgroundColor(index % 3 == 0 ? '#E5BD62' : '#8D6B2F')
          .opacity(index % 3 == 0 ? 0.7 : 0.45)
          .offset({ y: -this.getRoundDialSize() * 0.23 })
      }
      .width(this.getRoundDialSize())
      .height(this.getRoundDialSize())
      .rotate({ angle: index * 30 })
    }, (index: number) => index.toString())
  }

  @Builder
  RoundDiamondMarkers() {
    ForEach(CLOCK_WIDGET_HOURS, (index: number) => {
      Stack() {
        Column()
          .width(index % 3 == 0 ? this.getRoundRadius() * 0.07 : this.getRoundRadius() * 0.05)
          .height(index % 3 == 0 ? this.getRoundRadius() * 0.07 : this.getRoundRadius() * 0.05)
          .backgroundColor(index % 3 == 0 ? '#F7DFA1' : '#E5BD62')
          .rotate({ angle: 45 })
          .offset({ y: -this.getRoundRadius() * 0.72 })
      }
      .width(this.getRoundDialSize())
      .height(this.getRoundDialSize())
      .rotate({ angle: index * 30 })
    }, (index: number) => index.toString())
  }

  @Builder
  RoundHand(angle: number, width: number, length: number, color: ResourceColor) {
    Column()
      .width(width)
      .height(length)
      .borderRadius(width)
      .backgroundColor(color)
      .offset({ y: -length * 0.5 })
      .rotate({
        angle: angle,
        centerX: '50%',
        centerY: '100%'
      })
  }

  @Builder
  LunarWidget() {
    Column() {
      Text(this.getDateText())
        .fontSize(this.widgetSize == ClockWidgetSize.Size4x4 ? 18 : 14)
        .fontColor(this.config.colors.mutedColor ?? this.config.colors.fontColor)
        .maxLines(1)
        .width('100%')

      Blank()

      this.TimeText(this.getTimeFontSize())

      Blank()

      Column({ space: this.widgetSize == ClockWidgetSize.Size4x4 ? 10 : 6 }) {
        Text(this.getLunarText())
          .fontSize(this.widgetSize == ClockWidgetSize.Size4x4 ? 22 : 17)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.config.colors.fontColor)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text('LUNAR CALENDAR')
          .fontSize(11)
          .fontColor(this.config.colors.accentColor ?? this.config.colors.fontColor)
      }
      .padding({
        left: 14,
        right: 14,
        top: this.widgetSize == ClockWidgetSize.Size4x4 ? 14 : 10,
        bottom: this.widgetSize == ClockWidgetSize.Size4x4 ? 14 : 10
      })
      .borderRadius(14)
      .backgroundColor(this.config.colors.cardColor ?? '#FFF8E8')
    }
    .width('100%')
    .height('100%')
    .padding({
      top: this.widgetSize == ClockWidgetSize.Size4x4 ? 26 : 18,
      bottom: this.widgetSize == ClockWidgetSize.Size4x4 ? 24 : 18,
      left: this.getHorizontalPadding(),
      right: this.getHorizontalPadding()
    })
    .alignItems(HorizontalAlign.Start)
  }
}
