import { updateManager } from '@kit.StoreKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import type { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import dataPreferences from '@ohos.data.preferences'

export class UpdateManager {

  static checkUpdate() {
    const context = getContext() as common.UIAbilityContext
    let options: dataPreferences.Options = { name: 'AccountBook' };
    let preferences = dataPreferences.getPreferencesSync(context, options);

    const checkUpdateTimeStamp = preferences.getSync('checkUpdateTimeStamp', 0) as number
    const now = new Date().getTime()
    if (now - checkUpdateTimeStamp <= 24 * 3600 * 7) {
      return
    }

    try {
      updateManager.checkAppUpdate(context)
        .then((checkResult: updateManager.CheckUpdateResult) => {
          hilog.info(0, 'TAG', "Succeeded in checking Result updateAvailable:" + checkResult.updateAvailable);
          if (checkResult.updateAvailable === 1) {
            UpdateManager.showUpdateDialog()

            preferences.putSync('checkUpdateTimeStamp', now)
            preferences.flush()
          }
        }).catch((error: BusinessError) => {
        hilog.error(0, 'TAG', `checkAppUpdate onError.code is ${error.code}, message is ${error.message}`);
      });
    } catch (error) {
      hilog.error(0, 'TAG', `checkAppUpdate onError.code is ${error.code}, message is ${error.message}`);
    }
  }

  static showUpdateDialog() {
    try {
      updateManager.showUpdateDialog(getContext() as common.UIAbilityContext)
        .then((resultCode: updateManager.ShowUpdateResultCode) => {
          hilog.info(0, 'TAG', "Succeeded in showing UpdateDialog resultCode:" + resultCode);
        })
        .catch((error: BusinessError) => {
          hilog.error(0, 'TAG', `showUpdateDialog onError.code is ${error.code}, message is ${error.message}`);
        });
    } catch (error) {
      hilog.error(0, 'TAG', `showUpdateDialog onError.code is ${error.code}, message is ${error.message}`);
    }
  }

}