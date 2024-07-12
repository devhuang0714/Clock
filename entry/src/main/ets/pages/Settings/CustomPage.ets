import { AppConstants } from '../../common/constants/Constants'
import { NavigationBar } from '../../views/NavigationBar'

interface CustomItem {
  title: string,
  isOn: true
}

@Entry
@Component
struct CustomPage {
  @State items: CustomItem[] = [
    {
      title: '24小时制',
      isOn: true,
    },
    {
      title: '显示AM/PM',
      isOn: true,
    },
    {
      title: '显示日期',
      isOn: true,
    },
    {
      title: '显示农历',
      isOn: true,
    },
    {
      title: '显示周',
      isOn: true,
    }
  ]

  build() {
    Column() {
      // Text('字体大小')
      //   .fontSize(16)
      //
      // Row({ space: 12 }) {
      //   Button('中')
      //     .fontSize(16)
      //
      //   Button('大')
      //     .fontSize(20)
      //
      //   Button('超大')
      //     .fontSize(24)
      // }
      // .width('100%')
      // .justifyContent(FlexAlign.Start)
      NavigationBar({
        title: '自定义'
      })

      List({ space: 12 }) {
        ForEach(this.items, (item: CustomItem) => {
          ListItem() {
            Row() {
              Text(item.title)
                .fontSize(18)
                .fontColor($r('app.color.flip_text_color'))

              Blank()

              Toggle({
                type: ToggleType.Switch,
                isOn: item.isOn
              })
                .selectedColor(Color.Green)
            }
            .width('100%')
            .height(60)
            .padding({ left: 12, right: 12 })
          }
          .margin({ left: 24, right: 24 })
          .borderRadius(8)
          .backgroundColor($r('app.color.flip_card_bg_color'))
        })

        ListItem()
          .height(AppConstants.DEFAULT_NAV_HEIGHT)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
    .alignItems(HorizontalAlign.Start)
  }
}