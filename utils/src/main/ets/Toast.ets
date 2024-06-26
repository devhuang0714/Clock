import promptAction from '@ohos.promptAction';

export class Toast {
  public static show(message: string) {
    promptAction.showToast({
      message: message,
      duration: 1500
    })
  }
}