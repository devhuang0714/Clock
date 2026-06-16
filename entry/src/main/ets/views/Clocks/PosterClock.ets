import { ClockColorsConfig, ClockStyle, DEFAULT_GLOBAL_CONFIG, GlobalClockConfig } from './ClockConfig'
import { ClockController, ClockListener } from './ClockController'
import { DateUtils } from '../../common/utils/DateUtils'
import { Icons } from '../../common/constants/Constants'

@Extend(Text)
function posterTimeText(fontSize: number, color: ResourceColor, family: string) {
  .fontFamily(family)
  .fontSize(fontSize)
  .fontColor(color)
  .fontWeight(FontWeight.Bold)
  .textAlign(TextAlign.Center)
  .minFontSize(18)
  .maxFontSize(fontSize)
  .maxLines(1)
  .width('100%')
}

@Extend(Text)
function posterLabel(fontSize: number, color: ResourceColor) {
  .fontSize(fontSize)
  .minFontSize(10)
  .maxFontSize(fontSize)
  .fontColor(color)
  .fontWeight(FontWeight.Medium)
  .maxLines(1)
}

@Component({ freezeWhenInactive: true })
export struct PosterClock {
  controller: ClockController = new ClockController()
  date: Date = new Date()
  @Prop style: ClockStyle = ClockStyle.Style1
  @Prop colorsConfig: ClockColorsConfig = {
    backgroundColor: '#050713',
    cardColor: '#1a2132',
    fontColor: '#ffffff'
  }
  @Prop globalConfig: GlobalClockConfig = DEFAULT_GLOBAL_CONFIG
  @Prop isLandscape: boolean = false
  @State dateStr: string = '2025年05月24日'
  @State week: string = '周五'
  @State weekEn: string = 'TUESDAY'
  @State weekShort: string = 'TUE'
  @State time: string = '00:00'
  @State seconds: string = '00'
  @State period: string = 'AM'
  @State workProgress: number = 0
  private listener: ClockListener = {
    onUpdate: (date) => {
      this.dateStr = DateUtils.formatDate(date, 'yyyy年MM月dd日')
      this.week = DateUtils.getWeek_ZH(date.getDay())
      this.weekEn = this.getWeekEn(date.getDay(), false)
      this.weekShort = this.getWeekEn(date.getDay(), true)
      const hours = this.globalConfig.use24HourFormat ? date.getHours() : DateUtils.get12Hour(date)
      this.time = `${hours.toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`
      this.seconds = date.getSeconds().toString().padStart(2, '0')
      this.period = date.getHours() >= 12 ? 'PM' : 'AM'
      this.workProgress = this.getWorkProgress(date)
    }
  }

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

  getWorkProgress(date: Date): number {
    const start = new Date(date.getTime())
    start.setHours(9, 0, 0, 0)
    const end = new Date(date.getTime())
    end.setHours(18, 0, 0, 0)
    const total = end.getTime() - start.getTime()
    const elapsed = date.getTime() - start.getTime()
    if (elapsed <= 0) {
      return 0
    }
    if (elapsed >= total) {
      return 100
    }
    return Math.floor(elapsed * 100 / total)
  }

  getHourText(): string {
    return this.time.substring(0, 2)
  }

  getMinuteText(): string {
    return this.time.substring(3, 5)
  }

  getDateLine(separator: string): string {
    return this.dateStr.replace('年', separator).replace('月', separator).replace('日', '')
  }

  getWeekEn(day: number, short: boolean): string {
    const longWeeks: string[] = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY']
    const shortWeeks: string[] = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
    return short ? shortWeeks[day] : longWeeks[day]
  }

  build() {
    Stack() {
      this.Background()
      if (this.style == ClockStyle.Style1) {
        this.CyberPoster()
      } else if (this.style == ClockStyle.Style2) {
        this.RetroPoster()
      } else if (this.style == ClockStyle.Style3) {
        this.CutePoster()
      } else if (this.style == ClockStyle.Style4) {
        this.MinimalPoster()
      } else {
        if (this.style == ClockStyle.Style5) {
          this.FunnyPoster()
        } else if (this.style == ClockStyle.Style6) {
          this.OrbitronHudPoster()
        } else if (this.style == ClockStyle.Style7) {
          this.ExoDashboardPoster()
        } else if (this.style == ClockStyle.Style8) {
          this.AudiowideSynthPoster()
        } else if (this.style == ClockStyle.Style9) {
          this.DsegLedPoster()
        } else if (this.style == ClockStyle.Style10) {
          this.PlexMinimalPoster()
        } else if (this.style == ClockStyle.Style11) {
          this.SpaceTerminalPoster()
        } else if (this.style == ClockStyle.Style12) {
          this.OfficePoster(
            $rawfile('images/poster_clocks/office/snooze_character.png'),
            $rawfile('images/poster_clocks/office/snooze_title.png'),
            '今日摸鱼进度',
            84,
            67
          )
        } else if (this.style == ClockStyle.Style13) {
          this.OfficePoster(
            $rawfile('images/poster_clocks/office/monday_character.png'),
            $rawfile('images/poster_clocks/office/monday_title.png'),
            '精神加载中',
            72,
            64
          )
        } else if (this.style == ClockStyle.Style14) {
          this.OfficePoster(
            $rawfile('images/poster_clocks/office/coffee_character.png'),
            $rawfile('images/poster_clocks/office/coffee_title.png'),
            '今日清醒进度',
            78,
            62
          )
        } else {
          this.OfficePoster(
            $rawfile('images/poster_clocks/office/payday_character.png'),
            $rawfile('images/poster_clocks/office/payday_title.png'),
            '下班倒计时',
            74,
            62
          )
        }
      }
    }
    .width('100%')
    .height('100%')
    .clip(true)
  }

  @Builder
  Background() {
    if (this.style == ClockStyle.Style1) {
      Row()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [[0xff050713, 0.0], [0xff10143a, 0.45], [0xff080815, 1.0]]
        })
    } else if (this.style == ClockStyle.Style2) {
      Row()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [[0xffff8a00, 0.0], [0xfff07900, 1.0]]
        })
    } else if (this.style == ClockStyle.Style3) {
      Row()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [[0xfffff7d8, 0.0], [0xffffe3ed, 0.68], [0xfffff8e9, 1.0]]
        })
    } else if (this.style == ClockStyle.Style4) {
      Row()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [[0xff08213a, 0.0], [0xff03101f, 1.0]]
        })
    } else {
      if (this.style == ClockStyle.Style5) {
        Row()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [[0xff08111d, 0.0], [0xff111426, 1.0]]
          })
      } else if (this.style == ClockStyle.Style6) {
        Row()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [[0xff020815, 0.0], [0xff07294a, 0.54], [0xff020815, 1.0]]
          })
      } else if (this.style == ClockStyle.Style7) {
        Row()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [[0xff08131d, 0.0], [0xff112636, 1.0]]
          })
      } else if (this.style == ClockStyle.Style8) {
        Row()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [[0xff180625, 0.0], [0xff28104a, 0.58], [0xff07020d, 1.0]]
          })
      } else if (this.style == ClockStyle.Style9) {
        Row()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [[0xff050807, 0.0], [0xff111a16, 1.0]]
          })
      } else if (this.style == ClockStyle.Style10) {
        Row()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [[0xff111418, 0.0], [0xff050607, 1.0]]
          })
      } else if (this.style == ClockStyle.Style11) {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor('#050607')
      } else {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor(this.colorsConfig.backgroundColor)
      }
    }
  }

  @Builder
  CyberPoster() {
    Stack() {
      this.CyberCircuitDecorations()
      Column() {
        Blank()
          .layoutWeight(1)

        Stack() {
          this.CyberRing()

          Column({ space: 6 }) {
            Text(`${this.time}:${this.seconds}`)
              .posterTimeText(this.isLandscape ? 108 : 46, '#61f4ff', Icons.FONT_NOVA_MONO)
              .width(this.isLandscape ? '100%' : '92%')
              .textShadow({ radius: 18, color: '#aa23d8ff', offsetX: 0, offsetY: 0 })

            Text('REMAINING TIME')
              .fontFamily(Icons.FONT_ICELAND)
              .posterLabel(this.isLandscape ? 30 : 22, '#6eeeff')
              .textAlign(TextAlign.Center)
              .width('100%')
              .opacity(0.82)

            Text(`${this.dateStr.replace('年', ' / ').replace('月', ' / ').replace('日', '')}   ${this.week}`)
              .fontFamily(Icons.FONT_ICELAND)
              .posterLabel(this.isLandscape ? 18 : 15, '#5fcfe5')
              .textAlign(TextAlign.Center)
              .width('100%')
              .opacity(0.72)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .width(this.isLandscape ? '74%' : '100%')
        .height(this.isLandscape ? '58%' : '50%')

        Column() {
          this.CyberCycleBar()
        }
        .margin({ top: this.isLandscape ? 20 : 10 })

        Blank()
          .layoutWeight(1)

        Row({ space: 28 }) {
          this.HudSlash()
          Text('CYCLE')
            .fontFamily(Icons.FONT_ICELAND)
            .posterLabel(this.isLandscape ? 28 : 20, '#6eeeff')
            .textAlign(TextAlign.Center)
            .width(this.isLandscape ? 120 : 72)
          this.HudSlash()
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .padding({ bottom: 22 })
      }
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
  }

  @Builder
  RetroPoster() {
    Stack() {
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor('#060606')

      Column({ space: this.isLandscape ? 12 : 18 }) {
        if (this.isLandscape) {
          Row({ space: 16 }) {
            Text(DateUtils.formatDate(this.date, 'yyyy-MM-dd'))
              .fontFamily(Icons.FONT_ERBOS_DRACO_1ST_OPEN_NBP)
              .posterLabel(42, '#172026')
              .opacity(0.96)
            Text(this.week)
              .fontFamily(Icons.FONT_ERBOS_DRACO_1ST_OPEN_NBP)
              .posterLabel(34, '#172026')
              .opacity(0.86)
          }
          .justifyContent(FlexAlign.Start)
          .width('100%')
        } else {
          Column({ space: 4 }) {
            Text(DateUtils.formatDate(this.date, 'yyyy-MM-dd'))
              .fontFamily(Icons.FONT_ERBOS_DRACO_1ST_OPEN_NBP)
              .posterLabel(30, '#172026')
              .opacity(0.96)
              .width('100%')
            Text(this.week)
              .fontFamily(Icons.FONT_ERBOS_DRACO_1ST_OPEN_NBP)
              .posterLabel(24, '#172026')
              .opacity(0.86)
              .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
        }

        Row({ space: this.isLandscape ? 14 : 8 }) {
          Text(this.time)
            .fontFamily(Icons.FONT_GEO)
            .fontSize(this.isLandscape ? 162 : 106)
            .minFontSize(54)
            .maxLines(1)
            .fontColor('#172026')
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .layoutWeight(1)
          Text(this.seconds)
            .fontFamily(Icons.FONT_GEO)
            .fontSize(this.isLandscape ? 66 : 46)
            .minFontSize(28)
            .maxLines(1)
            .fontColor('#172026')
            .fontWeight(FontWeight.Bold)
            .margin({ top: this.isLandscape ? 74 : 50 })
        }
        .width('100%')

        Row() {
          Row()
            .width('64%')
            .height(this.isLandscape ? 12 : 8)
            .backgroundColor('#66172026')
            .borderRadius(2)
        }
        .width('100%')
        .height(this.isLandscape ? 18 : 12)
        .border({ width: 2, color: '#22172026', radius: 4 })

        Text(this.period)
          .fontFamily(Icons.FONT_ERBOS_DRACO_1ST_OPEN_NBP)
          .posterLabel(this.isLandscape ? 26 : 18, '#172026')
          .opacity(this.getPeriodVisible() == Visibility.Visible ? 0.7 : 0)
      }
      .width('100%')
      .height('100%')
      .justifyContent(this.isLandscape ? FlexAlign.Start : FlexAlign.Center)
      .padding({ left: this.isLandscape ? 28 : 20, right: this.isLandscape ? 28 : 20, top: this.isLandscape ? 18 : 16, bottom: 14 })
      .backgroundColor('#ff8200')
      .border({ width: 5, color: '#050505', radius: 12 })
    }
    .padding(this.isLandscape ? 12 : 14)
    .width('100%')
    .height('100%')
  }

  @Builder
  CutePoster() {
    Stack() {
      this.Clouds()
      Column() {
        Blank()
          .height(this.isLandscape ? 10 : 72)

        Row({ space: 12 }) {
          Text(this.dateStr.replace('年', ' / ').replace('月', ' / ').replace('日', ''))
            .fontFamily(Icons.FONT_EXO2)
            .posterLabel(this.isLandscape ? 18 : 18, '#9f5752')
          Text(this.week)
            .fontFamily(Icons.FONT_EXO2)
            .posterLabel(this.isLandscape ? 18 : 18, '#9f5752')
        }
        .justifyContent(FlexAlign.Center)

        Row({ space: 6 }) {
          Text(this.time)
            .posterTimeText(this.isLandscape ? 108 : 72, '#ff8d8d', Icons.FONT_EXO2)
            .textShadow({ radius: 0, color: '#ffffff', offsetX: 3, offsetY: 3 })
          Text(':' + this.seconds)
            .posterTimeText(this.isLandscape ? 48 : 32, '#ff8d8d', Icons.FONT_EXO2)
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .margin({ top: this.isLandscape ? 6 : 10 })

        if (this.isLandscape) {
          Row({ space: 18 }) {
            this.CuteCharacter()
            this.CuteMessageCard()
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .width('100%')
          .margin({ top: 4 })
        } else {
          this.CuteCharacter()
          this.CuteMessageCard()
        }

        Blank()
          .layoutWeight(1)
      }
      .height('100%')
    }
  }

  @Builder
  MinimalPoster() {
    Stack() {
      this.CyberGridDecorations()

      Column() {
        Blank()
          .layoutWeight(1)

        Stack() {
          this.HudPanelFrame()

          Column({ space: this.isLandscape ? 8 : 12 }) {
            Text('REMAINING TIME')
              .fontFamily(Icons.FONT_JURA)
              .posterLabel(this.isLandscape ? 28 : 20, '#e8ffff')
              .fontWeight(FontWeight.Bold)
              .textShadow({ radius: 12, color: '#8843c9ff', offsetX: 0, offsetY: 0 })

            Text(`${this.time}:${this.seconds}`)
              .fontFamily(Icons.FONT_NOVA_MONO)
              .fontSize(this.isLandscape ? 106 : 56)
              .minFontSize(32)
              .maxLines(1)
              .fontColor('#e8ffff')
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .width('100%')

            Row({ space: 18 }) {
              Text('▷ Play')
                .fontFamily(Icons.FONT_JURA)
                .posterLabel(this.isLandscape ? 22 : 16, '#a9e8ff')
              Text('○ Active')
                .fontFamily(Icons.FONT_JURA)
                .posterLabel(this.isLandscape ? 22 : 16, '#7da6bd')
            }
            .justifyContent(FlexAlign.Center)
          }
          .alignItems(HorizontalAlign.Center)
          .width('100%')
          .padding({ left: this.isLandscape ? 78 : 26, right: this.isLandscape ? 78 : 26 })
        }
        .width(this.isLandscape ? '72%' : '90%')
        .height(this.isLandscape ? '56%' : '44%')

        Blank()
          .layoutWeight(1)

        Row({ space: 18 }) {
          this.HudSlash()
          Text(`${DateUtils.formatDate(this.date, 'yyyy.MM.dd')}  ${this.week}`)
            .fontFamily(Icons.FONT_JURA)
            .posterLabel(this.isLandscape ? 18 : 14, '#6bbce0')
            .opacity(0.76)
          this.HudSlash()
        }
        .justifyContent(FlexAlign.Center)
        .padding({ bottom: 24 })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .height('100%')
    .width('100%')
  }

  @Builder
  FunnyPoster() {
    Column() {
      Blank()
        .layoutWeight(this.isLandscape ? 1 : 1.8)

      Flex({
        direction: this.isLandscape ? FlexDirection.Row : FlexDirection.Column,
        justifyContent: FlexAlign.Center,
        alignItems: ItemAlign.Center
      }) {
        this.FunnyFace()

        Column({ space: this.isLandscape ? 10 : 18 }) {
          Text('都几点了！')
            .fontFamily(Icons.FONT_EXO2)
            .posterLabel(this.isLandscape ? 32 : 30, '#91a6d6')
          Text('还不去干活？')
            .fontFamily(Icons.FONT_EXO2)
            .posterLabel(this.isLandscape ? 28 : 28, '#91a6d6')

          Row({ space: this.isLandscape ? 8 : 4 }) {
            Text(this.time)
              .fontFamily(Icons.FONT_IBM_PLEX_MONO)
              .fontSize(this.isLandscape ? 88 : 66)
              .minFontSize(36)
              .maxLines(1)
              .fontColor('#ffffff')
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.End)
              .layoutWeight(1)
            Text(':' + this.seconds)
              .fontFamily(Icons.FONT_IBM_PLEX_MONO)
              .fontSize(this.isLandscape ? 38 : 26)
              .minFontSize(18)
              .maxLines(1)
              .fontColor('#ffffff')
              .fontWeight(FontWeight.Bold)
              .width(this.isLandscape ? 70 : 48)
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Bottom)
          .width(this.isLandscape ? 360 : '100%')

          Text('今日摸鱼进度')
            .fontFamily(Icons.FONT_EXO2)
            .posterLabel(this.isLandscape ? 17 : 20, '#ffffff')
            .opacity(0.9)

          Row({ space: this.isLandscape ? 10 : 8 }) {
            Blank()
              .width(this.isLandscape ? 48 : 52)

            Row() {
              Row()
                .height(this.isLandscape ? 12 : 16)
                .width(`${this.workProgress}%`)
                .linearGradient({
                  direction: GradientDirection.Right,
                  colors: [[0xff5da8ff, 0.0], [0xffb6d7ff, 1.0]]
                })
                .borderRadius(this.isLandscape ? 6 : 8)
            }
            .layoutWeight(1)
            .height(this.isLandscape ? 16 : 20)
            .padding(2)
            .border({ width: 1, color: '#ffffff', radius: 10 })

            Text(`${this.workProgress}%`)
              .fontFamily(Icons.FONT_IBM_PLEX_MONO)
              .posterLabel(this.isLandscape ? 17 : 20, '#ffffff')
              .width(this.isLandscape ? 48 : 52)
          }
          .justifyContent(FlexAlign.Center)
          .width(this.isLandscape ? 360 : '100%')
        }
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)
        .width(this.isLandscape ? 420 : '100%')
      }
      .width('100%')
      .padding({ left: this.isLandscape ? 24 : 34, right: this.isLandscape ? 24 : 34 })
      .offset({ y: this.isLandscape ? 0 : 34 })

      Blank()
        .layoutWeight(this.isLandscape ? 1 : 0.2)

      Row({ space: 64 }) {
        this.BottomIcon('#ffd938')
        this.BottomIcon('#ff4db4')
        this.BottomIcon('#28c8ff')
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .padding({ bottom: this.isLandscape ? 14 : 26 })
    }
    .height('100%')
  }

  @Builder
  PosterRasterBackground(portrait: ResourceStr, landscape: ResourceStr) {
    Image(this.isLandscape ? landscape : portrait)
      .width('100%')
      .height('100%')
      .objectFit(ImageFit.Contain)
      .backgroundColor('#000000')
  }

  @Builder
  NeonHudOverlay(fontFamily: string, timeColor: ResourceColor, glowColor: ResourceColor, label: string) {
    Column({ space: this.isLandscape ? 14 : 10 }) {
      Text(`${this.getDateLine('-')}  ${this.weekShort}`)
        .fontFamily(fontFamily)
        .posterLabel(this.isLandscape ? 16 : 13, timeColor)
        .opacity(0.86)

      if (this.isLandscape) {
        Text(`${this.time}:${this.seconds}`)
          .fontFamily(fontFamily)
          .fontSize(label == 'SYNTHWAVE' ? 70 : 82)
          .minFontSize(34)
          .maxLines(1)
          .fontColor(timeColor)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .textShadow({ radius: 22, color: glowColor, offsetX: 0, offsetY: 0 })
          .width('72%')
      } else {
        Column({ space: 4 }) {
          Text(this.getHourText())
            .fontFamily(fontFamily)
            .fontSize(label == 'SYNTHWAVE' ? 74 : 82)
            .minFontSize(40)
            .maxLines(1)
            .fontColor(timeColor)
            .fontWeight(FontWeight.Bold)
            .textShadow({ radius: 20, color: glowColor, offsetX: 0, offsetY: 0 })
          Text(this.getMinuteText())
            .fontFamily(fontFamily)
            .fontSize(label == 'SYNTHWAVE' ? 74 : 82)
            .minFontSize(40)
            .maxLines(1)
            .fontColor(timeColor)
            .fontWeight(FontWeight.Bold)
            .textShadow({ radius: 20, color: glowColor, offsetX: 0, offsetY: 0 })
          Text(this.seconds)
            .fontFamily(Icons.FONT_IBM_PLEX_MONO)
            .posterLabel(26, timeColor)
            .textShadow({ radius: 14, color: glowColor, offsetX: 0, offsetY: 0 })
        }
        .alignItems(HorizontalAlign.Center)
      }

      Text(label)
        .fontFamily(fontFamily)
        .posterLabel(this.isLandscape ? 13 : 11, timeColor)
        .opacity(0.72)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .offset({ y: this.isLandscape ? 4 : 18 })
  }

  @Builder
  SciDashboardOverlay() {
    Column({ space: this.isLandscape ? 12 : 10 }) {
      Text(this.weekEn)
        .fontFamily(Icons.FONT_EXO2)
        .posterLabel(this.isLandscape ? 20 : 15, '#e7f3ff')
        .opacity(0.9)
      Text(this.getDateLine(' / '))
        .fontFamily(Icons.FONT_EXO2)
        .posterLabel(this.isLandscape ? 15 : 13, '#9dccff')
        .opacity(0.84)
      Text(`${this.time}:${this.seconds}`)
        .fontFamily(Icons.FONT_IBM_PLEX_MONO)
        .fontSize(this.isLandscape ? 78 : 44)
        .minFontSize(24)
        .maxLines(1)
        .fontColor('#f2f8ff')
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .textShadow({ radius: 12, color: '#665aa7ff', offsetX: 0, offsetY: 0 })
        .width(this.isLandscape ? '72%' : '86%')
      Text(this.period)
        .fontFamily(Icons.FONT_EXO2)
        .posterLabel(this.isLandscape ? 18 : 14, '#e7f3ff')
        .visibility(this.getPeriodVisible())
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .offset({ y: this.isLandscape ? 2 : 22 })
  }

  @Builder
  DsegOverlay() {
    Column({ space: this.isLandscape ? 14 : 10 }) {
      Text(`${this.getDateLine('-')}  ${this.weekShort}`)
        .fontFamily(Icons.FONT_SPACE_MONO)
        .posterLabel(this.isLandscape ? 16 : 13, '#94ff91')
        .opacity(0.86)

      if (this.isLandscape) {
        Text(`${this.time}:${this.seconds}`)
          .fontFamily(Icons.FONT_DSEG7_CLASSIC)
          .fontSize(84)
          .minFontSize(34)
          .maxLines(1)
          .fontColor('#91ff83')
          .textAlign(TextAlign.Center)
          .textShadow({ radius: 20, color: '#8856ff4d', offsetX: 0, offsetY: 0 })
          .width('68%')
      } else {
        Column({ space: 4 }) {
          Text(this.getHourText())
            .fontFamily(Icons.FONT_DSEG7_CLASSIC)
            .fontSize(76)
            .maxLines(1)
            .fontColor('#91ff83')
          Text(this.getMinuteText())
            .fontFamily(Icons.FONT_DSEG7_CLASSIC)
            .fontSize(76)
            .maxLines(1)
            .fontColor('#91ff83')
          Text(this.seconds)
            .fontFamily(Icons.FONT_DSEG7_CLASSIC)
            .fontSize(38)
            .maxLines(1)
            .fontColor('#91ff83')
        }
        .alignItems(HorizontalAlign.Center)
      }

      Text('ALARM 07:30')
        .fontFamily(Icons.FONT_SPACE_MONO)
        .posterLabel(this.isLandscape ? 13 : 11, '#94ff91')
        .opacity(0.68)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .offset({ y: this.isLandscape ? 0 : 18 })
  }

  @Builder
  IndustrialOverlay() {
    Column({ space: this.isLandscape ? 14 : 10 }) {
      Text(`${this.getDateLine('-')}  ${this.weekShort}`)
        .fontFamily(Icons.FONT_IBM_PLEX_MONO)
        .posterLabel(this.isLandscape ? 16 : 13, '#d6d7d5')
        .opacity(0.82)
      Text(`${this.time}:${this.seconds}`)
        .fontFamily(Icons.FONT_DSEG7_CLASSIC)
        .fontSize(this.isLandscape ? 82 : 48)
        .minFontSize(30)
        .maxLines(1)
        .fontColor('#ff7b2a')
        .textAlign(TextAlign.Center)
        .textShadow({ radius: 14, color: '#88ff7b2a', offsetX: 0, offsetY: 0 })
        .width(this.isLandscape ? '72%' : '78%')
      Text('MECHANICAL TIMER')
        .fontFamily(Icons.FONT_IBM_PLEX_MONO)
        .posterLabel(this.isLandscape ? 13 : 11, '#ff7b2a')
        .opacity(0.82)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .offset({ y: this.isLandscape ? 0 : 20 })
  }

  @Builder
  TerminalOverlay() {
    Column({ space: this.isLandscape ? 13 : 9 }) {
      Text(`> ${this.weekEn}  ${this.getDateLine('-')}`)
        .fontFamily(Icons.FONT_SPACE_MONO)
        .posterLabel(this.isLandscape ? 16 : 12, '#7dff74')
        .opacity(0.86)
      Text(`${this.time}:${this.seconds}`)
        .fontFamily(Icons.FONT_SPACE_MONO)
        .fontSize(this.isLandscape ? 72 : 42)
        .minFontSize(28)
        .maxLines(1)
        .fontColor('#7dff74')
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .textShadow({ radius: 14, color: '#667dff74', offsetX: 0, offsetY: 0 })
        .width(this.isLandscape ? '70%' : '58%')
      Text('READY_')
        .fontFamily(Icons.FONT_SPACE_MONO)
        .posterLabel(this.isLandscape ? 14 : 12, '#7dff74')
        .opacity(0.7)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .offset({ y: this.isLandscape ? 0 : 20 })
  }

  @Builder
  OrbitronHudPoster() {
    Stack() {
      this.PosterRasterBackground(
        $rawfile('images/poster_clocks/backgrounds/orbitron_portrait.png'),
        $rawfile('images/poster_clocks/backgrounds/orbitron_landscape.png')
      )
      this.NeonHudOverlay(Icons.FONT_ORBITRON, '#43f4ff', '#d435ff', 'ORBITRON')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ExoDashboardPoster() {
    Stack() {
      this.PosterRasterBackground(
        $rawfile('images/poster_clocks/backgrounds/exo2_portrait.png'),
        $rawfile('images/poster_clocks/backgrounds/exo2_landscape.png')
      )
      this.SciDashboardOverlay()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AudiowideSynthPoster() {
    Stack() {
      this.PosterRasterBackground(
        $rawfile('images/poster_clocks/backgrounds/audiowide_portrait.png'),
        $rawfile('images/poster_clocks/backgrounds/audiowide_landscape.png')
      )
      this.NeonHudOverlay(Icons.FONT_AUDIOWIDE, '#ff63c9', '#24dfff', 'SYNTHWAVE')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DsegLedPoster() {
    Stack() {
      this.PosterRasterBackground(
        $rawfile('images/poster_clocks/backgrounds/dseg_portrait.png'),
        $rawfile('images/poster_clocks/backgrounds/dseg_landscape.png')
      )
      this.DsegOverlay()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  PlexMinimalPoster() {
    Stack() {
      this.PosterRasterBackground(
        $rawfile('images/poster_clocks/backgrounds/plex_portrait.png'),
        $rawfile('images/poster_clocks/backgrounds/plex_landscape.png')
      )
      this.IndustrialOverlay()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SpaceTerminalPoster() {
    Stack() {
      this.PosterRasterBackground(
        $rawfile('images/poster_clocks/backgrounds/space_mono_portrait.png'),
        $rawfile('images/poster_clocks/backgrounds/space_mono_landscape.png')
      )
      this.TerminalOverlay()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  OfficePoster(character: ResourceStr, title: ResourceStr, progressLabel: string, characterWidth: number,
    titleWidth: number) {
    Stack() {
      if (this.isLandscape) {
        Column() {
          Blank()
            .layoutWeight(1)

          Flex({
            direction: FlexDirection.Row,
            justifyContent: FlexAlign.Center,
            alignItems: ItemAlign.Center
          }) {
            Image(character)
              .width(characterWidth * 4)
              .objectFit(ImageFit.Contain)
              .margin({ right: 28 })

            Column({ space: 10 }) {
              Image(title)
                .width(titleWidth * 4)
                .objectFit(ImageFit.Contain)
                .margin({ bottom: 4 })

              this.OfficeTimeBlock()
              this.OfficeProgress(progressLabel)
            }
            .width(420)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .padding({ left: 24, right: 24 })

          Blank()
            .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
      } else {
        Column({ space: 18 }) {
          Image(character)
            .width('78%')
            .objectFit(ImageFit.Contain)
            .margin({ top: 24 })

          Image(title)
            .width('56%')
            .objectFit(ImageFit.Contain)

          this.OfficeTimeBlock()
          this.OfficeProgress(progressLabel)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding({ left: 28, right: 28, bottom: 36 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  OfficeTimeBlock() {
    Row({ space: this.isLandscape ? 10 : 6 }) {
      Text(this.time)
        .fontFamily(Icons.FONT_IBM_PLEX_MONO)
        .fontSize(this.isLandscape ? 88 : 68)
        .minFontSize(this.isLandscape ? 36 : 34)
        .maxFontSize(this.isLandscape ? 88 : 68)
        .maxLines(1)
        .fontColor(this.colorsConfig.fontColor)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.End)
        .textShadow({ radius: 12, color: '#55000000', offsetX: 0, offsetY: 4 })
        .width(this.isLandscape ? 280 : 244)

      Text(`:${this.seconds}`)
        .fontFamily(Icons.FONT_IBM_PLEX_MONO)
        .fontSize(this.isLandscape ? 38 : 28)
        .minFontSize(this.isLandscape ? 18 : 18)
        .maxFontSize(this.isLandscape ? 38 : 28)
        .maxLines(1)
        .fontColor(this.colorsConfig.fontColor)
        .fontWeight(FontWeight.Bold)
        .opacity(0.78)
        .width(this.isLandscape ? 70 : 48)
        .margin({ top: this.isLandscape ? 0 : 22 })
    }
    .alignItems(this.isLandscape ? VerticalAlign.Bottom : VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width(this.isLandscape ? 360 : 322)
  }

  @Builder
  OfficeProgress(label: string) {
    Column({ space: this.isLandscape ? 8 : 12 }) {
      Row({ space: this.isLandscape ? 10 : 10 }) {
        Blank()
          .width(this.isLandscape ? 48 : 50)

        Text(label)
          .fontFamily(Icons.FONT_IBM_PLEX_MONO)
          .posterLabel(this.isLandscape ? 17 : 18, this.colorsConfig.fontColor)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)

        Blank()
          .width(this.isLandscape ? 48 : 50)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row({ space: this.isLandscape ? 10 : 10 }) {
        Blank()
          .width(this.isLandscape ? 48 : 50)

        Row() {
          Row()
            .height(this.isLandscape ? 12 : 14)
            .width(`${this.workProgress}%`)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [[0xff6aa9ff, 0.0], [0xff98e4ff, 1.0]]
            })
            .borderRadius(this.isLandscape ? 9 : 7)
        }
        .layoutWeight(1)
        .height(this.isLandscape ? 16 : 22)
        .padding(this.isLandscape ? 2 : 3)
        .border({ width: this.isLandscape ? 1 : 2, color: this.colorsConfig.fontColor, radius: this.isLandscape ? 10 : 11 })
        .opacity(0.9)

        Text(`${this.workProgress}%`)
          .fontFamily(Icons.FONT_IBM_PLEX_MONO)
          .posterLabel(this.isLandscape ? 17 : 20, this.colorsConfig.fontColor)
          .fontWeight(FontWeight.Bold)
          .width(this.isLandscape ? 48 : 50)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

    }
    .width(this.isLandscape ? 360 : '104%')
  }

  @Builder
  TechFrame(borderColor: ResourceColor, glowColor: ResourceColor) {
    Stack() {
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor('#b0081018')
        .border({ width: 2, color: borderColor, radius: this.isLandscape ? 18 : 24 })
        .shadow({ radius: 28, color: glowColor, offsetX: 0, offsetY: 0 })
      Row()
        .width('91%')
        .height('83%')
        .border({ width: 1, color: borderColor, radius: this.isLandscape ? 10 : 16 })
        .opacity(0.45)
      Row()
        .width(this.isLandscape ? '54%' : '42%')
        .height(2)
        .backgroundColor(borderColor)
        .offset({ y: this.isLandscape ? -106 : -276 })
      Row()
        .width(this.isLandscape ? '48%' : '36%')
        .height(2)
        .backgroundColor(borderColor)
        .offset({ y: this.isLandscape ? 106 : 276 })

      ForEach([-1, 1], (x: number) => {
        ForEach([-1, 1], (y: number) => {
          Column({ space: 5 }) {
            Row()
              .width(this.isLandscape ? 42 : 28)
              .height(2)
              .backgroundColor(borderColor)
            Row()
              .width(2)
              .height(this.isLandscape ? 24 : 30)
              .backgroundColor(borderColor)
          }
          .offset({ x: x * (this.isLandscape ? 400 : 132), y: y * (this.isLandscape ? 114 : 286) })
        })
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  RuggedFrame(borderColor: ResourceColor, glowColor: ResourceColor) {
    Stack() {
      Row()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [[0xff20252a, 0.0], [0xff090b0d, 1.0]]
        })
        .border({ width: 2, color: '#53585e', radius: this.isLandscape ? 18 : 22 })
        .shadow({ radius: 18, color: glowColor, offsetX: 0, offsetY: 0 })
      Row()
        .width(this.isLandscape ? '82%' : '58%')
        .height(this.isLandscape ? 14 : 12)
        .backgroundColor('#0d0f11')
        .border({ width: 1, color: '#30363a', radius: 4 })
        .offset({ y: this.isLandscape ? -122 : -302 })
      Row()
        .width(this.isLandscape ? '82%' : '74%')
        .height(this.isLandscape ? '64%' : '68%')
        .backgroundColor('#99101315')
        .border({ width: 1, color: borderColor, radius: 10 })
      Row()
        .width(this.isLandscape ? 5 : 4)
        .height(this.isLandscape ? '58%' : '42%')
        .backgroundColor(borderColor)
        .borderRadius(3)
        .offset({ x: this.isLandscape ? -430 : -144 })
      Row()
        .width(this.isLandscape ? 5 : 4)
        .height(this.isLandscape ? '58%' : '42%')
        .backgroundColor(borderColor)
        .borderRadius(3)
        .offset({ x: this.isLandscape ? 430 : 144 })
      ForEach([-1, 1], (x: number) => {
        ForEach([-1, 1], (y: number) => {
          Row()
            .width(14)
            .height(14)
            .border({ width: 2, color: '#6a6d70', radius: 7 })
            .offset({ x: x * (this.isLandscape ? 430 : 142), y: y * (this.isLandscape ? 122 : 300) })
        })
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TerminalFrame() {
    Stack() {
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor('#cc030604')
        .border({ width: 2, color: '#2cff5a', radius: this.isLandscape ? 14 : 22 })
        .shadow({ radius: 18, color: '#772cff5a', offsetX: 0, offsetY: 0 })
      Column({ space: 12 }) {
        ForEach([0, 1, 2, 3, 4, 5, 6, 7], () => {
          Row()
            .width('82%')
            .height(1)
            .backgroundColor('#2237aa43')
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  HudMetric(label: string, value: string, color: ResourceColor) {
    Row({ space: 6 }) {
      Text(label)
        .fontFamily(Icons.FONT_ORBITRON)
        .posterLabel(13, color)
      Text(value)
        .fontFamily(Icons.FONT_NOVA_MONO)
        .posterLabel(14, color)
    }
  }

  @Builder
  SpaceArcDecor() {
    Stack() {
      Row()
        .width(this.isLandscape ? 560 : 300)
        .height(this.isLandscape ? 120 : 78)
        .border({ width: 2, color: '#336ed8ff', radius: 260 })
        .offset({ y: this.isLandscape ? 116 : 212 })
      Row()
        .width(this.isLandscape ? 500 : 260)
        .height(3)
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [[0x0037c8ff, 0.0], [0xff42b8ff, 0.5], [0x0037c8ff, 1.0]]
        })
        .offset({ y: this.isLandscape ? 84 : 184 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SynthGridDecor() {
    Stack() {
      Row()
        .width(this.isLandscape ? 260 : 150)
        .height(this.isLandscape ? 130 : 86)
        .border({ width: 2, color: '#ff2f73', radius: this.isLandscape ? 130 : 75 })
        .offset({ y: this.isLandscape ? 110 : 220 })
      Row()
        .width(this.isLandscape ? 260 : 150)
        .height(3)
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [[0x00ff2f73, 0.0], [0xffff2f73, 0.5], [0x00ff2f73, 1.0]]
        })
        .offset({ y: this.isLandscape ? 110 : 220 })
      Row({ space: this.isLandscape ? 8 : 5 }) {
        ForEach([52, 88, 38, 120, 66, 44, 98, 58, 76, 110, 42, 90], (height: number, index: number) => {
          Row()
            .width(this.isLandscape ? 16 : 8)
            .height(this.isLandscape ? height : height * 0.72)
            .backgroundColor(index % 2 == 0 ? '#5517042b' : '#77230840')
            .border({ width: 1, color: '#55ff2f73' })
        })
      }
      .alignItems(VerticalAlign.Bottom)
      .offset({ y: this.isLandscape ? 128 : 238 })
      Column({ space: 18 }) {
        ForEach([0, 1, 2, 3, 4, 5], (index: number) => {
          Row()
            .width(`${100 - index * 9}%`)
            .height(1)
            .backgroundColor('#55ff2fd6')
        })
      }
      .justifyContent(FlexAlign.End)
      .height('100%')
      .padding({ bottom: this.isLandscape ? 26 : 42 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ExoMetric(label: string, value: string, unit: string, color: ResourceColor) {
    Column({ space: 6 }) {
      Text(label)
        .fontFamily(Icons.FONT_EXO2)
        .posterLabel(this.isLandscape ? 18 : 12, color)
      Text(value)
        .fontFamily(Icons.FONT_EXO2)
        .posterLabel(this.isLandscape ? 42 : 24, '#f1fdff')
      Text(unit)
        .fontFamily(Icons.FONT_EXO2)
        .posterLabel(this.isLandscape ? 16 : 11, '#83b9cf')
    }
    .width(this.isLandscape ? 128 : 78)
    .height(this.isLandscape ? 150 : 120)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#55172f42')
    .border({ width: 1, color: color, radius: 8 })
  }

  @Builder
  NeonInfoCard(title: string, subTitle: string, color: string) {
    Column({ space: 4 }) {
      Text(title)
        .posterLabel(22, '#ffffff')
      Text(subTitle)
        .posterLabel(16, color)
    }
    .alignItems(HorizontalAlign.Center)
    .padding(12)
    .width('100%')
    .backgroundColor('#33101828')
    .border({ width: 1, color: color, radius: 8 })
  }

  @Builder
  BottomIcon(color: ResourceColor) {
    Stack() {
      Text(Icons.CLOCK)
        .fontFamily(Icons.FONT_FAMILY)
        .fontSize(24)
        .fontColor(color)
    }
    .width(34)
    .height(34)
  }

  @Builder
  CyberCircuitDecorations() {
    Stack() {
      Column({ space: 14 }) {
        ForEach([30, 42, 24, 50, 36], (width: number, index: number) => {
          Row({ space: 10 }) {
            Row()
              .width(7)
              .height(7)
              .borderRadius(4)
              .backgroundColor(index % 2 == 0 ? '#558cecff' : '#334b9fd1')
            Row()
              .width(`${width}%`)
              .height(1)
              .backgroundColor('#335cecff')
            Row()
              .width(5)
              .height(5)
              .borderRadius(3)
              .backgroundColor('#334b9fd1')
          }
        })
      }
      .offset({ x: this.isLandscape ? -430 : -180, y: -88 })

      Column({ space: 14 }) {
        ForEach([36, 25, 48, 39, 29], (width: number, index: number) => {
          Row({ space: 10 }) {
            Row()
              .width(5)
              .height(5)
              .borderRadius(3)
              .backgroundColor('#334b9fd1')
            Row()
              .width(`${width}%`)
              .height(1)
              .backgroundColor('#335cecff')
            Row()
              .width(7)
              .height(7)
              .borderRadius(4)
              .backgroundColor(index % 2 == 0 ? '#558cecff' : '#334b9fd1')
          }
        })
      }
      .offset({ x: this.isLandscape ? 430 : 180, y: -72 })

      Row()
        .width(this.isLandscape ? 1020 : '92%')
        .height(1)
        .backgroundColor('#245cecff')
        .offset({ y: 22 })

      Row()
        .width(this.isLandscape ? 860 : '76%')
        .height(1)
        .backgroundColor('#2442d8ff')
        .offset({ y: 174 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  CyberRing() {
    Stack() {
      Row()
        .width(this.isLandscape ? '72%' : '68%')
        .aspectRatio(1)
        .border({ width: 2, color: '#6a61eaff' })
        .opacity(0.82)

      Row()
        .width(this.isLandscape ? '62%' : '58%')
        .aspectRatio(1)
        .border({ width: 5, color: '#5a65f3ff' })
        .opacity(0.42)

      Row()
        .width(this.isLandscape ? '90%' : '76%')
        .height(2)
        .backgroundColor('#335cecff')

      Row()
        .width(2)
        .height(this.isLandscape ? '64%' : '52%')
        .backgroundColor('#335cecff')

      ForEach([0, 1, 2, 3, 4, 5], (index: number) => {
        Row()
          .width(this.isLandscape ? 16 : 10)
          .height(this.isLandscape ? 16 : 10)
          .borderRadius(this.isLandscape ? 8 : 5)
          .backgroundColor('#65d9ffff')
          .shadow({ radius: 18, color: '#cc1ba9ff', offsetX: 0, offsetY: 0 })
          .offset({
            x: Math.cos(index * Math.PI / 3) * (this.isLandscape ? 150 : 80),
            y: Math.sin(index * Math.PI / 3) * (this.isLandscape ? 150 : 80)
          })
      })
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }

  @Builder
  CyberCycleBar() {
    Column({ space: 8 }) {
      Row({ space: 12 }) {
        ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], (item: number) => {
          Row()
            .width(2)
            .height(item % 3 == 0 ? 18 : 10)
            .backgroundColor('#77dff8ff')
        })
      }
      Row() {
        Row()
          .height(8)
          .width('64%')
          .backgroundColor('#7a6cecff')
      }
      .width(this.isLandscape ? '80%' : '64%')
      .height(12)
      .border({ width: 1, color: '#775cecff', radius: 1 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  HudSlash() {
    Row({ space: 6 }) {
      ForEach([0, 1, 2], (index: number) => {
        Row()
          .width(this.isLandscape ? 24 : 16)
          .height(this.isLandscape ? 8 : 6)
          .backgroundColor(index == 2 ? '#335cecff' : '#67dff8ff')
          .rotate({ angle: -18 })
      })
    }
  }

  @Builder
  HudPanelFrame() {
    Stack() {
      Row()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [[0x3328e5ff, 0.0], [0x1145f5ff, 1.0]]
        })
        .border({ width: 2, color: '#667befff', radius: 10 })

      Row()
        .width('70%')
        .height(3)
        .backgroundColor('#7cefffff')
        .offset({ y: this.isLandscape ? -118 : -80 })
        .shadow({ radius: 12, color: '#aa2bc9ff', offsetX: 0, offsetY: 0 })

      Row()
        .width('82%')
        .height(3)
        .backgroundColor('#7cefffff')
        .offset({ y: this.isLandscape ? 118 : 80 })
        .shadow({ radius: 12, color: '#aa2bc9ff', offsetX: 0, offsetY: 0 })

      Row()
        .width(12)
        .height('34%')
        .backgroundColor('#70e6ffff')
        .offset({ x: this.isLandscape ? -455 : -168 })

      Row()
        .width(12)
        .height('34%')
        .backgroundColor('#70e6ffff')
        .offset({ x: this.isLandscape ? 455 : 168 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  CyberGridDecorations() {
    Stack() {
      Column({ space: 28 }) {
        ForEach([0, 1, 2, 3, 4, 5], () => {
          Row()
            .width(240)
            .height(1)
            .backgroundColor('#244f85b8')
        })
      }
      .offset({ x: this.isLandscape ? -460 : -190, y: 0 })

      Row({ space: 28 }) {
        ForEach([0, 1, 2, 3, 4, 5], () => {
          Row()
            .width(1)
            .height(180)
            .backgroundColor('#244f85b8')
        })
      }
      .offset({ x: this.isLandscape ? -460 : -190, y: 0 })

      Column({ space: 12 }) {
        ForEach([120, 92, 146, 72, 110], (width: number) => {
          Row()
            .width(width)
            .height(5)
            .backgroundColor('#335fc2e6')
        })
      }
      .offset({ x: this.isLandscape ? 360 : 150, y: -150 })
      .opacity(0.58)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FlipTile(text: string) {
    Stack() {
      Text(text)
        .posterTimeText(this.isLandscape ? 120 : 92, '#f8e5c3', '')
      Row()
        .height(2)
        .width('100%')
        .backgroundColor('#77310f06')
    }
    .width(this.isLandscape ? 160 : 116)
    .height(this.isLandscape ? 132 : 104)
    .backgroundColor('#5b3518')
    .border({ width: 2, color: '#1b0d05', radius: 10 })
    .shadow({ radius: 22, color: '#aa000000', offsetY: 8 })
  }

  @Builder
  SmallFlipTile(text: string) {
    Text(text)
      .posterTimeText(this.isLandscape ? 54 : 44, '#f8e5c3', '')
      .width(this.isLandscape ? 82 : 70)
      .height(this.isLandscape ? 70 : 58)
      .backgroundColor('#4d2b13')
      .border({ width: 2, color: '#1b0d05', radius: 8 })
  }

  @Builder
  CityDecoration() {
    Row({ space: 6 }) {
      ForEach([58, 86, 120, 76, 150, 94, 130, 70, 112], (height: number, index: number) => {
        Column()
          .width('9%')
          .height(height)
          .backgroundColor(index % 2 == 0 ? '#663e0f54' : '#66212b5c')
          .border({ width: 1, color: index % 2 == 0 ? '#ff2bd6' : '#00f6ff' })
      })
    }
    .alignItems(VerticalAlign.Bottom)
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24, bottom: 34 })
  }

  @Builder
  Lamp() {
    Column({ space: 0 }) {
      Row()
        .width(44)
        .height(24)
        .backgroundColor('#f0b35a')
        .borderRadius({ topLeft: 22, topRight: 22 })
      Row()
        .width(4)
        .height(42)
        .backgroundColor('#8a562c')
      Row()
        .width(70)
        .height(8)
        .backgroundColor('#8a562c')
        .borderRadius(4)
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  Radio() {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        Row()
          .layoutWeight(1)
          .height(28)
          .backgroundColor('#3a2111')
          .border({ width: 1, color: '#b1793d', radius: 4 })
        Row()
          .width(28)
          .height(28)
          .borderRadius(14)
          .backgroundColor('#8a562c')
      }
      Row()
        .width('100%')
        .height(8)
        .backgroundColor('#2a160b')
        .borderRadius(4)
    }
    .width(130)
    .padding(12)
    .backgroundColor('#5a3218')
    .border({ width: 2, color: '#1b0d05', radius: 10 })
  }

  @Builder
  Clouds() {
    Stack() {
      Row()
        .width(70)
        .height(32)
        .backgroundColor('#ccffffff')
        .borderRadius(16)
        .offset({ x: -170, y: -150 })
      Row()
        .width(96)
        .height(38)
        .backgroundColor('#bbffffff')
        .borderRadius(19)
        .offset({ x: 170, y: -90 })
      Text('☆')
        .fontSize(30)
        .fontColor('#ffc36a')
        .offset({ x: 120, y: -160 })
      Text('♡')
        .fontSize(28)
        .fontColor('#ef8f9a')
        .offset({ x: -120, y: 62 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  CuteCharacter() {
    Stack() {
      Row()
        .width(this.isLandscape ? 132 : 136)
        .height(this.isLandscape ? 92 : 98)
        .backgroundColor('#fff6ef')
        .border({ width: 2, color: '#d99587', radius: 60 })
      Text('• ᴗ •')
        .fontSize(this.isLandscape ? 24 : 25)
        .fontColor('#7d4d48')
        .margin({ top: this.isLandscape ? 12 : 16 })
      Row()
        .width(this.isLandscape ? 170 : 178)
        .height(this.isLandscape ? 32 : 32)
        .backgroundColor('#f7bac4')
        .borderRadius(22)
        .offset({ y: this.isLandscape ? 56 : 62 })
      Text('★')
        .fontSize(this.isLandscape ? 42 : 48)
        .fontColor('#ffd36f')
        .offset({ x: this.isLandscape ? 88 : 92, y: 10 })
    }
    .width(this.isLandscape ? 200 : 220)
    .height(this.isLandscape ? 116 : 140)
    .margin({ top: this.isLandscape ? 0 : 14 })
  }

  @Builder
  CuteMessageCard() {
    Column({ space: 8 }) {
      Text('早点休息哦~')
        .posterLabel(this.isLandscape ? 18 : 20, '#b86b63')
      Text('明天也要元气满满！')
        .posterLabel(this.isLandscape ? 15 : 16, '#b86b63')
    }
    .padding(this.isLandscape ? 14 : 16)
    .backgroundColor('#ccfff8e8')
    .border({ width: 1, color: '#e9b7a9', radius: 14 })
    .width(this.isLandscape ? '34%' : '78%')
    .margin({ top: this.isLandscape ? 0 : 12 })
  }

  @Builder
  MinimalStat(value: string, label: string, color: ResourceColor) {
    Row({ space: 12 }) {
      Row()
        .width(10)
        .height(10)
        .borderRadius(5)
        .backgroundColor(color)
      Column() {
        Text(value)
          .posterLabel(22, '#ffffff')
        Text(label)
          .posterLabel(15, '#bfbfbf')
      }
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  FunnyFace() {
    Stack() {
      Row()
        .width(this.isLandscape ? 156 : 124)
        .height(this.isLandscape ? 176 : 136)
        .backgroundColor('#f1dfc4')
        .borderRadius({ topLeft: 70, topRight: 70, bottomLeft: 30, bottomRight: 30 })
      Text('ಠ  ಠ')
        .fontSize(this.isLandscape ? 28 : 22)
        .fontColor('#111111')
        .offset({ y: -22 })
      Row()
        .width(this.isLandscape ? 74 : 58)
        .height(this.isLandscape ? 14 : 11)
        .backgroundColor('#f08a2b')
        .borderRadius(7)
        .offset({ y: 10 })
      Row()
        .width(this.isLandscape ? 82 : 66)
        .height(this.isLandscape ? 56 : 44)
        .backgroundColor('#d7d5cf')
        .border({ width: 3, color: '#181818', radius: 8 })
        .offset({ x: 76, y: 72 })
      Row()
        .width(this.isLandscape ? 70 : 56)
        .height(this.isLandscape ? 20 : 16)
        .backgroundColor('#5b341b')
        .borderRadius(10)
        .offset({ x: 76, y: 50 })
    }
    .width(this.isLandscape ? 260 : 210)
    .height(this.isLandscape ? 240 : 188)
    .margin({ right: this.isLandscape ? 36 : 0, bottom: this.isLandscape ? 0 : 24 })
  }
}
