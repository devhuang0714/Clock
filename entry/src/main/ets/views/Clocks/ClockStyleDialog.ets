import { Icons } from '../../common/constants/Constants'

@CustomDialog
export struct ClockStyleDialog {
  controller: CustomDialogController
  @State offsetY: number = 200
  @State styles: Resource[] = [
    $r('app.media.flip_clock_default'),
    $r('app.media.round_clock_default'),
    $r('app.media.digital_clock_default'),
    $r('app.media.rotate_clock_style1'),
    $r('app.media.rotate_clock_style2'),
    $r('app.media.rotate_clock_style3'),
    $r('app.media.lunar_calendar_clock_style1'),
    $r('app.media.lunar_calendar_clock_style2'),
  ]
  @State selectedStyleIndex: number = 0

  build() {
    Column() {
      Column() {
        Grid() {
          ForEach(this.styles, (icon: Resource, index: number) => {
            GridItem() {
              Stack() {
                Image(icon)
                  .objectFit(ImageFit.Contain)

                if (index == this.selectedStyleIndex) {
                  Text(Icons.CHECKED)
                    .fontFamily(Icons.FONT_FAMILY)
                    .fontSize(24)
                    .fontColor(Color.Green)
                }
              }
              .alignContent(Alignment.BottomEnd)
            }
            .border({
              width: 3,
              color: this.selectedStyleIndex == index ? Color.Green : $r('app.color.flip_card_bg_color'),
              radius: 8
            })
            .onClick(() => {
              this.selectedStyleIndex = index
            })
          })
        }
        .height(60)
        .columnsGap(12)
        .rowsTemplate('1fr')
        .scrollBar(BarState.Off)
      }
      .height(200)
      .width('100%')
      .backgroundColor(0xCC000000)
      .offset({
        y: this.offsetY
      })
      .animation({
        duration: 400,
      })
    }
    .justifyContent(FlexAlign.End)
    .backgroundColor(Color.Transparent)
    .height('100%')
    .width('100%')
    .onClick(() => {
      this.controller.close()
    })
    .onAppear(() => {
      this.offsetY = 0
    })
  }
}