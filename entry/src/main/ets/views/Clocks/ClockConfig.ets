import { ClockController } from './ClockController'

export enum ClockType {
  Flip,          // 小布丁时钟
  Round,         // 圆形时钟
  Digital,       // 数码时钟
  Rotate,        // 旋转时钟
  LunarCalendar, // 农历数字时钟
  NormalDigital, // 普通数字时钟
  Stereoscopic,  // 立体感时钟
}

export enum ClockStyle {
  Style1,
  Style2,
  Style3,
  Style4,
  Style5,
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

export interface GlobalClockConfig {
  use24HourFormat: boolean,   // 24小时制
  showAMPM: boolean,          // 显示AM/PM
  showDate: boolean,          // 显示日期
  showLunarCalendar: boolean, // 显示农历
  showWeek: boolean,          // 显示星期
  showMilliseconds: boolean   // 显示毫秒
}

export const DEFAULT_GLOBAL_CONFIG: GlobalClockConfig = {
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
      fontColor: $r('app.color.flip_text_color')
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
]