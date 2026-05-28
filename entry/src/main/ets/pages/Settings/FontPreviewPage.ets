import { AppConstants, Icons } from '../../common/constants/Constants'
import { NavigationBar } from '../../views/NavigationBar'

interface FontPreviewItem {
  name: string
  family: string
  status: string
  statusColor: ResourceColor
  digitsMonospace: boolean
  style?: string
  scene?: string
  note: string
}

@Entry
@Component
struct FontPreviewPage {
  private fonts: FontPreviewItem[] = [
    {
      name: 'Iceland',
      family: Icons.FONT_ICELAND,
      status: '可商用',
      statusColor: '#247a46',
      digitsMonospace: true,
      note: 'Google Fonts / SIL Open Font License 1.1，可用于商业产品和应用嵌入。'
    },
    {
      name: 'Nova Mono',
      family: Icons.FONT_NOVA_MONO,
      status: '可商用',
      statusColor: '#247a46',
      digitsMonospace: true,
      note: 'Google Fonts / SIL Open Font License 1.1，可用于商业产品和应用嵌入。'
    },
    {
      name: 'Geo',
      family: Icons.FONT_GEO,
      status: '可商用',
      statusColor: '#247a46',
      digitsMonospace: true,
      note: 'Google Fonts / SIL Open Font License 1.1，可用于商业产品和应用嵌入。'
    },
    {
      name: 'Monofett',
      family: Icons.FONT_MONOFETT,
      status: '可商用',
      statusColor: '#247a46',
      digitsMonospace: true,
      note: 'Google Fonts / SIL Open Font License 1.1，可用于商业产品和应用嵌入。'
    },
    {
      name: 'DSEG7 Classic',
      family: Icons.FONT_DSEG7_CLASSIC,
      status: '可商用',
      statusColor: '#247a46',
      digitsMonospace: true,
      style: '电子钟 / LED',
      scene: '已用于电子 LED 表盘；数字等宽，适合带秒、秒表和动态计时。',
      note: 'DSEG / SIL Open Font License 1.1，专业七段数码管字体。'
    },
    {
      name: 'IBM Plex Mono',
      family: Icons.FONT_IBM_PLEX_MONO,
      status: '可商用',
      statusColor: '#247a46',
      digitsMonospace: true,
      style: '极简高级 / 工程感',
      scene: '已用于极简高级表盘；数字等宽，适合长时间桌面显示。',
      note: 'Google Fonts / SIL Open Font License 1.1，适合高级极简和工程感 UI。'
    },
    {
      name: 'Space Mono',
      family: Icons.FONT_SPACE_MONO,
      status: '可商用',
      statusColor: '#247a46',
      digitsMonospace: true,
      style: 'Terminal / 复古航天',
      scene: '已用于终端复古表盘；数字等宽，适合黑白、命令行和 NASA 风。',
      note: 'Google Fonts / SIL Open Font License 1.1，适合 Terminal 和复古航天风。'
    },
    {
      name: 'Erbos Draco 1st Open NBP',
      family: Icons.FONT_ERBOS_DRACO_1ST_OPEN_NBP,
      status: '需署名',
      statusColor: '#247a46',
      digitsMonospace: true,
      note: '字体元数据为 CC BY-SA 3.0，商业可用但需要署名并遵守相同方式共享条款。'
    },
    {
      name: 'Jura',
      family: Icons.FONT_JURA,
      status: '可商用',
      statusColor: '#247a46',
      digitsMonospace: false,
      note: 'Google Fonts / SIL Open Font License 1.1，可用于商业产品和应用嵌入。'
    },
    {
      name: 'Raleway Dots',
      family: Icons.FONT_RALEWAY_DOTS,
      status: '可商用',
      statusColor: '#247a46',
      digitsMonospace: false,
      note: 'Google Fonts / SIL Open Font License 1.1，可用于商业产品和应用嵌入。'
    },
    {
      name: 'Nova Square',
      family: Icons.FONT_NOVA_SQUARE,
      status: '可商用',
      statusColor: '#247a46',
      digitsMonospace: false,
      note: 'Google Fonts / SIL Open Font License 1.1，可用于商业产品和应用嵌入。'
    },
    {
      name: 'Megrim',
      family: Icons.FONT_MEGRIM,
      status: '可商用',
      statusColor: '#247a46',
      digitsMonospace: false,
      note: 'Google Fonts / SIL Open Font License 1.1，可用于商业产品和应用嵌入。'
    },
    {
      name: 'Orbitron',
      family: Icons.FONT_ORBITRON,
      status: '可商用',
      statusColor: '#247a46',
      digitsMonospace: false,
      style: '赛博朋克 / 科幻 HUD',
      scene: '已用于赛博 HUD 表盘；主字体风格强，带秒时更适合作为标题或搭配数字等宽字体。',
      note: 'Google Fonts / SIL Open Font License 1.1，适合赛博朋克和 HUD 发光数字。'
    },
    {
      name: 'Exo 2',
      family: Icons.FONT_EXO2,
      status: '可商用',
      statusColor: '#247a46',
      digitsMonospace: false,
      style: '现代科技 / 智能仪表',
      scene: '已用于科技仪表盘；适合信息面板、状态标签和轻科技风主视觉。',
      note: 'Google Fonts / SIL Open Font License 1.1，适合现代科技仪表盘。'
    },
    {
      name: 'Audiowide',
      family: Icons.FONT_AUDIOWIDE,
      status: '可商用',
      statusColor: '#247a46',
      digitsMonospace: false,
      style: 'Synthwave / 游戏 HUD',
      scene: '已用于霓虹合成波表盘；适合复古科幻、游戏感和强装饰标题。',
      note: 'Google Fonts / SIL Open Font License 1.1，适合 Synthwave 和游戏 HUD。'
    }
  ]

  build() {
    Column() {
      NavigationBar({
        title: '字体预览'
      })

      List({ space: 12 }) {
        ForEach(this.fonts, (item: FontPreviewItem) => {
          ListItem() {
            this.FontItem(item)
          }
        })

        ListItem()
          .height(AppConstants.DEFAULT_NAV_HEIGHT + 12)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 12, right: 12, top: 12 })
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
  }

  @Builder
  FontItem(item: FontPreviewItem) {
    Column({ space: 10 }) {
      Row() {
        Text(item.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.main_text_color'))
          .layoutWeight(1)

        Text(item.status)
          .fontSize(12)
          .fontColor(Color.White)
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor(item.statusColor)
          .borderRadius(4)

        if (!item.digitsMonospace) {
          Text('数字非等宽')
            .fontSize(12)
            .fontColor(Color.White)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor('#b9482e')
            .borderRadius(4)
            .margin({ left: 6 })
        }
      }
      .width('100%')

      Text('23:58:36')
        .fontFamily(item.family)
        .fontSize(44)
        .minFontSize(26)
        .maxLines(1)
        .fontColor($r('app.color.main_text_color'))
        .width('100%')

      Text('CLOCK 2026/05/27  ABC xyz 0123456789')
        .fontFamily(item.family)
        .fontSize(22)
        .minFontSize(14)
        .maxLines(1)
        .fontColor($r('app.color.main_text_color'))
        .opacity(0.75)
        .width('100%')

      if (item.style != undefined) {
        Text(item.style ?? '')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.main_text_color'))
          .opacity(0.86)
          .width('100%')
      }

      if (item.scene != undefined) {
        Text(item.scene ?? '')
          .fontSize(12)
          .lineHeight(18)
          .fontColor($r('app.color.main_text_color'))
          .opacity(0.66)
          .width('100%')
      }

      Text(item.note)
        .fontSize(12)
        .lineHeight(18)
        .fontColor($r('app.color.main_text_color'))
        .opacity(0.66)
        .width('100%')

      if (!item.digitsMonospace) {
        Text('提示：0-9 数字宽度不一致，不建议用于带秒或毫秒的动态时钟。')
          .fontSize(12)
          .lineHeight(18)
          .fontColor('#b9482e')
          .width('100%')
      }
    }
    .width('100%')
    .padding(14)
    .borderRadius(8)
    .backgroundColor($r('app.color.flip_card_bg_color'))
  }
}
