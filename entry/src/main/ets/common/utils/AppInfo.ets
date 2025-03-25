import bundleManager from '@ohos.bundle.bundleManager';
import { BusinessError } from '@ohos.base';
import HYLogger from './HYLogger'
import {display} from '@kit.ArkUI'
import { common, Want } from '@kit.AbilityKit';

export class AppInfo {
  static getVersion(): string {
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_ABILITY | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_REQUESTED_PERMISSION;

    let version = '1.0.0'
    try {
      let data = bundleManager.getBundleInfoForSelfSync(bundleFlags)
      version = data.versionName
      HYLogger.info(`getBundleInfoForSelfSync success data.versionName: ${data.versionName}`)
    } catch (err) {
      let message = (err as BusinessError).message;
      HYLogger.error('testTag', 'getBundleInfoForSelfSync failed: %{public}s', message);
    }
    return version
  }

  static getInfo(): Record<string, string> {
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_ABILITY | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_REQUESTED_PERMISSION;
    let info: Record<string, string> = {}
    try {
      let data = bundleManager.getBundleInfoForSelfSync(bundleFlags)
      info['bundleName'] = data.name
      info['versionCode'] = data.versionCode.toString()
      info['versionName'] = data.versionName
    } catch (err) {
      let message = (err as BusinessError).message;
      HYLogger.error('testTag', 'getBundleInfoForSelfSync failed: %{public}s', message);
    }
    return info
  }

  static goStore() {
    let context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
    let want: Want = {
      uri: 'https://appgallery.huawei.com/app/detail?id=C5765880207854789059'//通过这种方式跳转，可以评分
    }
    context.startAbility(want)
  }

  static getScreenWidth(): number {
    return px2vp(display.getDefaultDisplaySync().width)
  }

  static getScreenHeight(): number {
    return px2vp(display.getDefaultDisplaySync().height)
  }
}