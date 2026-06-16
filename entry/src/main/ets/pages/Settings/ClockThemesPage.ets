import { AppConstants, Icons } from '../../common/constants/Constants'
import router from '@ohos.router';
import { ClockConfig, ClockType, CLOCK_CONFIGS } from '../../views/Clocks/ClockConfig';
import { FlipClock } from '../../views/Clocks/FlipClock';
import { RoundClock } from '../../views/Clocks/RoundClock';
import { DigitalClock } from '../../views/Clocks/DigitalClock';
import { RotateClock } from '../../views/Clocks/RotateClock';
import { LunarCalendarClock } from '../../views/Clocks/LunarCalendarClock';
import { NormalDigitalClock } from '../../views/Clocks/NormalDigitalClock';
import { StereoscopicClock } from '../../views/Clocks/StereoscopicClock';
import { PosterClock } from '../../views/Clocks/PosterClock';
import { MechanicalClock } from '../../views/Clocks/MechanicalClock';

interface ClockThemeGroup {
  title: string
  items: ClockConfig[]
}

function configsByIds(ids: string[]): ClockConfig[] {
  const configs: ClockConfig[] = []
  ids.forEach((id: string) => {
    const config = CLOCK_CONFIGS.find((item: ClockConfig) => item.id == id)
    if (config != undefined) {
      configs.push(config)
    }
  })
  return configs
}

const CLOCK_THEME_GROUPS: ClockThemeGroup[] = [
  {
    title: '基础数字',
    items: configsByIds([
      'flip_clock_style1',
      'digital_clock_style1',
      'normal_digital_clock_style1',
      'stereoscopic_clock_style1'
    ])
  },
  {
    title: '圆形指针',
    items: configsByIds([
      'round_clock_style1',
      'round_clock_style2',
      'round_clock_style3',
      'round_clock_style4',
      'round_clock_style5',
      'round_clock_style6',
      'round_clock_style7',
      'mechanical_clock_style1'
    ])
  },
  {
    title: '机械旋转',
    items: configsByIds([
      'rotate_clock_style1',
      'rotate_clock_style2',
      'rotate_clock_style3',
      'rotate_clock_style1_light',
      'rotate_clock_style2_light',
      'rotate_clock_style3_light'
    ])
  },
  {
    title: '日历时光',
    items: configsByIds([
      'lunar_calendar_clock_style1',
      'lunar_calendar_clock_style2'
    ])
  },
  {
    title: '赛博 HUD',
    items: configsByIds([
      'poster_clock_cyberpunk',
      'poster_clock_minimal',
      'poster_clock_orbitron_hud'
    ])
  },
  {
    title: '科技仪表',
    items: configsByIds([
      'poster_clock_exo_dashboard'
    ])
  },
  {
    title: '复古电子',
    items: configsByIds([
      'poster_clock_retro_flip',
      'poster_clock_dseg_led'
    ])
  },
  {
    title: '终端复古',
    items: configsByIds([
      'poster_clock_space_terminal'
    ])
  },
  {
    title: '霓虹合成波',
    items: configsByIds([
      'poster_clock_audiowide_synthwave'
    ])
  },
  {
    title: '极简高级',
    items: configsByIds([
      'poster_clock_plex_minimal'
    ])
  },
  {
    title: '可爱趣味',
    items: configsByIds([
      'poster_clock_cute',
      'poster_clock_funny',
      'poster_clock_office_snooze',
      'poster_clock_office_monday',
      'poster_clock_office_coffee',
      'poster_clock_office_payday'
    ])
  }
]

@Entry
@Component
struct ClockThemesPage {
  @State themeGroups: ClockThemeGroup[] = CLOCK_THEME_GROUPS
  @State selectedConfig: ClockConfig = CLOCK_CONFIGS[0]
  @StorageProp('isLandscape') isLandscape: boolean = false
  private previewDate: Date = new Date('2022-09-22 00:22:00')

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 300 })
      .slide(SlideEffect.Bottom)
    PageTransitionExit({ type: RouteType.Pop, duration: 300 })
      .slide(SlideEffect.Bottom)

    PageTransitionEnter({ type: RouteType.Pop, duration: 0 })
    PageTransitionExit({ type: RouteType.Push, duration: 1000 })
  }

  aboutToAppear(): void {
    let config = AppStorage.get<ClockConfig>('defaultClockConfig')
    if (config != undefined) {
      this.selectedConfig = config
    }
  }

  isSelected(item: ClockConfig): boolean {
    return this.selectedConfig.id == item.id
  }

  build() {
    Column() {
      Row() {
        Button('完成')
          .type(ButtonType.Normal)
          .padding(0)
          .fontSize(18)
          .fontColor($r('app.color.flip_text_color'))
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            AppStorage.setOrCreate('defaultClockConfig', this.selectedConfig)
            router.back({
              url: 'pages/Index'
            })
          })
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.End)
      .margin({ top: 40, bottom: 12, right: 12 })

      List({ space: 18 }) {
        ForEach(this.themeGroups, (group: ClockThemeGroup) => {
          ListItem() {
            Column({ space: 10 }) {
              Text(group.title)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.flip_text_color'))
                .width('100%')

              Grid() {
                ForEach(group.items, (item: ClockConfig) => {
                  this.ThemeGridItem(item)
                }, (item: ClockConfig) => item.id)
              }
              .rowsGap(12)
              .columnsGap(24)
              .columnsTemplate(this.isLandscape ? '1fr 1fr 1fr 1fr 1fr' : '1fr 1fr')
              .scrollBar(BarState.Off)
            }
            .width('100%')
          }
        })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)

      Button() {
        Text(Icons.PACK_UP)
          .fontFamily(Icons.FONT_FAMILY)
          .fontSize(28)
          .fontColor($r('app.color.flip_text_color'))
      }
      .type(ButtonType.Normal)
      .padding(8)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        router.back()
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
    .padding({
      bottom: AppConstants.DEFAULT_NAV_HEIGHT,
      left: 24,
      right: 24
    })
  }

  @Builder
  ThemeGridItem(item: ClockConfig) {
    GridItem() {
      Stack() {
        this.PreviewClockView(item)

        if (this.isSelected(item)) {
          Text(Icons.CHECKED)
            .fontFamily(Icons.FONT_FAMILY)
            .fontSize(24)
            .fontColor(Color.Green)
        }
      }
      .alignContent(Alignment.BottomEnd)
    }
    .height(60)
    .width(60 * 1150 / 534)
    .border({
      width: 2,
      color: this.isSelected(item) ? Color.Green : $r('app.color.flip_card_bg_color'),
      radius: 8
    })
    .clip(true)
    .onClick(() => {
      this.selectedConfig = item
    })
  }

  @Builder
  PreviewClockView(clockConfig: ClockConfig) {
    RelativeContainer() {
      Column() {
        if (clockConfig.type == ClockType.Flip) {
          FlipClock({
            date: this.previewDate,
            colorsConfig: clockConfig.colors,
            isLandscape: true
          })
        } else if (clockConfig.type == ClockType.Round) {
          RoundClock({
            date: this.previewDate,
            style: clockConfig.style
          })
        } else if (clockConfig.type == ClockType.Digital) {
          DigitalClock({
            date: this.previewDate,
            colorsConfig: clockConfig.colors,
          })
        } else if (clockConfig.type == ClockType.Rotate) {
          RotateClock({
            date: this.previewDate,
            style: clockConfig.style,
            colorsConfig: clockConfig.colors,
            lightOn: clockConfig.ext?.lightOn ?? false,
            isLandscape: true,
          })
        } else if (clockConfig.type == ClockType.LunarCalendar) {
          LunarCalendarClock({
            date: this.previewDate,
            style: clockConfig.style,
            colorsConfig: clockConfig.colors,
            isLandscape: true,
          })
        } else if (clockConfig.type == ClockType.NormalDigital) {
          NormalDigitalClock({
            date: this.previewDate,
            colorsConfig: clockConfig.colors,
            isLandscape: true,
          })
        } else if (clockConfig.type == ClockType.Stereoscopic) {
          StereoscopicClock({
            date: this.previewDate,
            colorsConfig: clockConfig.colors,
            isLandscape: true,
          })
        } else if (clockConfig.type == ClockType.Poster) {
          PosterClock({
            date: this.previewDate,
            style: clockConfig.style,
            colorsConfig: clockConfig.colors,
            isLandscape: true,
          })
        } else if (clockConfig.type == ClockType.Mechanical) {
          MechanicalClock({
            date: this.previewDate,
            isLandscape: true
          })
        }
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor(clockConfig.colors.backgroundColor)
      .alignRules({
        top: { anchor: "__container__", align: VerticalAlign.Top },
        left: { anchor: "__container__", align: HorizontalAlign.Start },
        right: { anchor: "__container__", align: HorizontalAlign.End },
        bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
      })
      .id("preview_clock")
      .height(534)
      .width(1150)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
    .scale({
      x: 60 / 534,
      y: 60 / 534
    })
  }
}
