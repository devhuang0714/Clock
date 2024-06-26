import animator, { AnimatorResult } from '@ohos.animator';
import measure from '@ohos.measure'

const fontStyle = 'font-style5'

@Extend(Text)
function setTextStyles(fontSize: number, baselineOffset: number, space: number) {
  .fontFamily(fontStyle)
  .fontSize(fontSize)
  .fontColor($r('app.color.flip_text_color'))
  .fontWeight(FontWeight.Medium)
  .textAlign(TextAlign.Center)
  .lineHeight(fontSize * 0.5)
  .baselineOffset(baselineOffset)
  .height((fontSize - space) * 0.5)
  .width(140)
}

export class FlipCardController {
  changeFn: (next: string) => void = () => {
  }

  public change(next: string) {
    this.changeFn(next)
  }
}

@Component
export struct FlipCard {
  @State space: number = 6
  @State fontSize: number = 60
  @State horizontalMargin: number = 12
  @State verticalMargin: number = 20
  @State prev: string = '--'
  @State current: string = '--'
  @State next: string = '--'
  @State isFlipping: boolean = false
  @State angle: number = 0
  private animator: AnimatorResult = animator.create({
    duration: 900,
    easing: 'ease',
    delay: 0,
    fill: 'none',
    direction: 'normal',
    iterations: 1,
    begin: 0,
    end: 1
  })
  private controller: FlipCardController = new FlipCardController()

  aboutToAppear(): void {
    this.prev = this.current

    this.controller.changeFn = (next) => {
      if (this.current == next) {
        return
      }
      this.next = next
      this.current = this.next
      this.startAnimator()
    }
  }

  startAnimator() {
    this.animator.onframe = (progress: number) => {
      this.angle = -180 * progress
      this.isFlipping = true
    };
    this.animator.onfinish = () => {
      this.angle = -180
      this.isFlipping = false

      this.prev = this.current
      this.next = (parseInt(this.next) + 1).toString()
    }
    this.animator.play();
  }

  build() {
    Column({ space: this.space }) {
      Stack() {
        HalfCard({
          text: this.current,
          fontSize: this.fontSize,
          space: this.space,
          type: HalfCardType.Top,
          horizontalMargin: this.horizontalMargin,
          verticalMargin: this.verticalMargin
        })

        Column() {
          Stack() {
            HalfCard({
              text: this.current,
              fontSize: this.fontSize,
              space: this.space,
              type: HalfCardType.Bottom,
              horizontalMargin: this.horizontalMargin,
              verticalMargin: this.verticalMargin
            })
              .opacity(this.angle <= -90 ? 1 : 0)
              .rotate({
                x: 1,
                centerY: '50%',
                angle: 180
              })

            HalfCard({
              text: this.prev,
              fontSize: this.fontSize,
              space: this.space,
              type: HalfCardType.Top,
              horizontalMargin: this.horizontalMargin,
              verticalMargin: this.verticalMargin
            })
              .opacity(this.angle > -90 ? 1 : 0)
          }
          .zIndex(1)
          .rotate({
            x: 1,
            centerY: this.fontSize * 0.5 + this.verticalMargin,
            angle: this.angle
          })
          .visibility(this.isFlipping ? Visibility.Visible : Visibility.Hidden)
        }
      }
      .zIndex(1)

      Stack() {
        HalfCard({
          text: this.current,
          fontSize: this.fontSize,
          space: this.space,
          type: HalfCardType.Bottom,
          horizontalMargin: this.horizontalMargin,
          verticalMargin: this.verticalMargin
        })

        HalfCard({
          fontSize: this.fontSize,
          text: this.prev,
          space: this.space,
          type: HalfCardType.Bottom,
          horizontalMargin: this.horizontalMargin,
          verticalMargin: this.verticalMargin
        })
          .visibility(this.isFlipping ? Visibility.Visible : Visibility.Hidden)
      }
    }
  }
}

enum HalfCardType {
  Top,
  Bottom
}

@Component
export struct HalfCard {
  @Prop fontSize: number = 60
  @Prop horizontalMargin: number = 0
  @Prop verticalMargin: number = 0
  @Prop type: HalfCardType = HalfCardType.Top
  @Prop space: number = 0
  @Prop text: string = ''
  @Prop radius: number = 8
  @State textWidth : number = this.fontSize

  aboutToAppear(): void {
    let maxWidth = 0
    for (let i = 0; i < 10; i++) {
      const text = `${i}${i}`
      const size = measure.measureTextSize({
        textContent: text,
        fontSize: `${this.fontSize}px`,
        fontFamily: fontStyle,
        fontWeight: FontWeight.Medium
      })
      let width = Math.max(size.width as number, size.height as number)
      if (width > maxWidth) {
        maxWidth = width
      }
    }
    this.textWidth = maxWidth
  }

  build() {
    Column() {
      Text(this.text)
        .setTextStyles(this.fontSize, this.type == HalfCardType.Top ? -this.fontSize * 0.5 : 0, this.space)
        .width(this.textWidth)
    }
    .padding({
      left: this.horizontalMargin,
      right: this.horizontalMargin,
      top: this.type == HalfCardType.Top ? this.verticalMargin : 0,
      bottom: this.type == HalfCardType.Bottom ? this.verticalMargin : 0
    })
    .backgroundColor($r('app.color.flip_card_bg_color'))
    .justifyContent(this.type == HalfCardType.Top ? FlexAlign.End : FlexAlign.Start)
    .borderRadius({
      topLeft: this.type == HalfCardType.Top ? this.radius : 0,
      topRight: this.type == HalfCardType.Top ? this.radius : 0,
      bottomLeft: this.type == HalfCardType.Bottom ? this.radius : 0,
      bottomRight: this.type == HalfCardType.Bottom ? this.radius : 0,
    })
  }
}