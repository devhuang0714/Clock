import { ClockConfig, CLOCK_CONFIGS } from '../views/Clocks/ClockConfig';
import preferences from '@ohos.data.preferences';
import { AppConstants } from '../common/constants/Constants';

const defaultClockKey = 'defaultClockConfig'

export class ClockConfigManager {
  static setDefaultConfig(config: ClockConfig) {
    // 保存默认选择
    const preference = preferences.getPreferencesSync(getContext(), {
      name: AppConstants.BUNDLE_NAME
    })
    preference.put(defaultClockKey, JSON.stringify(config))
    preference.flush()
  }

  static getDefaultConfig(): ClockConfig {
    let clockConfig = CLOCK_CONFIGS[0]
    // 保存默认选择
    const preference = preferences.getPreferencesSync(getContext(), {
      name: AppConstants.BUNDLE_NAME
    })
    let configJson = preference.getSync(defaultClockKey, undefined) as string
    if (configJson != undefined) {
      clockConfig = JSON.parse(configJson)
    }
    return clockConfig
  }
}