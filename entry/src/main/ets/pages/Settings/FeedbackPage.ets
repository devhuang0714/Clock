import { IBuffer, MailEngine, getFileName, openFile } from "@coremail/mail_base";
import router from '@ohos.router';
import { Toast } from 'utils'
import { NavigationBar } from '../../views/NavigationBar'
import { BusinessError } from '@kit.BasicServicesKit';
import { Icons } from '../../common/constants/Constants';
import { AppInfo } from '../../common/utils/AppInfo'
import pasteboard from '@ohos.pasteboard';
import { deviceInfo } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

interface FeedbackType {
  type: number
  title: string
  normalColor: ResourceColor
  selectedColor: ResourceColor
  placeholder: string
  emailTitle: string
  emailTips: string
}

interface FeedbackAttachment {
  fileName: string
  content: IBuffer
}

interface FeedbackInfo {
  extInfo: Record<string, string | number>
}

function displayFeedbackValue(value: string | number | boolean | null | undefined): string {
  const text = String(value ?? '').trim()
  return text.length > 0 ? text : '-'
}

function buildFeedbackSummary(extInfo: Record<string, string | number>): string {
  const deviceParts = [
    String(extInfo['manufactureInfo'] ?? '').trim(),
    String(extInfo['marketName'] ?? '').trim(),
    String(extInfo['deviceType'] ?? '').trim(),
  ].filter((item: string) => item.length > 0)
  const osParts = [
    String(extInfo['distributionOSName'] ?? '').trim(),
    String(extInfo['distributionOSVersion'] ?? '').trim(),
    String(extInfo['displayVersion'] ?? '').trim(),
  ].filter((item: string) => item.length > 0)

  const lines: string[] = [
    '【关键信息】',
    `App版本：${displayFeedbackValue(extInfo['appVersion'])} (${displayFeedbackValue(extInfo['versionCode'])})`,
    `设备信息：${displayFeedbackValue(deviceParts.join(' / '))}`,
    `系统版本：${displayFeedbackValue(osParts.join(' / '))}`,
    `设备ID：${displayFeedbackValue(extInfo['odid'])}`,
  ]
  return lines.join('\n')
}

@Entry
@Component
struct FeedbackPage {
  @State types: FeedbackType[] = [
    {
      type: 1000,
      title: '意见建议',
      normalColor: '#666666',
      selectedColor: $r('app.color.blue'),
      placeholder: '您有任何使用过程中的问题，或者希望增加一些交互/功能，都可以提交反馈。\n您的反馈是我改进的动力。\n\n您也可以发送邮件至：devhuang0714@gmail.com',
      emailTitle: '邮箱（如果您希望得到回复）',
      emailTips: '',
    },
    {
      type: 2000,
      title: '功能异常',
      normalColor: '#666666',
      selectedColor: Color.Red,
      placeholder: '请尽量详细描述一下异常的功能、出现步骤和现象。收到后我会尽快定位处理。\n\n您也可以发送邮件至：devhuang0714@gmail.com',
      emailTitle: '邮箱（如果您希望得到回复）',
      emailTips: '如果问题和显示、横竖屏、桌面小组件有关，建议附上截图，定位会更快。',
    },
  ]
  @State content: string = ''
  @State selectedType: FeedbackType = this.types[0]
  @State receiveEmail: string = ''
  @State selectedImageUris: string[] = []
  @State pageWidth: number = 0
  @State pageHeight: number = 0
  @State sending: boolean = false
  controller: TextAreaController = new TextAreaController()
  private readonly maxAttachmentCount: number = 3
  private readonly attachmentPreviewSize: number = 72
  private readonly contactEmail: string = 'devhuang0714@gmail.com'

  get isLandscape(): boolean {
    return this.pageWidth > this.pageHeight && this.pageWidth >= 700
  }

  async selectImages() {
    if (this.selectedImageUris.length >= this.maxAttachmentCount) {
      Toast.show(`最多只能添加${this.maxAttachmentCount}张图片`)
      return
    }

    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = this.maxAttachmentCount - this.selectedImageUris.length;
    let photoViewPicker = new photoAccessHelper.PhotoViewPicker();

    try {
      const result = await photoViewPicker.select(photoSelectOptions)
      if (result.photoUris.length === 0) {
        return
      }

      const mergedUris = this.selectedImageUris.concat(result.photoUris)
      this.selectedImageUris = Array.from(new Set(mergedUris)).slice(0, this.maxAttachmentCount)
    } catch (err) {
      const error = err as BusinessError
      if (error.code) {
        Toast.show('选择图片失败，请重试')
      }
    }
  }

  removeSelectedImage(uri: string) {
    this.selectedImageUris = this.selectedImageUris.filter((item: string) => item !== uri)
  }

  copyContactEmail() {
    let sysPasteboard = pasteboard.getSystemPasteboard()
    let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.contactEmail);
    sysPasteboard.setData(pasteData)
    Toast.show('邮箱地址已复制到剪贴板')
  }

  buildFeedbackInfo(): FeedbackInfo {
    const bundleInfo = AppInfo.getInfo()
    const appVersion = AppInfo.getVersion()
    let extInfo: Record<string, string | number> = {
      "appVersion": appVersion,
      "versionCode": bundleInfo['versionCode'] ?? '',
      "bundleName": bundleInfo['bundleName'] ?? '',
      "deviceType": deviceInfo.deviceType,
      "manufactureInfo": deviceInfo.manufacture,
      "marketName": deviceInfo.marketName,
      "displayVersion": deviceInfo.displayVersion,
      "incrementalVersion": deviceInfo.incrementalVersion,
      "osReleaseType": deviceInfo.osReleaseType,
      "osFullName": deviceInfo.osFullName,
      "sdkApiVersionInfo": deviceInfo.sdkApiVersion,
      "firstApiVersionInfo": deviceInfo.firstApiVersion,
      "buildType": deviceInfo.buildType,
      "distributionOSName": deviceInfo.distributionOSName,
      "distributionOSVersion": deviceInfo.distributionOSVersion,
      "distributionOSReleaseType": deviceInfo.distributionOSReleaseType,
      "odid": deviceInfo.ODID,
    }

    return {
      extInfo,
    }
  }

  buildEmailContent(feedbackInfo: FeedbackInfo): string {
    let emailContent = this.content.trim()
    emailContent += '\n\n' + `反馈类型：${this.selectedType.title}`

    if (this.receiveEmail !== undefined && this.receiveEmail.trim().length > 0) {
      emailContent += '\n' + `接收邮件：${this.receiveEmail.trim()}`
    }

    emailContent += '\n\n' + buildFeedbackSummary(feedbackInfo.extInfo)
    emailContent += '\n\n【原始附加字段】\n' + JSON.stringify(feedbackInfo.extInfo)

    return emailContent
  }

  async commit() {
    if (this.sending) {
      return
    }

    if (!this.content.trim().length) {
      Toast.show('请输入反馈内容')
      return
    }
    this.sending = true

    const feedbackInfo = this.buildFeedbackInfo()
    const attachments: FeedbackAttachment[] = this.selectedImageUris.map((uri: string, index: number): FeedbackAttachment => {
      const name = getFileName(uri)
      const attachment: FeedbackAttachment = {
        fileName: name.length > 0 ? name : `feedback_image_${index + 1}.jpg`,
        content: openFile(uri, 'r'),
      }
      return attachment
    })

    try {
      const engine = new MailEngine();
      engine.setProperties({
        imap: { host: 'imap.yeah.net', port: 993, secure: true },
        smtp: { host: 'smtp.yeah.net', port: 25, secure: false },
        userInfo: { username: 'hytest2020@yeah.net', password: 'VBZCBPEPKYFTPBRN' },
      });
      const transport = engine.getTransport();
      await transport.sendMail(
        { name: "小布丁时钟", email: 'hytest2020@yeah.net' }, // 发件人
        [{ name: "development", email: this.contactEmail }], // 收件人列表
        [], // 抄送列表
        [], // 暗送列表
        `【小布丁时钟】意见反馈-${this.selectedType.title}`, // 邮件标题
        '', // 富文本正文
        this.buildEmailContent(feedbackInfo), // 纯文本正文
        [], // 内联图片
        attachments
      );
      router.back()
    } catch (err) {
      const error = err as BusinessError
      Toast.show(`提交失败：${error.message ?? '请稍后重试'}`)
    } finally {
      this.sending = false
    }
  }

  build() {
    Column() {
      NavigationBar({
        title: '意见反馈',
        builder: (): void => {
          this.CommitItem()
        }
      })

      Scroll() {
        if (this.isLandscape) {
          Row({ space: 20 }) {
            Column({ space: 18 }) {
              this.TypeSelector()
              this.ContentInput()
              this.EmailInput()
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Column({ space: 18 }) {
              this.Attachments()
              this.ContactInfo()
            }
            .width(320)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
          .padding(20)
        } else {
          Column({ space: 18 }) {
            this.TypeSelector()
            this.ContentInput()
            this.EmailInput()
            this.Attachments()
            this.ContactInfo()
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(20)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.TopStart)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
    .onAreaChange((oldArea: Area, newArea: Area) => {
      this.pageWidth = Number(newArea.width)
      this.pageHeight = Number(newArea.height)
    })
  }

  @Builder
  TypeSelector() {
    Row({ space: 12 }) {
      ForEach(this.types, (item: FeedbackType) => {
        Button() {
          Text(item.title)
            .fontSize(14)
            .fontColor(this.selectedType.type === item.type ? item.selectedColor : item.normalColor)
            .margin({
              left: 12,
              right: 12,
              top: 6,
              bottom: 6
            })
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .border({
          color: this.selectedType.type === item.type ? item.selectedColor : item.normalColor,
          width: 1
        })
        .borderRadius(6)
        .onClick(() => {
          this.selectedType = item
        })
      })
    }
    .width('100%')
  }

  @Builder
  ContentInput() {
    TextArea({
      text: $$this.content,
      placeholder: this.selectedType.placeholder,
      controller: this.controller
    })
      .placeholderFont({
        size: 14
      })
      .placeholderColor('#999999')
      .fontSize(16)
      .fontColor($r('app.color.main_text_color'))
      .caretColor('#09AFFF')
      .padding({ left: 8, right: 8 })
      .borderRadius(8)
      .height(this.isLandscape ? 220 : 160)
  }

  @Builder
  EmailInput() {
    Column({ space: 6 }) {
      Text(this.selectedType.emailTitle)
        .fontSize(14)
        .fontColor($r('app.color.main_text_color'))

      TextInput({
        text: $$this.receiveEmail,
        placeholder: '请输入您的邮箱'
      })
        .type(InputType.Email)
        .placeholderFont({
          size: 16
        })
        .placeholderColor('#999999')
        .fontSize(16)
        .fontColor($r('app.color.main_text_color'))
        .caretColor('#09AFFF')
        .padding({ left: 8, right: 8 })
        .borderRadius(8)
        .height(50)

      if (this.selectedType.emailTips.length > 0) {
        Text(this.selectedType.emailTips)
          .fontSize(12)
          .fontColor(Color.Red)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  Attachments() {
    Column({ space: 8 }) {
      Text(`反馈图片（最多${this.maxAttachmentCount}张）`)
        .fontSize(14)
        .fontColor($r('app.color.main_text_color'))

      Scroll() {
        Row({ space: 10 }) {
          ForEach(this.selectedImageUris, (item: string) => {
            Stack({ alignContent: Alignment.TopEnd }) {
              Image(item)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)

              Row() {
                Text(Icons.DELETE)
                  .fontFamily(Icons.FONT_FAMILY)
                  .fontSize(12)
                  .fontColor(Color.White)
              }
              .width(18)
              .height(18)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#99000000')
              .borderRadius(9)
              .margin({ top: 4, right: 4 })
              .onClick(() => {
                this.removeSelectedImage(item)
              })
            }
            .width(this.attachmentPreviewSize)
            .height(this.attachmentPreviewSize)
            .borderRadius(8)
            .clip(true)
            .backgroundColor(Color.White)
          })

          if (this.selectedImageUris.length < this.maxAttachmentCount) {
            Button() {
              Text(Icons.ADD)
                .fontFamily(Icons.FONT_FAMILY)
                .fontSize(28)
                .fontColor('#999999')
            }
            .width(this.attachmentPreviewSize)
            .height(this.attachmentPreviewSize)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .border({
              color: '#999999',
              width: 1
            })
            .onClick(() => {
              this.selectImages()
            })
          }
        }
        .alignItems(VerticalAlign.Center)
        .width('100%')
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ContactInfo() {
    Column({ space: 12 }) {
      Text('也可以通过邮箱反馈和沟通问题')
        .fontSize(14)
        .fontColor($r('app.color.main_text_color'))

      Row({ space: 6 }) {
        Text(`邮箱：${this.contactEmail}`)
          .fontSize(13)
          .fontColor('#666666')

        Text('复制')
          .fontSize(13)
          .fontColor('#666666')
      }
      .onClick(() => {
        this.copyContactEmail()
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  CommitItem() {
    Button() {
      Text(this.sending ? '发送中' : '发送')
        .fontSize(18)
        .fontColor($r('app.color.blue'))
        .fontWeight(FontWeight.Medium)
    }
    .type(ButtonType.Normal)
    .backgroundColor(Color.Transparent)
    .padding(8)
    .margin({ right: 16 })
    .enabled(!this.sending)
    .onClick(() => {
      this.controller.stopEditing()
      this.content = this.content.trim()
      this.commit()
    })
  }
}
