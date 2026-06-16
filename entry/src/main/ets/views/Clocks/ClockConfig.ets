import { ClockController } from './ClockController'

export enum ClockType {
  Flip,          // 小布丁时钟
  Round,         // 圆形时钟
  Digital,       // 数码时钟
  Rotate,        // 旋转时钟
  LunarCalendar, // 农历数字时钟
  NormalDigital, // 普通数字时钟
  Stereoscopic,  // 立体感时钟
  Poster,        // 整屏主题时钟
  Mechanical,    // 机械指针时钟
}

export enum ClockStyle {
  Style1,
  Style2,
  Style3,
  Style4,
  Style5,
  Style6,
  Style7,
  Style8,
  Style9,
  Style10,
  Style11,
  Style12,
  Style13,
  Style14,
  Style15,
}

export enum ClockColorSetting {
  Background,
  FontColor,
  CardColor,
  ShadowColor
}

export interface ClockColorsConfig {
  backgroundColor: ResourceColor,
  fontColor: ResourceColor,
  cardColor?: ResourceColor,
  shadowColor?: ResourceColor
}

export interface ClockConfigExt {
  lightOn: boolean
}

export interface ClockConfig {
  id: string,
  type: ClockType,
  style: ClockStyle,
  colors: ClockColorsConfig,
  ext?: ClockConfigExt
}

export interface ClockThemeGroup {
  title: string
  ids: string[]
}

export interface ClockThemeGroupItems {
  title: string
  items: ClockConfig[]
}

export interface GlobalClockConfig {
  autoRotation: boolean,      // 跟随系统切换横竖屏
  themeMode: number,          // 主题
  use24HourFormat: boolean,   // 24小时制
  showAMPM: boolean,          // 显示AM/PM
  showDate: boolean,          // 显示日期
  showLunarCalendar: boolean, // 显示农历
  showWeek: boolean,          // 显示星期
  showMilliseconds: boolean   // 显示毫秒
}

export const DEFAULT_GLOBAL_CONFIG: GlobalClockConfig = {
  autoRotation: true,
  themeMode: -1,
  use24HourFormat: true,
  showAMPM: true,
  showDate: true,
  showLunarCalendar: true,
  showWeek: true,
  showMilliseconds: false
}

export const CLOCK_CONFIGS: ClockConfig[] = [
  {
    id: 'flip_clock_style1',
    type: ClockType.Flip,
    style: ClockStyle.Style1,
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color'),
      shadowColor: $r('app.color.card_shadow_color')
    }
  },
  {
    id: 'round_clock_style1',
    type: ClockType.Round,
    style: ClockStyle.Style1,
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      fontColor: ''
    }
  },
  {
    id: 'round_clock_style2',
    type: ClockType.Round,
    style: ClockStyle.Style2,
    colors: {
      backgroundColor: '#061018',
      fontColor: ''
    }
  },
  {
    id: 'round_clock_style3',
    type: ClockType.Round,
    style: ClockStyle.Style3,
    colors: {
      backgroundColor: '#0d0f13',
      fontColor: ''
    }
  },
  {
    id: 'round_clock_style4',
    type: ClockType.Round,
    style: ClockStyle.Style4,
    colors: {
      backgroundColor: '#fff3fb',
      fontColor: ''
    }
  },
  {
    id: 'round_clock_style5',
    type: ClockType.Round,
    style: ClockStyle.Style5,
    colors: {
      backgroundColor: '#e8d6ae',
      fontColor: ''
    }
  },
  {
    id: 'round_clock_style6',
    type: ClockType.Round,
    style: ClockStyle.Style6,
    colors: {
      backgroundColor: '#092e2a',
      fontColor: ''
    }
  },
  {
    id: 'round_clock_style7',
    type: ClockType.Round,
    style: ClockStyle.Style7,
    colors: {
      backgroundColor: '#08121f',
      fontColor: ''
    }
  },
  {
    id: 'mechanical_clock_style1',
    type: ClockType.Mechanical,
    style: ClockStyle.Style1,
    colors: {
      backgroundColor: '#0d0f13',
      fontColor: ''
    }
  },
  {
    id: 'digital_clock_style1',
    type: ClockType.Digital,
    style: ClockStyle.Style1,
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      fontColor: $r('app.color.flip_text_color')
    }
  },
  {
    id: 'rotate_clock_style1',
    type: ClockType.Rotate,
    style: ClockStyle.Style1,
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color')
    }
  },
  {
    id: 'rotate_clock_style2',
    type: ClockType.Rotate,
    style: ClockStyle.Style2,
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color')
    }
  },
  {
    id: 'rotate_clock_style3',
    type: ClockType.Rotate,
    style: ClockStyle.Style3,
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color')
    }
  },
  {
    id: 'rotate_clock_style1_light',
    type: ClockType.Rotate,
    style: ClockStyle.Style1,
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color')
    },
    ext: {
      lightOn: true
    }
  },
  {
    id: 'rotate_clock_style2_light',
    type: ClockType.Rotate,
    style: ClockStyle.Style2,
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color')
    },
    ext: {
      lightOn: true
    }
  },
  {
    id: 'rotate_clock_style3_light',
    type: ClockType.Rotate,
    style: ClockStyle.Style3,
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color')
    },
    ext: {
      lightOn: true
    }
  },
  {
    id: 'lunar_calendar_clock_style1',
    type: ClockType.LunarCalendar,
    style: ClockStyle.Style1,
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      fontColor: $r('app.color.flip_text_color')
    }
  },
  {
    id: 'lunar_calendar_clock_style2',
    type: ClockType.LunarCalendar,
    style: ClockStyle.Style2,
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      fontColor: $r('app.color.flip_text_color')
    }
  },
  {
    id: 'normal_digital_clock_style1',
    type: ClockType.NormalDigital,
    style: ClockStyle.Style1,
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      fontColor: $r('app.color.flip_text_color')
    }
  },
  {
    id: 'stereoscopic_clock_style1',
    type: ClockType.Stereoscopic,
    style: ClockStyle.Style1,
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color'),
      shadowColor: $r('app.color.card_shadow_color')
    }
  },
  {
    id: 'poster_clock_cyberpunk',
    type: ClockType.Poster,
    style: ClockStyle.Style1,
    colors: {
      backgroundColor: '#050713',
      cardColor: '#101828',
      fontColor: '#ffffff'
    }
  },
  {
    id: 'poster_clock_retro_flip',
    type: ClockType.Poster,
    style: ClockStyle.Style2,
    colors: {
      backgroundColor: '#ff8200',
      cardColor: '#ff8200',
      fontColor: '#172026'
    }
  },
  {
    id: 'poster_clock_cute',
    type: ClockType.Poster,
    style: ClockStyle.Style3,
    colors: {
      backgroundColor: '#fff4dc',
      cardColor: '#fff8e8',
      fontColor: '#9f5752'
    }
  },
  {
    id: 'poster_clock_minimal',
    type: ClockType.Poster,
    style: ClockStyle.Style4,
    colors: {
      backgroundColor: '#061a2e',
      cardColor: '#123047',
      fontColor: '#e8ffff'
    }
  },
  {
    id: 'poster_clock_funny',
    type: ClockType.Poster,
    style: ClockStyle.Style5,
    colors: {
      backgroundColor: '#08111d',
      cardColor: '#111426',
      fontColor: '#ffffff'
    }
  },
  {
    id: 'poster_clock_office_snooze',
    type: ClockType.Poster,
    style: ClockStyle.Style12,
    colors: {
      backgroundColor: '#06152f',
      fontColor: '#ffffff'
    }
  },
  {
    id: 'poster_clock_office_monday',
    type: ClockType.Poster,
    style: ClockStyle.Style13,
    colors: {
      backgroundColor: '#06152f',
      fontColor: '#ffffff'
    }
  },
  {
    id: 'poster_clock_office_coffee',
    type: ClockType.Poster,
    style: ClockStyle.Style14,
    colors: {
      backgroundColor: '#06152f',
      fontColor: '#ffffff'
    }
  },
  {
    id: 'poster_clock_office_payday',
    type: ClockType.Poster,
    style: ClockStyle.Style15,
    colors: {
      backgroundColor: '#06152f',
      fontColor: '#ffffff'
    }
  },
  {
    id: 'poster_clock_orbitron_hud',
    type: ClockType.Poster,
    style: ClockStyle.Style6,
    colors: {
      backgroundColor: '#020815',
      cardColor: '#071d35',
      fontColor: '#74f7ff'
    }
  },
  {
    id: 'poster_clock_exo_dashboard',
    type: ClockType.Poster,
    style: ClockStyle.Style7,
    colors: {
      backgroundColor: '#08131d',
      cardColor: '#112636',
      fontColor: '#e6fbff'
    }
  },
  {
    id: 'poster_clock_audiowide_synthwave',
    type: ClockType.Poster,
    style: ClockStyle.Style8,
    colors: {
      backgroundColor: '#180625',
      cardColor: '#2b0d3e',
      fontColor: '#ff6be8'
    }
  },
  {
    id: 'poster_clock_dseg_led',
    type: ClockType.Poster,
    style: ClockStyle.Style9,
    colors: {
      backgroundColor: '#050807',
      cardColor: '#111a16',
      fontColor: '#5cff9d'
    }
  },
  {
    id: 'poster_clock_plex_minimal',
    type: ClockType.Poster,
    style: ClockStyle.Style10,
    colors: {
      backgroundColor: '#f5f5f2',
      cardColor: '#ffffff',
      fontColor: '#111111'
    }
  },
  {
    id: 'poster_clock_space_terminal',
    type: ClockType.Poster,
    style: ClockStyle.Style11,
    colors: {
      backgroundColor: '#050607',
      cardColor: '#101314',
      fontColor: '#d9ffdf'
    }
  },
]

export const CLOCK_THEME_GROUPS: ClockThemeGroup[] = [
  {
    title: '基础翻页',
    ids: [
      'rotate_clock_style1',
      'rotate_clock_style2',
      'rotate_clock_style3',
      'rotate_clock_style1_light',
      'rotate_clock_style2_light',
      'rotate_clock_style3_light'
    ]
  },
  {
    title: '基础数字',
    ids: [
      'normal_digital_clock_style1',
      'digital_clock_style1',
      'flip_clock_style1',
      'stereoscopic_clock_style1'
    ]
  },
  {
    title: '日历时光',
    ids: [
      'lunar_calendar_clock_style1',
      'lunar_calendar_clock_style2'
    ]
  },
  {
    title: '可爱趣味',
    ids: [
      'poster_clock_cute',
      'poster_clock_funny',
      'poster_clock_office_snooze',
      'poster_clock_office_monday',
      'poster_clock_office_coffee',
      'poster_clock_office_payday'
    ]
  },
  {
    title: '圆形指针',
    ids: [
      'round_clock_style1',
      'round_clock_style2',
      'round_clock_style3',
      'round_clock_style4',
      'round_clock_style5',
      'round_clock_style6',
      'round_clock_style7',
      'mechanical_clock_style1'
    ]
  },
  {
    title: '海报 HUD',
    ids: [
      'poster_clock_cyberpunk',
      'poster_clock_minimal',
      'poster_clock_orbitron_hud',
      'poster_clock_exo_dashboard'
    ]
  },
  {
    title: '海报复古',
    ids: [
      'poster_clock_retro_flip',
      'poster_clock_dseg_led',
      'poster_clock_space_terminal',
      'poster_clock_audiowide_synthwave',
      'poster_clock_plex_minimal'
    ]
  }
]

export function getClockConfigById(id: string): ClockConfig | undefined {
  return CLOCK_CONFIGS.find((item: ClockConfig) => item.id == id)
}

export function getClockConfigsByIds(ids: string[]): ClockConfig[] {
  const configs: ClockConfig[] = []
  ids.forEach((id: string) => {
    const config = getClockConfigById(id)
    if (config != undefined) {
      configs.push(config)
    }
  })
  return configs
}

export function getClockThemeGroupItems(): ClockThemeGroupItems[] {
  return CLOCK_THEME_GROUPS.map((group: ClockThemeGroup): ClockThemeGroupItems => {
    return {
      title: group.title,
      items: getClockConfigsByIds(group.ids)
    }
  })
}

export function getOrderedClockConfigs(): ClockConfig[] {
  const configs: ClockConfig[] = []
  CLOCK_THEME_GROUPS.forEach((group: ClockThemeGroup) => {
    configs.push(...getClockConfigsByIds(group.ids))
  })
  CLOCK_CONFIGS.forEach((config: ClockConfig) => {
    if (configs.find((item: ClockConfig) => item.id == config.id) == undefined) {
      configs.push(config)
    }
  })
  return configs
}

export function getClockColorSettings(config: ClockConfig): ClockColorSetting[] {
  if (config.type == ClockType.Flip || config.type == ClockType.Stereoscopic) {
    return [
      ClockColorSetting.Background,
      ClockColorSetting.FontColor,
      ClockColorSetting.CardColor,
      ClockColorSetting.ShadowColor
    ]
  }

  if (config.type == ClockType.Rotate) {
    return [
      ClockColorSetting.Background,
      ClockColorSetting.FontColor,
      ClockColorSetting.CardColor
    ]
  }

  if (config.type == ClockType.Digital || config.type == ClockType.NormalDigital ||
    config.type == ClockType.LunarCalendar) {
    return [
      ClockColorSetting.Background,
      ClockColorSetting.FontColor
    ]
  }

  if (config.type == ClockType.Round || config.type == ClockType.Mechanical) {
    return [ClockColorSetting.Background]
  }

  if (config.type == ClockType.Poster &&
    (config.id == 'poster_clock_office_snooze' || config.id == 'poster_clock_office_monday' ||
      config.id == 'poster_clock_office_coffee' || config.id == 'poster_clock_office_payday')) {
    return [
      ClockColorSetting.Background,
      ClockColorSetting.FontColor
    ]
  }

  return []
}

export function supportsClockColorSetting(config: ClockConfig, setting: ClockColorSetting): boolean {
  return getClockColorSettings(config).indexOf(setting) >= 0
}
