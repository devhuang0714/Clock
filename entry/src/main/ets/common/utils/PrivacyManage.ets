import { BusinessError } from '@kit.BasicServicesKit';
import { privacyManager } from '@kit.StoreKit';
import Logger from '../utils/HYLogger'

export class PrivacyManage {
  static isAgree(): boolean {
    try {
      let appPrivacyResults: privacyManager.AppPrivacyResult[] = privacyManager.getAppPrivacyResult();
      Logger.info("Succeeded in getting AppPrivacyResult size = " + appPrivacyResults.length);
      for (let i = 0; i < appPrivacyResults.length; i++) {
        Logger.info("Succeeded in getting AppPrivacyResult type = " + appPrivacyResults[i]["type"] + ", version = " + appPrivacyResults[i]["versionCode"] + ", result = "+appPrivacyResults[i]["result"]);
        if (appPrivacyResults[i]["result"] === privacyManager.AppPrivacyResultType.FULL_MODE_AGREED) {
          return true
        }
      }
    } catch (error) {
      Logger.error("GetAppPrivacyResultPublic exception code: " + error.code + ", exception message: " + error.message);
    }
    return false
  }
}