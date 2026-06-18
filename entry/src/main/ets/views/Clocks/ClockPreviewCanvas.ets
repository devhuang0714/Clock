import { ClockController } from './ClockController'
import display from '@ohos.display';
import {
  ClockConfig,
  ClockType,
  DEFAULT_GLOBAL_CONFIG,
  GlobalClockConfig
} from './ClockConfig'
import { FlipClock } from './FlipClock';
import { RoundClock } from './RoundClock';
import { DigitalClock } from './DigitalClock';
import { RotateClock } from './RotateClock';
import { LunarCalendarClock } from './LunarCalendarClock';
import { NormalDigitalClock } from './NormalDigitalClock';
import { StereoscopicClock } from './StereoscopicClock';
import { PosterClock } from './PosterClock';
import { MechanicalClock } from './MechanicalClock';

export const CLOCK_PREVIEW_LANDSCAPE_WIDTH = 1150
export const CLOCK_PREVIEW_LANDSCAPE_HEIGHT = 534
export const CLOCK_PREVIEW_PORTRAIT_WIDTH = 534
export const CLOCK_PREVIEW_PORTRAIT_HEIGHT = 1150
export const CLOCK_PREVIEW_CARD_SHORT_SIDE = 60

function getDisplayShortSideVp(): number {
  const defaultDisplay = display.getDefaultDisplaySync()
  return Math.max(Math.min(px2vp(defaultDisplay.width), px2vp(defaultDisplay.height)), 1)
}

function getDisplayLongSideVp(): number {
  const defaultDisplay = display.getDefaultDisplaySync()
  return Math.max(px2vp(defaultDisplay.width), px2vp(defaultDisplay.height))
}

export function isCurrentPreviewLandscape(): boolean {
  const defaultDisplay = display.getDefaultDisplaySync()
  return defaultDisplay.width >= defaultDisplay.height
}

export function getCurrentPreviewAspectRatio(): number {
  const defaultDisplay = display.getDefaultDisplaySync()
  const longerSide = Math.max(defaultDisplay.width, defaultDisplay.height)
  const shorterSide = Math.max(Math.min(defaultDisplay.width, defaultDisplay.height), 1)
  return longerSide / shorterSide
}

export function getCurrentPreviewCanvasWidth(isLandscape: boolean): number {
  return isLandscape ? getDisplayLongSideVp() : getDisplayShortSideVp()
}

export function getCurrentPreviewCanvasHeight(isLandscape: boolean): number {
  return isLandscape ? getDisplayShortSideVp() : getDisplayLongSideVp()
}

export function getCurrentPreviewItemWidth(isLandscape: boolean,
  shortSide: number = CLOCK_PREVIEW_CARD_SHORT_SIDE): number {
  return isLandscape ? shortSide * getCurrentPreviewAspectRatio() : shortSide
}

export function getCurrentPreviewItemHeight(isLandscape: boolean,
  shortSide: number = CLOCK_PREVIEW_CARD_SHORT_SIDE): number {
  return isLandscape ? shortSide : shortSide * getCurrentPreviewAspectRatio()
}

export function getCurrentPreviewScale(isLandscape: boolean,
  shortSide: number = CLOCK_PREVIEW_CARD_SHORT_SIDE): number {
  return Math.min(getCurrentPreviewItemWidth(isLandscape, shortSide) / getCurrentPreviewCanvasWidth(isLandscape),
    getCurrentPreviewItemHeight(isLandscape, shortSide) / getCurrentPreviewCanvasHeight(isLandscape))
}

@Component
export struct ClockPreviewCanvas {
  @Prop clockConfig: ClockConfig
  @Prop date: Date = new Date()
  @Prop globalConfig: GlobalClockConfig = DEFAULT_GLOBAL_CONFIG
  @Prop isLandscape: boolean = true
  @Prop canvasWidth: number = CLOCK_PREVIEW_LANDSCAPE_WIDTH
  @Prop canvasHeight: number = CLOCK_PREVIEW_LANDSCAPE_HEIGHT
  controller: ClockController = new ClockController()

  build() {
    RelativeContainer() {
      Column() {
        if (this.clockConfig.type == ClockType.Flip) {
          FlipClock({
            controller: this.controller,
            date: this.date,
            colorsConfig: this.clockConfig.colors,
            globalConfig: this.globalConfig,
            isLandscape: this.isLandscape
          })
        } else if (this.clockConfig.type == ClockType.Round) {
          RoundClock({
            controller: this.controller,
            date: this.date,
            style: this.clockConfig.style
          })
        } else if (this.clockConfig.type == ClockType.Digital) {
          DigitalClock({
            controller: this.controller,
            date: this.date,
            colorsConfig: this.clockConfig.colors,
            globalConfig: this.globalConfig,
          })
        } else if (this.clockConfig.type == ClockType.Rotate) {
          RotateClock({
            controller: this.controller,
            date: this.date,
            style: this.clockConfig.style,
            colorsConfig: this.clockConfig.colors,
            globalConfig: this.globalConfig,
            lightOn: this.clockConfig.ext?.lightOn ?? false,
            isLandscape: this.isLandscape,
          })
        } else if (this.clockConfig.type == ClockType.LunarCalendar) {
          LunarCalendarClock({
            controller: this.controller,
            date: this.date,
            style: this.clockConfig.style,
            colorsConfig: this.clockConfig.colors,
            globalConfig: this.globalConfig,
            isLandscape: this.isLandscape,
          })
        } else if (this.clockConfig.type == ClockType.NormalDigital) {
          NormalDigitalClock({
            controller: this.controller,
            date: this.date,
            colorsConfig: this.clockConfig.colors,
            globalConfig: this.globalConfig,
            isLandscape: this.isLandscape,
          })
        } else if (this.clockConfig.type == ClockType.Stereoscopic) {
          StereoscopicClock({
            controller: this.controller,
            date: this.date,
            colorsConfig: this.clockConfig.colors,
            globalConfig: this.globalConfig,
            isLandscape: this.isLandscape,
          })
        } else if (this.clockConfig.type == ClockType.Poster) {
          PosterClock({
            controller: this.controller,
            date: this.date,
            style: this.clockConfig.style,
            colorsConfig: this.clockConfig.colors,
            globalConfig: this.globalConfig,
            isLandscape: this.isLandscape,
          })
        } else if (this.clockConfig.type == ClockType.Mechanical) {
          MechanicalClock({
            controller: this.controller,
            date: this.date,
            isLandscape: this.isLandscape
          })
        }
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.clockConfig.colors.backgroundColor)
      .alignRules({
        top: { anchor: "__container__", align: VerticalAlign.Top },
        left: { anchor: "__container__", align: HorizontalAlign.Start },
        right: { anchor: "__container__", align: HorizontalAlign.End },
        bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
      })
      .id("preview_clock")
      .height(this.canvasHeight)
      .width(this.canvasWidth)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
  }
}
