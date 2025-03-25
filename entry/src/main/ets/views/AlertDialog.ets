@CustomDialog
export struct AlertDialog {
  private controller: CustomDialogController
  @State cancelText: string = '取消'
  @State confirmText: string = '确定'
  private cancel: () => void = () => {
  }
  private confirm: () => void = () => {
  }
  private message: string = '确定要删除吗？'

  build() {
    Column() {
      Text(`${this.message}`)
        .fontSize(16)
        .fontColor($r('app.color.flip_text_color'))
        .textAlign(TextAlign.Center)
        .margin({ top: 20, left: 12, right: 12, bottom: 20 })

      Row() {
        Button(this.cancelText, { type: ButtonType.Normal })
          .foregroundColor($r('app.color.flip_text_color'))
          .backgroundColor($r('app.color.flip_card_bg_color'))
          .layoutWeight(1)
          .border({
            width: {
              right: 1
            },
            color: $r('app.color.divider_color')
          })
          .onClick(() => {
            this.controller.close()
            this.cancel()
          })
        Button(this.confirmText, { type: ButtonType.Normal })
          .foregroundColor($r('app.color.confirm'))
          .backgroundColor($r('app.color.flip_card_bg_color'))
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close()
            this.confirm()
          })
      }
      .height(44)
      .border({
        width: {
          top: 1
        },
        color: $r('app.color.divider_color')
      })
    }
    .backgroundColor($r('app.color.flip_card_bg_color'))
    .border({
      color: $r('app.color.flip_card_bg_color'),
      radius: 8
    })
  }
}