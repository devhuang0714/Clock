import { ConfigurationConstant } from '@kit.AbilityKit';
import { BuilderNode, FrameNode, NodeController, NodeRenderType, PiPWindow, UIContext } from '@kit.ArkUI';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import mediaQuery from '@ohos.mediaquery';
import display from '@ohos.display';
import router from '@ohos.router';
import { AppConstants, Icons } from '../common/constants/Constants';
import { ClockController } from '../views/Clocks/ClockController'
import { RoundClock } from '../views/Clocks/RoundClock';
import { FlipCard, FlipCardController, FlipClock } from '../views/Clocks/FlipClock';
import { DigitalClock } from '../views/Clocks/DigitalClock';
import { LunarCalendarClock } from '../views/Clocks/LunarCalendarClock'
import { RotateClock } from '../views/Clocks/RotateClock'
import { ClockStyleDialog } from '../views/Clocks/ClockStyleDialog'
import {
  ClockConfig,
  ClockStyle,
  ClockType,
  CLOCK_CONFIGS,
  DEFAULT_GLOBAL_CONFIG,
  GlobalClockConfig
} from '../views/Clocks/ClockConfig'
import { NormalDigitalClock } from '../views/Clocks/NormalDigitalClock';
import { BusinessError } from '@kit.BasicServicesKit';
import dataPreferences from '@ohos.data.preferences';
import { StereoscopicClock } from '../views/Clocks/StereoscopicClock';
import { UpdateManager } from '../common/utils/UpdateManager';
import { PrivacyManage } from '../common/utils/PrivacyManage';
import { GlobalContext } from 'utils';
import { AlertDialog } from '../views/AlertDialog'
import { AppInfo } from '../common/utils/AppInfo';
import { PosterClock } from '../views/Clocks/PosterClock';
import { DEBUG } from 'utils/BuildProfile';
import { MechanicalClock } from '../views/Clocks/MechanicalClock';
import {
  CLOCK_PREVIEW_LANDSCAPE_HEIGHT,
  CLOCK_PREVIEW_LANDSCAPE_WIDTH,
  CLOCK_PREVIEW_PORTRAIT_HEIGHT,
  CLOCK_PREVIEW_PORTRAIT_WIDTH,
  ClockPreviewCanvas
} from '../views/Clocks/ClockPreviewCanvas';
import Icon from '../common/icons/Icon';

// 持久化存储UI状态
PersistentStorage.persistProp('currentColorMode', ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
PersistentStorage.persistProp('defaultClockConfig', CLOCK_CONFIGS[0])
PersistentStorage.persistProp('globalClockConfig', DEFAULT_GLOBAL_CONFIG)
PersistentStorage.persistProp('isLandscape', false)
PersistentStorage.persistProp('soundEnabled', true)

interface PipClockSize {
  width: number
  height: number
}

const PIP_CLOCK_SHORT_SIDE = 180
const PIP_CLOCK_PREVIEW_LANDSCAPE_WIDTH = CLOCK_PREVIEW_LANDSCAPE_WIDTH
const PIP_CLOCK_PREVIEW_LANDSCAPE_HEIGHT = CLOCK_PREVIEW_LANDSCAPE_HEIGHT
const PIP_CLOCK_PREVIEW_PORTRAIT_WIDTH = CLOCK_PREVIEW_PORTRAIT_WIDTH
const PIP_CLOCK_PREVIEW_PORTRAIT_HEIGHT = CLOCK_PREVIEW_PORTRAIT_HEIGHT
const PIP_CLOCK_CONTENT_FIT_SCALE = 0.96

function getScreenAspectRatio(): number {
  const defaultDisplay = display.getDefaultDisplaySync()
  const shortSide = Math.max(Math.min(defaultDisplay.width, defaultDisplay.height), 1)
  const longSide = Math.max(defaultDisplay.width, defaultDisplay.height)
  return longSide / shortSide
}

function getPipClockSize(isLandscape: boolean): PipClockSize {
  const longSide = Math.round(PIP_CLOCK_SHORT_SIDE * getScreenAspectRatio())
  return {
    width: isLandscape ? longSide : PIP_CLOCK_SHORT_SIDE,
    height: isLandscape ? PIP_CLOCK_SHORT_SIDE : longSide
  }
}

@Builder
function PipClockBuilder() {
  ClockPipView()
}

class ClockPipNodeController extends NodeController {
  private builderNode: BuilderNode<[]> | null = null
  private width: number = getPipClockSize(false).width
  private height: number = getPipClockSize(false).height

  constructor(isLandscape: boolean) {
    super()
    const size = getPipClockSize(isLandscape)
    this.width = size.width
    this.height = size.height
  }

  makeNode(uiContext: UIContext): FrameNode | null {
    const builderNode = new BuilderNode<[]>(uiContext, {
      selfIdealSize: {
        width: this.width,
        height: this.height
      },
      type: NodeRenderType.RENDER_TYPE_TEXTURE
    })
    builderNode.build(wrapBuilder(PipClockBuilder))
    this.builderNode = builderNode
    return builderNode.getFrameNode()
  }

  update(isLandscape: boolean) {
    const size = getPipClockSize(isLandscape)
    this.width = size.width
    this.height = size.height
    this.rebuild()
  }

  refresh() {
    this.rebuild()
  }
}

@Entry
@Component
struct Index {
  // 当设备横屏时条件成立
  listener: mediaQuery.MediaQueryListener = mediaQuery.matchMediaSync('(orientation: landscape)');
  @Watch('onColorModeChange') @StorageLink('currentColorMode') currentMode: number =
    ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  @State isDark: boolean = false // 是否暗黑模式
  @State isLandscape: boolean = false // 当前是否横屏
  @Watch('onCleanChange') @State isClean: boolean = false // 清屏
  @State isPresentSetting: boolean = false
  @State selectedTabIndex: number = 0
  @Watch('onConfigChange') @StorageLink('defaultClockConfig') clockConfig: ClockConfig = CLOCK_CONFIGS[0]
  @Watch('onConfigChange') @StorageLink('globalClockConfig') globalConfig: GlobalClockConfig = DEFAULT_GLOBAL_CONFIG
  private date: Date = new Date()
  private clockController: ClockController = new ClockController()
  private pipXComponentController: XComponentController = new XComponentController()
  private pipUiController: ClockPipNodeController = new ClockPipNodeController(false)
  private pipController: PiPWindow.PiPController | null = null
  private pipIsLandscape: boolean = false
  private intervalId: number = 0;
  private cleanTimeoutId: number = 0;
  private clockStyleDialog: CustomDialogController = new CustomDialogController({
    builder: ClockStyleDialog({
      selectedConfig: this.clockConfig,
      onSelected: (config) => {
        this.clockConfig = config
      }
    }),
    customStyle: true,
    maskColor: Color.Transparent,
    openAnimation: {
      duration: 0
    },
    closeAnimation: {
      duration: 0
    },
  })
  goStoreDialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      message: '开发不易，去给开发者一个好评以资鼓励吧',
      cancelText: '以后再说',
      confirmText: '马上去',
      confirm: () => {
        AppInfo.goStore()

        let options: dataPreferences.Options = { name: AppConstants.BUNDLE_NAME };
        let preferences = dataPreferences.getPreferencesSync(getContext(), options);

        // 记录去评分事件
        preferences.putSync('goStoreGuideConfirm', true)
        preferences.flush()
      },
      cancel: () => {
        let options: dataPreferences.Options = { name: AppConstants.BUNDLE_NAME };
        let preferences = dataPreferences.getPreferencesSync(getContext(), options);

        // 记录取消评分事件时间
        preferences.putSync('goStoreGuideCancelTime', new Date().getTime())
        preferences.flush()
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Bottom,
    offset: {
      dx: 0,
      dy: -12
    },
    customStyle: false
  })

  aboutToAppear(): void {
    this.isLandscape = this.listener.matches as boolean
    AppStorage.setOrCreate('isLandscape', this.isLandscape)
    // 绑定横竖屏切换回调函数
    this.listener.on('change', (mediaQueryResult: mediaQuery.MediaQueryResult) => {
      console.log(`mediaQueryResult: ${mediaQueryResult.matches as boolean}`)
      this.isLandscape = mediaQueryResult.matches as boolean
      AppStorage.setOrCreate('isLandscape', this.isLandscape)
      this.syncPictureInPictureOrientation()
    })
    this.isDark = this.currentMode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK

    this.updateTimes()
    this.onConfigChange()
    this.onCleanChange()
  }

  aboutToDisappear(): void {
    clearInterval(this.intervalId)
    clearTimeout(this.cleanTimeoutId)
  }

  onPageShow(): void {
    this.onCleanChange()
    this.checkNeedTipsGoStore()
  }

  onPageHide(): void {
    clearTimeout(this.cleanTimeoutId)
  }

  pageTransition() {
    PageTransitionEnter({ duration: 0 })
    PageTransitionExit({ duration: 1000 })
  }

  checkNeedTipsGoStore() {
    let options: dataPreferences.Options = { name: AppConstants.BUNDLE_NAME };
    let preferences = dataPreferences.getPreferencesSync(getContext(), options);

    const installTimestamps = preferences.getSync('installTimestamps', 0) as number
    if (installTimestamps === 0) {
      preferences.putSync('installTimestamps', new Date().getTime())
      preferences.flush()
      return
    }

    const goStoreGuide = preferences.getSync('goStoreGuide', false) as boolean
    if (goStoreGuide) {
      return
    }

    const now = new Date().getTime()
    if (now - installTimestamps > 3600 * 24 * 3 * 1000) {
      this.goStoreDialogController.open()

      preferences.putSync('goStoreGuide', true)
      preferences.flush()
    }
  }

  onCleanChange() {
    // if (this.cleanTimeoutId != 0) {
    //   clearTimeout(this.cleanTimeoutId)
    // }
    // if (!this.isClean) {
    //   this.cleanTimeoutId = setTimeout(() => {
    //     this.isClean = true
    //   }, 8000)
    // }
  }

  checkUpdate() {
    if (PrivacyManage.isAgree()) {
      UpdateManager.checkUpdate()
    }
  }

  onColorModeChange(): void {
    this.isDark = this.currentMode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK
    if (this.pipController) {
      this.pipUiController.refresh()
    }
    const preferences = dataPreferences.getPreferencesSync(getContext(), { name: AppConstants.BUNDLE_NAME })
    preferences.putSync('defaultColorMode', this.currentMode)
    preferences.flush()
  }

  onConfigChange() {
    clearInterval(this.intervalId)
    if ((this.globalConfig.showMilliseconds && this.clockConfig.type == ClockType.NormalDigital) ||
      (this.clockConfig.type == ClockType.Round &&
        (this.clockConfig.style == ClockStyle.Style2 || this.clockConfig.style == ClockStyle.Style3 ||
          this.clockConfig.style == ClockStyle.Style4 || this.clockConfig.style == ClockStyle.Style5 ||
          this.clockConfig.style == ClockStyle.Style6 || this.clockConfig.style == ClockStyle.Style7)) ||
      this.clockConfig.type == ClockType.Mechanical) {
      this.startClock(20)
    } else {
      this.startClock(1000)
    }
    if (this.globalConfig.autoRotation) {
      this.changeOrientation(window.Orientation.AUTO_ROTATION)
    } else {
      this.changeOrientation(this.isLandscape ? window.Orientation.LANDSCAPE : window.Orientation.PORTRAIT)
    }
    if (this.globalConfig.themeMode === ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET) {
      const preferences = dataPreferences.getPreferencesSync(getContext(), { name: AppConstants.BUNDLE_NAME })
      preferences.deleteSync('defaultColorMode')
      preferences.flush()
    }
  }

  // 改变设备横竖屏状态函数
  changeOrientation(orientation: window.Orientation) {
    // 获取UIAbility实例的上下文信息
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    // 调用该接口手动改变设备横竖屏状态
    window.getLastWindow(context).then((lastWindow) => {
      lastWindow.setPreferredOrientation(orientation)
    });
  }

  startClock(interval: number) {
    this.intervalId = setInterval(() => {
      this.updateTimes()
    }, interval);
  }

  updateTimes() {
    this.date = new Date()
    this.clockController.update(this.date)
  }

  private getPipContentWidth(): number {
    return getPipClockSize(this.isLandscape).width
  }

  private getPipContentHeight(): number {
    return getPipClockSize(this.isLandscape).height
  }

  private async syncPictureInPictureOrientation() {
    if (!this.pipController || this.pipIsLandscape == this.isLandscape) {
      return
    }
    this.pipIsLandscape = this.isLandscape
    this.pipUiController.update(this.isLandscape)
    try {
      this.pipController.updateContentSize(this.getPipContentWidth(), this.getPipContentHeight())
    } catch (error) {
      const err = error as BusinessError
      console.warn(`Failed to update PiP content size. Code=${err.code}, message=${err.message}`)
    }
  }

  async startPictureInPicture() {
    try {
      if (!PiPWindow.isPiPEnabled()) {
        console.warn('Picture-in-picture is not enabled on this device.')
        return
      }

      const width = this.getPipContentWidth()
      const height = this.getPipContentHeight()
      if (this.pipController && this.pipIsLandscape != this.isLandscape) {
        await this.syncPictureInPictureOrientation()
        return
      }

      if (!this.pipController) {
        const context = getContext(this) as common.UIAbilityContext
        this.pipIsLandscape = this.isLandscape
        this.pipUiController = new ClockPipNodeController(this.isLandscape)
        this.pipController = await PiPWindow.create({
          context,
          componentController: this.pipXComponentController,
          templateType: PiPWindow.PiPTemplateType.VIDEO_LIVE,
          contentWidth: width,
          contentHeight: height,
          controlGroups: [],
          customUIController: this.pipUiController,
          defaultWindowSizeType: 1,
          cornerAdsorptionEnabled: true
        })
        this.pipController.on('stateChange', (state: PiPWindow.PiPState, reason: string) => {
          console.info(`PiP state changed. state=${state}, reason=${reason}`)
        })
        this.pipController.on('controlPanelActionEvent', (event: PiPWindow.PiPActionEventType, status?: number) => {
          console.info(`PiP control event. event=${event}, status=${status}`)
        })
      }

      this.pipController.setAutoStartEnabled(true)
      await this.pipController.startPiP()
    } catch (error) {
      const err = error as BusinessError
      console.error(`Failed to start picture-in-picture. Code=${err.code}, message=${err.message}`)
    }
  }

  build() {
    RelativeContainer() {
      Column() {
        this.ClockView()
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.clockConfig.colors.backgroundColor)
      .alignRules({
        top: { anchor: "__container__", align: VerticalAlign.Top },
        left: { anchor: "__container__", align: HorizontalAlign.Start },
        right: { anchor: "__container__", align: HorizontalAlign.End },
        bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
      })
      .id("clock")

      this.TopTools()
      this.BottomTools()
      this.PipSource()
    }
    .height('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      this.isClean = !this.isClean
    })
    .onAppear(() => {
      this.checkUpdate()
    })
  }

  @Builder
  PipSource() {
    XComponent({
      id: 'flipClockPipSource',
      type: XComponentType.SURFACE,
      controller: this.pipXComponentController
    })
      .width(this.getPipContentWidth())
      .height(this.getPipContentHeight())
      .opacity(0.01)
      .hitTestBehavior(HitTestMode.None)
      .zIndex(-1)
      .alignRules({
        top: { anchor: "__container__", align: VerticalAlign.Top },
        left: { anchor: "__container__", align: HorizontalAlign.Start }
      })
  }

  @Builder
  ClockView() {
    if (this.clockConfig.type == ClockType.Flip) {
      FlipClock({
        controller: this.clockController,
        date: this.date,
        colorsConfig: this.clockConfig.colors,
        globalConfig: this.globalConfig,
        isLandscape: this.isLandscape
      })
    } else if (this.clockConfig.type == ClockType.Round) {
      RoundClock({
        controller: this.clockController,
        date: this.date,
        style: this.clockConfig.style
      })
    } else if (this.clockConfig.type == ClockType.Digital) {
      DigitalClock({
        controller: this.clockController,
        date: this.date,
        colorsConfig: this.clockConfig.colors,
        globalConfig: this.globalConfig,
      })
    } else if (this.clockConfig.type == ClockType.Rotate) {
      RotateClock({
        controller: this.clockController,
        date: this.date,
        style: this.clockConfig.style,
        colorsConfig: this.clockConfig.colors,
        globalConfig: this.globalConfig,
        lightOn: this.clockConfig.ext?.lightOn,
        isLandscape: this.isLandscape,
      })
    } else if (this.clockConfig.type == ClockType.LunarCalendar) {
      LunarCalendarClock({
        controller: this.clockController,
        date: this.date,
        style: this.clockConfig.style,
        colorsConfig: this.clockConfig.colors,
        globalConfig: this.globalConfig,
        isLandscape: this.isLandscape,
      })
    } else if (this.clockConfig.type == ClockType.NormalDigital) {
      NormalDigitalClock({
        controller: this.clockController,
        date: this.date,
        colorsConfig: this.clockConfig.colors,
        globalConfig: this.globalConfig,
        isLandscape: this.isLandscape,
      })
    } else if (this.clockConfig.type == ClockType.Stereoscopic) {
      StereoscopicClock({
        controller: this.clockController,
        date: this.date,
        colorsConfig: this.clockConfig.colors,
        globalConfig: this.globalConfig,
        isLandscape: this.isLandscape,
      })
    } else if (this.clockConfig.type == ClockType.Poster) {
      PosterClock({
        controller: this.clockController,
        date: this.date,
        style: this.clockConfig.style,
        colorsConfig: this.clockConfig.colors,
        globalConfig: this.globalConfig,
        isLandscape: this.isLandscape,
      })
    } else if (this.clockConfig.type == ClockType.Mechanical) {
      MechanicalClock({
        controller: this.clockController,
        date: this.date,
        isLandscape: this.isLandscape
      })
    }
  }

  @Builder
  TopTools() {
    Row({ space: 12 }) {
      ToolItem({
        iconName: this.isDark ? Icons.THEME_LIGHT : Icons.THEME_DARK,
        fontSize: this.isDark ? 24 : 28
      })
        .onClick(() => {
          let mode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK
          if (this.isDark) {
            mode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
          }
          this.globalConfig.themeMode = mode
          getContext().getApplicationContext().setColorMode(mode);
        })
      ToolItem({
        iconName: Icons.MINI_WINDOW,
        fontSize: 24
      })
        .onClick(() => {
          this.startPictureInPicture()
        })

      if (DEBUG) {
        Row() {
          Text(this.clockConfig.id)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.tool_item_color'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Center)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor($r('app.color.tool_item_bg_color'))
            .borderRadius(16)
        }
          .justifyContent(FlexAlign.Center)
          .layoutWeight(1)
      } else {
        Blank()
          .layoutWeight(1)
      }

      ToolItem({
        iconName: Icons.SETTINGS,
        fontSize: 24
      })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/Settings/SettingPage'
          })
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .visibility(this.isClean ? Visibility.Hidden : Visibility.Visible)
    .alignRules({
      top: { anchor: "__container__", align: VerticalAlign.Top },
      left: { anchor: "__container__", align: HorizontalAlign.Start }
    })
    .offset({
      y: AppConstants.DEFAULT_STATUS_HEIGHT
    })
    .padding({ left: 24, right: 24 })
    .id('previews')
  }

  @Builder
  BottomTools() {
    Row({ space: 24 }) {
      ToolItem({
        iconName: Icons.SCREEN_ORIENTATION,
        fontSize: 20
      })
        .onClick(() => {
          this.globalConfig.autoRotation = false
          this.changeOrientation(!this.isLandscape ? window.Orientation.LANDSCAPE : window.Orientation.PORTRAIT)
        })

      Blank()
        .layoutWeight(1)

      ToolItem({
        iconName: Icons.THEME_FILL_ICON,
        fontSize: 24
      })
        .onClick(() => {
          this.clockStyleDialog.open()
        })
    }
    .padding({ left: 24, right: 24, bottom: 36 })
    .visibility(this.isClean ? Visibility.Hidden : Visibility.Visible)
    .backgroundColor(Color.Transparent)
    .alignRules({
      left: { anchor: "__container__", align: HorizontalAlign.Start },
      right: { anchor: "__container__", align: HorizontalAlign.End },
      bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
    })
    .id("tools")
  }
}

@Component
struct ClockPipView {
  @Watch('onClockConfigChange') @StorageLink('defaultClockConfig') clockConfig: ClockConfig = CLOCK_CONFIGS[0]
  @StorageLink('globalClockConfig') globalConfig: GlobalClockConfig = DEFAULT_GLOBAL_CONFIG
  @StorageLink('isLandscape') isLandscape: boolean = false
  @StorageLink('currentColorMode') currentMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
  @State now: Date = new Date()
  private clockController: ClockController = new ClockController()
  private hourController: FlipCardController = new FlipCardController()
  private minuteController: FlipCardController = new FlipCardController()
  private secondController: FlipCardController = new FlipCardController()
  private intervalId: number = 0

  aboutToAppear(): void {
    this.updateTime()
    this.onClockConfigChange()
  }

  aboutToDisappear(): void {
    clearInterval(this.intervalId)
  }

  onClockConfigChange() {
    clearInterval(this.intervalId)
    const interval = this.clockConfig.type == ClockType.Round &&
      (this.clockConfig.style == ClockStyle.Style2 || this.clockConfig.style == ClockStyle.Style3 ||
        this.clockConfig.style == ClockStyle.Style4 || this.clockConfig.style == ClockStyle.Style5 ||
        this.clockConfig.style == ClockStyle.Style6 || this.clockConfig.style == ClockStyle.Style7) ? 20 : 1000
    this.intervalId = setInterval(() => {
      this.updateTime()
    }, interval)
    this.updateTime()
  }

  updateTime() {
    this.now = new Date()
    this.clockController.update(this.now)

    const hours = this.globalConfig.use24HourFormat ? this.now.getHours() : this.get12Hour(this.now)
    this.hourController.change(hours.toString().padStart(2, '0'))
    this.minuteController.change(this.now.getMinutes().toString().padStart(2, '0'))
    this.secondController.change(this.now.getSeconds().toString().padStart(2, '0'))
  }

  get12Hour(date: Date): number {
    const hours = date.getHours() % 12
    return hours === 0 ? 12 : hours
  }

  getHourText(): string {
    const hours = this.globalConfig.use24HourFormat ? this.now.getHours() : this.get12Hour(this.now)
    return hours.toString().padStart(2, '0')
  }

  getPipWidth(): number {
    return getPipClockSize(this.isLandscape).width
  }

  getPipHeight(): number {
    return getPipClockSize(this.isLandscape).height
  }

  getPreviewScale(): number {
    return Math.min(this.getPipWidth() / this.getPreviewWidth(), this.getPipHeight() / this.getPreviewHeight()) *
    PIP_CLOCK_CONTENT_FIT_SCALE
  }

  getPreviewWidth(): number {
    return this.isLandscape ? PIP_CLOCK_PREVIEW_LANDSCAPE_WIDTH : PIP_CLOCK_PREVIEW_PORTRAIT_WIDTH
  }

  getPreviewHeight(): number {
    return this.isLandscape ? PIP_CLOCK_PREVIEW_LANDSCAPE_HEIGHT : PIP_CLOCK_PREVIEW_PORTRAIT_HEIGHT
  }

  getPipBackgroundColor(): ResourceColor {
    if (this.clockConfig.id == 'poster_clock_plex_minimal') {
      return '#000000'
    }
    return this.clockConfig.colors.backgroundColor
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      this.PreviewClockFace()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getPipBackgroundColor())
    .borderRadius(28)
    .clip(true)
  }

  @Builder
  PipFlipClock() {
    if (this.isLandscape) {
      Row({ space: 10 }) {
        this.PipFlipCardItems()
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 10, right: 10, top: 12, bottom: 12 })
      .backgroundColor(this.clockConfig.colors.backgroundColor)
    } else {
      Column({ space: 8 }) {
        this.PipFlipCardItems()
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .padding({ left: 12, right: 12, top: 14, bottom: 14 })
      .backgroundColor(this.clockConfig.colors.backgroundColor)
    }
  }

  @Builder
  PipFlipCardItems() {
    FlipCard({
      fontSize: this.isLandscape ? 44 : 48,
      fontColor: this.clockConfig.colors.fontColor,
      color: this.clockConfig.colors.cardColor,
      shadowColor: Color.Transparent,
      space: 2,
      current: this.getHourText(),
      controller: this.hourController
    })

    FlipCard({
      fontSize: this.isLandscape ? 44 : 48,
      fontColor: this.clockConfig.colors.fontColor,
      color: this.clockConfig.colors.cardColor,
      shadowColor: Color.Transparent,
      space: 2,
      current: this.now.getMinutes().toString().padStart(2, '0'),
      controller: this.minuteController
    })

    FlipCard({
      fontSize: this.isLandscape ? 44 : 48,
      fontColor: this.clockConfig.colors.fontColor,
      color: this.clockConfig.colors.cardColor,
      shadowColor: Color.Transparent,
      space: 2,
      current: this.now.getSeconds().toString().padStart(2, '0'),
      controller: this.secondController
    })
  }

  @Builder
  PreviewClockFace() {
    ClockPreviewCanvas({
      controller: this.clockController,
      clockConfig: this.clockConfig,
      date: this.now,
      globalConfig: this.globalConfig,
      isLandscape: this.isLandscape,
      canvasWidth: this.getPreviewWidth(),
      canvasHeight: this.getPreviewHeight()
    })
    .width(this.getPreviewWidth())
    .height(this.getPreviewHeight())
    .backgroundColor(Color.Transparent)
    .scale({
      x: this.getPreviewScale(),
      y: this.getPreviewScale(),
      centerX: '50%',
      centerY: '50%'
    })
  }

  @Builder
  CurrentClockFace() {
    Column() {
      if (this.clockConfig.type == ClockType.Round) {
        RoundClock({
          controller: this.clockController,
          date: this.now,
          style: this.clockConfig.style
        })
      } else if (this.clockConfig.type == ClockType.Digital) {
        DigitalClock({
          controller: this.clockController,
          date: this.now,
          colorsConfig: this.clockConfig.colors,
          globalConfig: this.globalConfig,
        })
      } else if (this.clockConfig.type == ClockType.Rotate) {
        RotateClock({
          controller: this.clockController,
          date: this.now,
          style: this.clockConfig.style,
          colorsConfig: this.clockConfig.colors,
          globalConfig: this.globalConfig,
          lightOn: this.clockConfig.ext?.lightOn,
          isLandscape: this.isLandscape,
        })
      } else if (this.clockConfig.type == ClockType.LunarCalendar) {
        LunarCalendarClock({
          controller: this.clockController,
          date: this.now,
          style: this.clockConfig.style,
          colorsConfig: this.clockConfig.colors,
          globalConfig: this.globalConfig,
          isLandscape: this.isLandscape,
        })
      } else if (this.clockConfig.type == ClockType.NormalDigital) {
        NormalDigitalClock({
          controller: this.clockController,
          date: this.now,
          colorsConfig: this.clockConfig.colors,
          globalConfig: this.globalConfig,
          isLandscape: this.isLandscape,
        })
      } else if (this.clockConfig.type == ClockType.Stereoscopic) {
        StereoscopicClock({
          controller: this.clockController,
          date: this.now,
          colorsConfig: this.clockConfig.colors,
          globalConfig: this.globalConfig,
          isLandscape: this.isLandscape,
        })
      } else if (this.clockConfig.type == ClockType.Poster) {
        PosterClock({
          controller: this.clockController,
          date: this.now,
          style: this.clockConfig.style,
          colorsConfig: this.clockConfig.colors,
          globalConfig: this.globalConfig,
          isLandscape: this.isLandscape,
        })
      } else if (this.clockConfig.type == ClockType.Mechanical) {
        MechanicalClock({
          controller: this.clockController,
          date: this.now,
          isLandscape: this.isLandscape
        })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .scale({
      x: this.isLandscape ? 0.48 : 0.54,
      y: this.isLandscape ? 0.48 : 0.54,
      centerX: '50%',
      centerY: '50%'
    })
  }
}

@Component
struct ToolItem {
  @Prop iconName: string = Icons.SETTINGS
  @Prop fontSize: number = 20

  build() {
    Button() {
      Icon({
        name: this.iconName,
        iconSize: this.fontSize,
        color: $r('app.color.tool_item_color')
      })
    }
    .backgroundColor($r('app.color.tool_item_bg_color'))
    .width(44)
    .height(44)
    .borderRadius(22)
  }
}
