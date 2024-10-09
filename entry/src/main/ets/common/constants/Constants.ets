export class AppConstants {
  static DEFAULT_STATUS_HEIGHT: number = 0;
  static DEFAULT_NAV_HEIGHT: number = 0;
  static readonly BUNDLE_NAME: string = 'com.hyx.clock'
}

export class Icons {
  static readonly FONT_FAMILY: string = AppConstants.BUNDLE_NAME + 'iconfont'
  static readonly FAMILY_SRC: ResourceStr = $rawfile('com.hyx.clock.iconfont.ttf')

  static readonly FLIP_NUM_FONT_FAMILY: string = AppConstants.BUNDLE_NAME + 'flip-num-font'
  static readonly DIGITAL_NUM_FONT_FAMILY: string = AppConstants.BUNDLE_NAME + 'digital-num-font'
  static readonly DIGITAL_NUM1_FONT_FAMILY: string = AppConstants.BUNDLE_NAME + 'digital-num-font1'

  static readonly FLIP_NUM_FONT_FAMILY_SRC: ResourceStr = $rawfile('flip-num-font.ttf')
  static readonly DIGITAL_NUM_FONT_FAMILY_SRC: ResourceStr = $rawfile('digital-num-font.ttf')
  static readonly DIGITAL_NUM1_FONT_FAMILY_SRC: ResourceStr = $rawfile('digital-num-font1.ttf')

  static readonly SETTINGS: string = '\ue785'
  static readonly THEME_DARK: string = '\ue634'
  static readonly THEME_LIGHT: string = '\ue600'
  static readonly ARROW_RIGHT: string = '\ue63c'
  static readonly EMAIL: string = '\ue68a'
  static readonly FEEDBACK: string = '\ue6fa'
  static readonly PRIVACY: string = '\ue612'
  static readonly PACK_UP: string = '\ue64d'
  static readonly TIPS: string = '\ue7a3'
  static readonly COMMENTS: string = '\ue8b9'
  static readonly CUSTOM: string = '\ue62f'
  static readonly ABOUT: string = '\ue607'
  static readonly CLOCK: string = '\ue74f'
  static readonly FLIP: string = '\ue69d'
  static readonly SCREEN_ORIENTATION: string = '\ue624'
  static readonly THEME_STROKE_ICON: string = '\ue65e'
  static readonly THEME_FILL_ICON: string = '\ue860'
  static readonly CHECKED: string = '\ue61d'
  static readonly BACK: string = '\ue62e'
  static readonly MINI_WINDOW: string = '\ue621'
}