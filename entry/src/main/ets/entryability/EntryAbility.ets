import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@ohos.base';
import font from '@ohos.font';
import { GlobalContext } from 'utils/Index'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    GlobalContext.getContext().setObject('entryContext', this.context);

    // AppStorage.setOrCreate('currentColorMode', this.context.config.colorMode);
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onNewWant');
    GlobalContext.getContext().setObject('entryContext', this.context);
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    AppStorage.setOrCreate('currentColorMode', newConfig.colorMode);
    hilog.info(0x0000, 'testTag', 'the newConfig.colorMode is %{public}s', JSON.stringify(AppStorage.get('currentColorMode')) ?? '');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/LauncherPage', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');

      const fonts: Record<string, string>[] = [
        {
          'name': 'iconfont',
          'rawfile': 'iconfont.ttf'
        },
        {
          'name': 'led-font',
          'rawfile': 'led-font.ttf'
        },
        {
          'name': 'font-style1',
          'rawfile': 'font-style1.ttf'
        },
        {
          'name': 'font-style2',
          'rawfile': 'font-style2.otf'
        },
        {
          'name': 'font-style3',
          'rawfile': 'font-style3.otf'
        },
        {
          'name': 'font-style4',
          'rawfile': 'font-style4.ttf'
        },
        {
          'name': 'font-style5',
          'rawfile': 'font-style5.ttf'
        },
      ]
      // 注册IconFont
      fonts.map((item) => {
        font.registerFont({
          familyName: item.name,
          familySrc: $rawfile(item.rawfile)
        })
      })

      let windowClass: window.Window = windowStage.getMainWindowSync(); // 获取应用主窗口
      // 1. 设置窗口全屏
      let isLayoutFullScreen = true;
      windowClass.setWindowLayoutFullScreen(isLayoutFullScreen)
        .then(() => {
          console.info('Succeeded in setting the window layout to full-screen mode.');
        })
        .catch((err: BusinessError) => {
          console.error(`Failed to set the window layout to full-screen mode. Code is ${err.code}, message is ${err.message}`);
        });

      // 2. 设置状态栏和导航条隐藏
      windowClass.setSpecificSystemBarEnabled('status', false)
        .then(() => {
          console.info('Succeeded in setting the status bar to be invisible.');
        })
        .catch((err: BusinessError) => {
          console.error(`Failed to set the status bar to be invisible. Code is ${err.code}, message is ${err.message}`);
        });
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
