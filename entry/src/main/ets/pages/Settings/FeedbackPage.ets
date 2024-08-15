import { MailEngine } from "@coremail/mail_base";
import router from '@ohos.router';
import { Toast } from 'utils'
import { NavigationBar } from '../../views/NavigationBar'
import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Icons } from '../../common/constants/Constants';
import { AppInfo } from '../../common/utils/AppInfo'
import pasteboard from '@ohos.pasteboard';
import { deviceInfo } from '@kit.BasicServicesKit';

@Entry
@Component
struct FeedbackPage {
  @State content: string = ''
  controller: TextAreaController = new TextAreaController()

  async commit() {
    const extInfo = `
    appVersion: ${AppInfo.getVersion()}
    deviceType: ${deviceInfo.deviceType}
    manufactureInfo: ${deviceInfo.manufacture}
    marketName: ${deviceInfo.marketName}
    osFullName: ${deviceInfo.osFullName}
    sdkApiVersionInfo: ${deviceInfo.sdkApiVersion}
    firstApiVersionInfo: ${deviceInfo.firstApiVersion}
    odid: ${deviceInfo.ODID}`

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
      this.content.trim() + '\n\n' + extInfo, // 纯文本正文
      [], // 内联图片
      []
    );
    router.back()
  }

  sendEmail() {
    let sysPasteboard = pasteboard.getSystemPasteboard()
    let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, 'devhuang0714@gmail.com');
    sysPasteboard.setData(pasteData)
    Toast.show('收件人地址已复制到剪贴板')

    let recipients = ['devhuang0714@gmail.com']

    let mailUri: string = 'mailto:';
    mailUri += recipients.join(',') || '';
    mailUri += '?cc=' + '';
    mailUri += '&bcc=' + '';
    mailUri += '&subject=' + 'subject';
    mailUri += '&body=' + 'body';

    let want: Want = {
      bundleName: 'com.huawei.hmos.email',
      abilityName: 'EntryAbility',
      moduleName: 'entry',
      uri: mailUri,
      action: 'ohos.want.action.viewData',
    }

    setTimeout(() => {
      try {
        let context = getContext(this) as common.UIAbilityContext;
        context.startAbility(want)
          .then(() => {
            console.log(`startAbility success ${mailUri}`);
          })
          .catch((err: BusinessError) => {
            console.log(`startAbility error: ${err}`);
          })
      } catch (e) {
        console.log(`error: ${e}`)
      }
    }, 1000)
  }

  build() {
    Column() {
      NavigationBar({
        title: '意见反馈',
        builder: (): void => {
          // 解决this指向问题，参考：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-builderparam-0000001820999553
          this.CommitItem()
        }
      })

      TextArea({
        text: $$this.content,
        placeholder: '快说出您宝贵的意见或建议吧，您的反馈是我改进的动力。\n\n您也可以发送邮件至：devhuang0714@gmail.com',
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
    Row({ space: 6 }) {
      Button() {
        Text(Icons.EMAIL)
          .fontFamily(Icons.FONT_FAMILY)
          .fontSize(24)
          .fontColor($r('app.color.flip_text_color'))
      }
      .type(ButtonType.Normal)
      .backgroundColor(Color.Transparent)
      .padding(8)
      .onClick(() => {
        this.sendEmail()
      })

      Button() {
        Text('提交')
          .fontSize(18)
          .fontColor($r('app.color.blue'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.controller.stopEditing()
            this.content = this.content.trim()
            this.commit()
          })
      }
      .type(ButtonType.Normal)
      .backgroundColor(Color.Transparent)
      .padding(8)
      .margin({ right: 16 })
    }
    .alignItems(VerticalAlign.Center)
    .height('100%')
  }
}