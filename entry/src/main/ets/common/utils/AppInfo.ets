import bundleManager from '@ohos.bundle.bundleManager';
import { BusinessError } from '@ohos.base';
import HYLogger from './HYLogger'
import {display} from '@kit.ArkUI'

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

  static getScreenWidth(): number {
    return px2vp(display.getDefaultDisplaySync().width)
  }

  static getScreenHeight(): number {
    return px2vp(display.getDefaultDisplaySync().height)
  }
}