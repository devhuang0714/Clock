export enum ClockWidgetSize {
  Size2x2,
  Size2x4,
  Size4x4
}

export enum ClockWidgetStyleType {
  Minimal,
  Flip,
  Digital,
  Round,
  Lunar
}

export enum ClockWidgetRoundStyle {
  Classic,
  Cool,
  Cyberpunk,
  Cute,
  Retro,
  ArtDeco,
  DeepBlue
}

export interface ClockWidgetColors {
  backgroundColor: ResourceColor
  fontColor: ResourceColor
  cardColor?: ResourceColor
  mutedColor?: ResourceColor
  accentColor?: ResourceColor
}

export interface ClockWidgetConfig {
  id: string
  title: string
  subtitle: string
  type: ClockWidgetStyleType
  roundStyle?: ClockWidgetRoundStyle
  supportedSizes: ClockWidgetSize[]
  colors: ClockWidgetColors
}

export const DEFAULT_CLOCK_WIDGET_ID: string = 'widget_minimal'

export const CLOCK_WIDGET_SIZES: ClockWidgetSize[] = [
  ClockWidgetSize.Size2x2,
  ClockWidgetSize.Size2x4,
  ClockWidgetSize.Size4x4
]

export const CLOCK_WIDGET_CONFIGS: ClockWidgetConfig[] = [
  {
    id: 'widget_minimal',
    title: '极简数字',
    subtitle: '大号时间和日期',
    type: ClockWidgetStyleType.Minimal,
    supportedSizes: [
      ClockWidgetSize.Size2x2,
      ClockWidgetSize.Size2x4,
      ClockWidgetSize.Size4x4
    ],
    colors: {
      backgroundColor: '#F7F7F3',
      fontColor: '#111111',
      mutedColor: '#64645E',
      accentColor: '#111111'
    }
  },
  {
    id: 'widget_flip',
    title: '小布丁翻页',
    subtitle: '小时和分钟翻页卡片',
    type: ClockWidgetStyleType.Flip,
    supportedSizes: [
      ClockWidgetSize.Size2x4,
      ClockWidgetSize.Size4x4
    ],
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color'),
      mutedColor: '#767676',
      accentColor: '#09AFFF'
    }
  },
  {
    id: 'widget_digital',
    title: '电子数字',
    subtitle: '数字钟和状态信息',
    type: ClockWidgetStyleType.Digital,
    supportedSizes: [
      ClockWidgetSize.Size2x2,
      ClockWidgetSize.Size2x4,
      ClockWidgetSize.Size4x4
    ],
    colors: {
      backgroundColor: '#050807',
      cardColor: '#111A16',
      fontColor: '#5CFF9D',
      mutedColor: '#8BA596',
      accentColor: '#5CFF9D'
    }
  },
  {
    id: 'widget_round_classic',
    title: '经典时钟',
    subtitle: '经典白色圆盘',
    type: ClockWidgetStyleType.Round,
    roundStyle: ClockWidgetRoundStyle.Classic,
    supportedSizes: [
      ClockWidgetSize.Size2x2,
      ClockWidgetSize.Size2x4,
      ClockWidgetSize.Size4x4
    ],
    colors: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: '#FFFFFF',
      fontColor: '#111111',
      mutedColor: '#9A9A94',
      accentColor: '#D94D3D'
    }
  },
  {
    id: 'widget_round',
    title: '霓虹机械',
    subtitle: '蓝绿分层表盘',
    type: ClockWidgetStyleType.Round,
    roundStyle: ClockWidgetRoundStyle.Cool,
    supportedSizes: [
      ClockWidgetSize.Size2x2,
      ClockWidgetSize.Size2x4,
      ClockWidgetSize.Size4x4
    ],
    colors: {
      backgroundColor: '#061018',
      cardColor: '#061018',
      fontColor: '#D8FBFF',
      mutedColor: '#5B7C86',
      accentColor: '#8FF7FF'
    }
  },
  {
    id: 'widget_round_cyberpunk',
    title: '赛博霓虹',
    subtitle: '蓝紫双色刻度',
    type: ClockWidgetStyleType.Round,
    roundStyle: ClockWidgetRoundStyle.Cyberpunk,
    supportedSizes: [
      ClockWidgetSize.Size2x2,
      ClockWidgetSize.Size2x4,
      ClockWidgetSize.Size4x4
    ],
    colors: {
      backgroundColor: '#0D0F13',
      cardColor: '#0D0F13',
      fontColor: '#FDF4FF',
      mutedColor: '#6F4D8F',
      accentColor: '#FF2BD6'
    }
  },
  {
    id: 'widget_round_cute',
    title: '甜心圆盘',
    subtitle: '柔粉色点刻度',
    type: ClockWidgetStyleType.Round,
    roundStyle: ClockWidgetRoundStyle.Cute,
    supportedSizes: [
      ClockWidgetSize.Size2x2,
      ClockWidgetSize.Size2x4,
      ClockWidgetSize.Size4x4
    ],
    colors: {
      backgroundColor: '#FFF3FB',
      cardColor: '#FFF3FB',
      fontColor: '#6A4B73',
      mutedColor: '#B887A2',
      accentColor: '#FF8FC7'
    }
  },
  {
    id: 'widget_round_retro',
    title: '复古罗马',
    subtitle: '暖色罗马刻度',
    type: ClockWidgetStyleType.Round,
    roundStyle: ClockWidgetRoundStyle.Retro,
    supportedSizes: [
      ClockWidgetSize.Size2x2,
      ClockWidgetSize.Size2x4,
      ClockWidgetSize.Size4x4
    ],
    colors: {
      backgroundColor: '#E8D6AE',
      cardColor: '#E8D6AE',
      fontColor: '#4A2B16',
      mutedColor: '#9E7440',
      accentColor: '#C99742'
    }
  },
  {
    id: 'widget_round_deco',
    title: '金色装饰',
    subtitle: '深绿 Art Deco',
    type: ClockWidgetStyleType.Round,
    roundStyle: ClockWidgetRoundStyle.ArtDeco,
    supportedSizes: [
      ClockWidgetSize.Size2x2,
      ClockWidgetSize.Size2x4,
      ClockWidgetSize.Size4x4
    ],
    colors: {
      backgroundColor: '#092E2A',
      cardColor: '#092E2A',
      fontColor: '#F7DFA1',
      mutedColor: '#8D6B2F',
      accentColor: '#E5BD62'
    }
  },
  {
    id: 'widget_round_deepblue',
    title: '深蓝星盘',
    subtitle: '深蓝分层表盘',
    type: ClockWidgetStyleType.Round,
    roundStyle: ClockWidgetRoundStyle.DeepBlue,
    supportedSizes: [
      ClockWidgetSize.Size2x2,
      ClockWidgetSize.Size2x4,
      ClockWidgetSize.Size4x4
    ],
    colors: {
      backgroundColor: '#08121F',
      cardColor: '#08121F',
      fontColor: '#E8F4FF',
      mutedColor: '#7F99B6',
      accentColor: '#4DA3FF'
    }
  },
  {
    id: 'widget_lunar',
    title: '农历日期',
    subtitle: '时间、公历和农历',
    type: ClockWidgetStyleType.Lunar,
    supportedSizes: [
      ClockWidgetSize.Size2x4,
      ClockWidgetSize.Size4x4
    ],
    colors: {
      backgroundColor: '#FFF4DC',
      cardColor: '#FFF8E8',
      fontColor: '#9F5752',
      mutedColor: '#B48472',
      accentColor: '#FF7A59'
    }
  }
]

export function getClockWidgetConfig(widgetId: string): ClockWidgetConfig {
  const config = CLOCK_WIDGET_CONFIGS.find((item: ClockWidgetConfig) => item.id == widgetId)
  return config ?? CLOCK_WIDGET_CONFIGS[0]
}

export function isClockWidgetSizeSupported(config: ClockWidgetConfig, size: ClockWidgetSize): boolean {
  return config.supportedSizes.indexOf(size) >= 0
}

export function getClockWidgetConfigForSize(widgetId: string, size: ClockWidgetSize): ClockWidgetConfig {
  const selectedConfig = getClockWidgetConfig(widgetId)
  if (isClockWidgetSizeSupported(selectedConfig, size)) {
    return selectedConfig
  }

  const config = CLOCK_WIDGET_CONFIGS.find((item: ClockWidgetConfig) => isClockWidgetSizeSupported(item, size))
  return config ?? CLOCK_WIDGET_CONFIGS[0]
}

export function getClockWidgetSizeFromDimension(dimension: number): ClockWidgetSize {
  if (dimension == 3) {
    return ClockWidgetSize.Size2x4
  }
  if (dimension == 4) {
    return ClockWidgetSize.Size4x4
  }
  return ClockWidgetSize.Size2x2
}

export function getClockWidgetDimension(size: ClockWidgetSize): number {
  if (size == ClockWidgetSize.Size2x4) {
    return 3
  }
  if (size == ClockWidgetSize.Size4x4) {
    return 4
  }
  return 2
}

export function getClockWidgetSizeLabel(size: ClockWidgetSize): string {
  if (size == ClockWidgetSize.Size2x4) {
    return '2x4'
  }
  if (size == ClockWidgetSize.Size4x4) {
    return '4x4'
  }
  return '2x2'
}

export function getClockWidgetSizeFormValue(size: ClockWidgetSize): string {
  if (size == ClockWidgetSize.Size2x4) {
    return '2*4'
  }
  if (size == ClockWidgetSize.Size4x4) {
    return '4*4'
  }
  return '2*2'
}

export function getClockWidgetSizeAspectRatio(size: ClockWidgetSize): number {
  if (size == ClockWidgetSize.Size2x4) {
    return 2
  }
  return 1
}
