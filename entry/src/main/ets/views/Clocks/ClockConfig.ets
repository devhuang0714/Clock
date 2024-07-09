
export interface ClockStyle {
  backgroundColor: ResourceColor,
  cardColor: ResourceColor,
  fontColor: ResourceColor
}

export interface ClockConfig {
  type: string,
  preview: Resource,
  style: ClockStyle
}

export const CLOCK_CONFIGS: ClockConfig[] = [
  {
    type: 'flip_clock_default',
    preview: $r('app.media.flip_clock_default'),
    style: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color')
    }
  },
  {
    type: 'round_clock_default',
    preview: $r('app.media.round_clock_default'),
    style: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: '',
      fontColor: ''
    }
  },
  {
    type: 'digital_clock_default',
    preview: $r('app.media.digital_clock_default'),
    style: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: '',
      fontColor: $r('app.color.flip_text_color')
    }
  },
  {
    type: 'rotate_clock_style1',
    preview: $r('app.media.rotate_clock_style1'),
    style: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color')
    }
  },
  {
    type: 'rotate_clock_style2',
    preview: $r('app.media.rotate_clock_style2'),
    style: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color')
    }
  },
  {
    type: 'rotate_clock_style3',
    preview:$r('app.media.rotate_clock_style3'),
    style: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color')
    }
  },
  {
    type: 'lunar_calendar_clock_style1',
    preview: $r('app.media.lunar_calendar_clock_style1'),
    style: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color')
    }
  },
  {
    type: 'lunar_calendar_clock_style2',
    preview: $r('app.media.lunar_calendar_clock_style2'),
    style: {
      backgroundColor: $r('app.color.main_background_color'),
      cardColor: $r('app.color.flip_card_bg_color'),
      fontColor: $r('app.color.flip_text_color')
    }
  }
]