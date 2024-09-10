import { ClockController } from './ClockController'

export enum ClockType {
  Flip,          // 小布丁时钟
  Round,         // 圆形时钟
  Digital,       // 数码时钟
  Rotate,        // 旋转时钟
  LunarCalendar, // 农历数字时钟
  NormalDigital  // 普通数字时钟
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
  cardColor: ResourceColor,
  fontColor: ResourceColor
}

export interface ClockConfigExt {
  lightOn: boolean
}

export interface ClockConfig {
  id: string,
  type: ClockType,
  style: ClockStyle,
  preview: Resource,
  colors: ClockColorsConfig,
  ext: ClockConfigExt
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
    preview: $r('app.media.flip_clock_style1'),
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color')
    },
    ext: {
      lightOn: false
    }
  },
  {
    id: 'round_clock_style1',
    type: ClockType.Round,
    style: ClockStyle.Style1,
    preview: $r('app.media.round_clock_style1'),
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: '',
      fontColor: ''
    },
    ext: {
      lightOn: false
    }
  },
  {
    id: 'digital_clock_style1',
    type: ClockType.Digital,
    style: ClockStyle.Style1,
    preview: $r('app.media.digital_clock_style1'),
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: '',
      fontColor: $r('app.color.flip_text_color')
    },
    ext: {
      lightOn: false
    }
  },
  {
    id: 'rotate_clock_style1',
    type: ClockType.Rotate,
    style: ClockStyle.Style1,
    preview: $r('app.media.rotate_clock_style1'),
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color')
    },
    ext: {
      lightOn: false
    }
  },
  {
    id: 'rotate_clock_style2',
    type: ClockType.Rotate,
    style: ClockStyle.Style2,
    preview: $r('app.media.rotate_clock_style2'),
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color')
    },
    ext: {
      lightOn: false
    }
  },
  {
    id: 'rotate_clock_style3',
    type: ClockType.Rotate,
    style: ClockStyle.Style3,
    preview:$r('app.media.rotate_clock_style3'),
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color')
    },
    ext: {
      lightOn: false
    }
  },
  {
    id: 'rotate_clock_style1_light',
    type: ClockType.Rotate,
    style: ClockStyle.Style1,
    preview: $r('app.media.rotate_clock_style1_light'),
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
    preview: $r('app.media.rotate_clock_style2_light'),
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
    preview:$r('app.media.rotate_clock_style3_light'),
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
    preview: $r('app.media.lunar_calendar_clock_style1'),
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: '',
      fontColor: $r('app.color.flip_text_color')
    },
    ext: {
      lightOn: false
    }
  },
  {
    id: 'lunar_calendar_clock_style2',
    type: ClockType.LunarCalendar,
    style: ClockStyle.Style2,
    preview: $r('app.media.lunar_calendar_clock_style2'),
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: '',
      fontColor: $r('app.color.flip_text_color')
    },
    ext: {
      lightOn: false
    }
  },
  {
    id: 'normal_digital_clock_style1',
    type: ClockType.NormalDigital,
    style: ClockStyle.Style1,
    preview: $r('app.media.normal_digital_clock_style1'),
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: '',
      fontColor: $r('app.color.flip_text_color')
    },
    ext: {
      lightOn: false
    }
  }
]