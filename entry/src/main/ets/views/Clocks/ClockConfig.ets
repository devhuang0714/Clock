
export interface ClockConfig {
  style: string,
  preview: Resource,
  backgroundColor: ResourceColor,
  cardColor: ResourceColor,
  fontColor: ResourceColor
}

export const CLOCK_CONFIGS: ClockConfig[] = [
  {
    style: 'flip_clock_default',
    preview: $r('app.media.flip_clock_default'),
    backgroundColor: $r('app.color.main_background_color'),
    cardColor: $r('app.color.flip_card_bg_color'),
    fontColor: $r('app.color.flip_text_color')
  },
  {
    style: 'round_clock_default',
    preview: $r('app.media.round_clock_default'),
    backgroundColor: $r('app.color.main_background_color'),
    cardColor: $r('app.color.flip_card_bg_color'),
    fontColor: $r('app.color.flip_text_color')
  },
  {
    style: 'digital_clock_default',
    preview: $r('app.media.digital_clock_default'),
    backgroundColor: $r('app.color.main_background_color'),
    cardColor: $r('app.color.flip_card_bg_color'),
    fontColor: $r('app.color.flip_text_color')
  },
  {
    style: 'rotate_clock_style1',
    preview: $r('app.media.rotate_clock_style1'),
    backgroundColor: $r('app.color.main_background_color'),
    cardColor: $r('app.color.flip_card_bg_color'),
    fontColor: $r('app.color.flip_text_color')
  },
  {
    style: 'rotate_clock_style2',
    preview: $r('app.media.rotate_clock_style2'),
    backgroundColor: $r('app.color.main_background_color'),
    cardColor: $r('app.color.flip_card_bg_color'),
    fontColor: $r('app.color.flip_text_color')
  },
  {
    style: 'rotate_clock_style3',
    preview:$r('app.media.rotate_clock_style3'),
    backgroundColor: $r('app.color.main_background_color'),
    cardColor: $r('app.color.flip_card_bg_color'),
    fontColor: $r('app.color.flip_text_color')
  },
  {
    style: 'lunar_calendar_clock_style1',
    preview: $r('app.media.lunar_calendar_clock_style1'),
    backgroundColor: $r('app.color.main_background_color'),
    cardColor: $r('app.color.flip_card_bg_color'),
    fontColor: $r('app.color.flip_text_color')
  },
  {
    style: 'lunar_calendar_clock_style2',
    preview: $r('app.media.lunar_calendar_clock_style2'),
    backgroundColor: $r('app.color.main_background_color'),
    cardColor: $r('app.color.flip_card_bg_color'),
    fontColor: $r('app.color.flip_text_color')
  }
]