import { MailEngine } from "@coremail/mail_base";
import router from '@ohos.router';
import { Toast } from 'utils'
import { AppConstants, Icons } from '../../common/constants/Constants';
import { NavigationBar } from '../../views/NavigationBar'

@Entry
@Component
struct FeedbackPage {
  @State content: string = ''
  controller: TextAreaController = new TextAreaController()

  async sendEmail() {
    if (!this.content.trim().length) {
      Toast.show('请输入反馈内容')
      return
    }
    const engine = new MailEngine();
    engine.setProperties({
      imap: { host: 'imap.yeah.net', port: 993, secure: true },
      smtp: { host: 'smtp.yeah.net', port: 25, secure: false },
      userInfo: { username: 'hytest2020@yeah.net', password: 'VBZCBPEPKYFTPBRN' },
    });
    const transport = engine.getTransport();
    await transport.sendMail(
      { name: "翻页时钟", email: 'hytest2020@yeah.net' }, // 发件人
      [{ name: "development", email: "devhuang0714@gmail.com" }], // 收件人列表
      [], // 抄送列表
      [], // 暗送列表
      "【翻页时钟】意见反馈", // 邮件标题
      '', // 富文本正文
      this.content.trim(), // 纯文本正文
      [], // 内联图片
      []
    );
    router.back()
  }

  build() {
    Column() {
      NavigationBar({
        title: $r('app.string.privacy_text_title'),
        builder: this.CommitItem
      })

      TextArea({
        text: $$this.content,
        placeholder: '快说出您宝贵的意见或建议吧，您的反馈是我改进的动力。',
        controller: this.controller
      })
        .placeholderFont({
          size: 16
        })
        .placeholderColor('#999999')
        .fontSize(16)
        .fontColor($r('app.color.main_text_color'))
        .caretColor('#09AFFF')
        .margin({ top: 24, left: 12, right: 12 })
        .padding({ left: 8, right: 8 })
        .borderRadius(8)
        .height(200)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
  }

  @Builder
  CommitItem() {
    Button() {
      Text('提交')
        .fontSize(18)
        .fontColor($r('app.color.blue'))
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          this.controller.stopEditing()
          this.content = this.content.trim()
          this.sendEmail()
        })
    }
    .type(ButtonType.Normal)
    .backgroundColor(Color.Transparent)
    .margin({ right: 24 })
  }
}