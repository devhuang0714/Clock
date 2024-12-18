import { updateManager } from '@kit.StoreKit';
import type { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import dataPreferences from '@ohos.data.preferences'
import Logger from '../utils/HYLogger'
import { AppInfo } from '../utils/AppInfo'

export class UpdateManager {
  static checkUpdate() {
    const context = getContext() as common.UIAbilityContext
    let options: dataPreferences.Options = { name: 'AccountBook' };
    let preferences = dataPreferences.getPreferencesSync(context, options);

    const now = new Date().getTime()
    const currentVersion = AppInfo.getVersion()
    const checkUpdateLocalVersion = preferences.getSync('checkUpdateLocalVersion', '') as string
    if (checkUpdateLocalVersion == currentVersion) {
      const checkUpdateTimeStamp = preferences.getSync('checkUpdateTimeStamp', 0) as number
      if (now - checkUpdateTimeStamp <= 24 * 3600 * 7) {
        return
      }
    }

    try {
      updateManager.checkAppUpdate(context)
        .then((checkResult: updateManager.CheckUpdateResult) => {
          Logger.info("Succeeded in checking Result updateAvailable:" + checkResult.updateAvailable);
          if (checkResult.updateAvailable === 1) {
            UpdateManager.showUpdateDialog()

            preferences.putSync('checkUpdateLocalVersion', currentVersion)
            preferences.putSync('checkUpdateTimeStamp', now)
            preferences.flush()
          }
        }).catch((error: BusinessError) => {
        Logger.error(`checkAppUpdate onError.code is ${error.code}, message is ${error.message}`);
      });
    } catch (error) {
      Logger.error(`checkAppUpdate onError.code is ${error.code}, message is ${error.message}`);
    }
  }

  static showUpdateDialog() {
    try {
      updateManager.showUpdateDialog(getContext() as common.UIAbilityContext)
        .then((resultCode: updateManager.ShowUpdateResultCode) => {
          Logger.info("Succeeded in showing UpdateDialog resultCode:" + resultCode);
        })
        .catch((error: BusinessError) => {
          Logger.error(`showUpdateDialog onError.code is ${error.code}, message is ${error.message}`);
        });
    } catch (error) {
      Logger.error(`showUpdateDialog onError.code is ${error.code}, message is ${error.message}`);
    }
  }
}