import pasteboard from '@ohos.pasteboard';
import { Toast } from 'utils/Index';
import { AppConstants, Icons } from '../../common/constants/Constants';
import { common } from '@kit.AbilityKit';
// import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import fs from '@ohos.file.fs';
// import { fileUri } from '@kit.CoreFileKit';
import { NavigationBar } from '../../views/NavigationBar';

const downloadUrl: string = `https://appgallery.huawei.com/app/detail?id=${AppConstants.BUNDLE_NAME}`;
const downloadImageName: string = '小布丁时钟下载.png'

@Entry
@Component
struct SharePage {
  @StorageProp('isLandscape') isLandscape: boolean = false

  async copyQRCode() {
    let sysPasteboard = pasteboard.getSystemPasteboard()
    let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, downloadUrl);
    sysPasteboard.setData(pasteData)
    Toast.show('下载链接已复制到剪贴板')
  }

  getShareImageUri(): string {
    // let context = getContext(this) as common.UIAbilityContext;
    // try {
    //   // 沙箱路径
    //   let filePath = context.filesDir + '/' + downloadImageName
    //   let uri = fileUri.getUriFromPath(filePath)
    //   if (fs.accessSync(filePath)) {
    //     console.log(`${filePath} 文件已存在`)
    //     return uri
    //   }
    //
    //   // 从rawfile中写入沙盒
    //   let file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE)
    //   let array = getContext().resourceManager.getRawFileContentSync(`images/${downloadImageName}`)
    //   fs.writeSync(file.fd, array.buffer)
    //   fs.closeSync(file.fd)
    //   console.log(`${filePath} 写入成功`)
    //
    //   return uri
    // } catch (error) {
    //   console.log(`getRawFileContentSync failed: ${error}`)
    // }
    return ''
  }

  shareAction() {
    // 构造ShareData，需配置一条有效数据信息
    // let data: systemShare.SharedData = new systemShare.SharedData({
    //   utd: utd.UniformDataType.PLAIN_TEXT,
    //   content: downloadUrl
    // });
    //
    // let uri = this.getShareImageUri()
    // if (uri.length > 0) {
    //   // 额外再添加一条记录
    //   data.addRecord({
    //     utd: utd.UniformDataType.PNG,
    //     uri: uri
    //   });
    // }
    //
    // // 构建ShareController
    // let controller: systemShare.ShareController = new systemShare.ShareController(data);
    // // 注册分享面板关闭监听
    // controller.on('dismiss', () => {
    //   console.info('Share panel closed');
    //   // 分享结束，可处理其他业务。
    // });
    //
    // // 获取UIAbility上下文对象
    // let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    // // 进行分享面板显示
    // controller.show(context, {
    //   previewMode: systemShare.SharePreviewMode.DETAIL,
    //   selectionMode: systemShare.SelectionMode.SINGLE
    // });
  }

  build() {
    Column() {
      NavigationBar({
        title: '分享',
        builder: () => {
          this.NavMenuBuilder()
        }
      })

      Column() {
        Text('扫描以下二维码：')
          .fontSize(16)
          .fontColor($r('app.color.flip_text_color'))
          .margin({ bottom: 12 })

        Image($rawfile(`images/${downloadImageName}`))
          .objectFit(ImageFit.Contain)
          .width(this.isLandscape ? 180 : 280)
          .height(this.isLandscape ? 180 : 280)
          .onClick(() => {
            this.copyQRCode()
          })

        Text('（点击复制链接）')
          .fontSize(16)
          .fontColor($r('app.color.flip_text_color'))
          .margin({ top: 12 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.main_background_color'))
      .padding({ top: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main_background_color'))
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  NavMenuBuilder() {
    Row({ space: 2 }) {
      Button() {
        Text(Icons.SHARE)
          .fontFamily(Icons.FONT_FAMILY)
          .fontSize(24)
          .fontColor($r('app.color.flip_text_color'))
      }
      .type(ButtonType.Normal)
      .borderRadius(3)
      .backgroundColor(Color.Transparent)
      .padding(8)
      .margin({ right: 12 })
      .onClick(() => {
        this.shareAction()
      })
    }
    .alignItems(VerticalAlign.Center)
    .height('100%')
  }
}