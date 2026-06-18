import HYLogger from '../../common/utils/HYLogger';
import { display } from '@kit.ArkUI';
import ClockSoundPlayer, { ROUND_CLOCK_TICK_SOUND } from '../../common/utils/ClockSoundPlayer'
import { ClockController, ClockListener } from './ClockController'
import { ClockStyle } from './ClockConfig'

const HOURS: Array<string> = ['3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '1', '2'];
const CLOCK_HOURS: Array<string> = ['12', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11'];
const ROMAN_HOURS: Array<string> = ['XII', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI'];
const TAG: string = 'Index';

@Component({ freezeWhenInactive: true })
export struct RoundClock {
  controller: ClockController = new ClockController()
  date: Date = new Date()
  @Prop style: ClockStyle = ClockStyle.Style1
  @State canvasWidth: number = 300; // 300是表盘默认大小
  @State hourAngle: number = 0
  @State minuteAngle: number = 0
  @State secondAngle: number = 0
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private radius: number = 150; // 默认表盘半径
  private lastSoundSecond: number = -1
  private listener: ClockListener = {
    onUpdate: (date) => {
      this.playTickSound(date)
      if (this.isImageStackStyle()) {
        const milliseconds = date.getMilliseconds()
        const seconds = date.getSeconds() + milliseconds / 1000
        const minutes = date.getMinutes() + seconds / 60
        const hours = date.getHours() % 12 + minutes / 60

        this.secondAngle = seconds * 6
        this.minuteAngle = minutes * 6
        this.hourAngle = hours * 30
        return
      }

      this.context.clearRect(0, 0, this.canvasWidth, this.canvasWidth);
      this.context.save();
      this.drawBackGround();
      this.drawHour(date.getHours(), date.getMinutes());
      this.drawMinute(date.getMinutes());
      this.drawSecond(date.getSeconds());
      this.drawDot();
      this.context.restore();
    }
  }

  private playTickSound(date: Date): void {
    const second = date.getSeconds()
    if (this.lastSoundSecond >= 0 && this.lastSoundSecond != second) {
      ClockSoundPlayer.play(ROUND_CLOCK_TICK_SOUND)
    }
    this.lastSoundSecond = second
  }

  aboutToAppear() {
    // this.getSize();
    this.controller.registerListener(this.listener)
    if (this.isImageStackStyle()) {
      this.listener.onUpdate(this.date)
    }
  }

  aboutToDisappear(): void {
    this.controller.unregisterListener(this.listener)
  }

  // 获取设备宽高计算表盘大小
  async getSize() {
    let mDisplay = await display.getDefaultDisplaySync();
    HYLogger.info(TAG, `getDefaultDisplay mDisplay = ${JSON.stringify(mDisplay)}`);
    this.canvasWidth = px2vp(mDisplay.width > mDisplay.height ? mDisplay.height * 0.6 : mDisplay.width * 0.6);
    this.radius = this.canvasWidth / 2;
  }

  fillTime(time: number) {
    return time < 10 ? `0${time}` : `${time}`;
  }

  isImageStackStyle(): boolean {
    return this.style == ClockStyle.Style2 || this.style == ClockStyle.Style3 ||
      this.style == ClockStyle.Style4 || this.style == ClockStyle.Style5 ||
      this.style == ClockStyle.Style6 || this.style == ClockStyle.Style7
  }

  drawBackGround() {
    this.context.translate(this.radius, this.radius);
    switch (this.style) {
      case ClockStyle.Style2:
        this.drawCoolFace();
        break;
      case ClockStyle.Style3:
        this.drawCyberpunkFace();
        break;
      case ClockStyle.Style4:
        this.drawCuteFace();
        break;
      case ClockStyle.Style5:
        this.drawRetroFace();
        break;
      case ClockStyle.Style6:
        this.drawArtDecoFace();
        break;
      default:
        this.drawClassicFace();
        break;
    }
  }

  // 绘制时针
  drawHour(hour: number, minute: number) {
    let rad = 2 * Math.PI / 12 * (hour % 12);
    let mrad = 2 * Math.PI / 12 / 60 * minute;
    this.drawHand(rad + mrad, this.getHourHandWidth(), this.getHourHandColor(), this.radius * 0.46, 10);
  }

  // 绘制分针
  drawMinute(minute: number) {
    let rad = 2 * Math.PI / 60 * minute;
    this.drawHand(rad, this.getMinuteHandWidth(), this.getMinuteHandColor(), this.radius - 42, 12);
  }

  // 绘制秒针
  drawSecond(second: number) {
    let rad = 2 * Math.PI / 60 * second;
    this.drawHand(rad, this.getSecondHandWidth(), this.getSecondHandColor(), this.radius - 24, 14);
  }

  drawHand(rad: number, width: number, color: string, length: number, tailLength: number) {
    this.context.save();
    this.context.beginPath();
    this.context.lineWidth = width;
    this.context.lineCap = 'round';
    this.context.rotate(rad);
    this.context.moveTo(0, tailLength);
    this.context.strokeStyle = color;
    this.context.lineTo(0, -length);
    this.context.stroke();
    this.context.restore();
  }

  // 绘制中心点
  drawDot() {
    switch (this.style) {
      case ClockStyle.Style2:
        this.fillCircle(0, 0, 9, '#0d2027');
        this.strokeCircle(0, 0, 9, '#8ff7ff', 3);
        this.fillCircle(0, 0, 3, '#ffffff');
        break;
      case ClockStyle.Style3:
        this.fillCircle(0, 0, 10, '#ff2bd6');
        this.strokeCircle(0, 0, 15, '#00f6ff', 2);
        this.fillCircle(0, 0, 4, '#11071f');
        break;
      case ClockStyle.Style4:
        this.fillCircle(0, 0, 11, '#ff8fc7');
        this.fillCircle(0, 0, 5, '#fff8c8');
        break;
      case ClockStyle.Style5:
        this.fillCircle(0, 0, 11, '#6d3f1d');
        this.strokeCircle(0, 0, 16, '#c99742', 2);
        break;
      case ClockStyle.Style6:
        this.fillCircle(0, 0, 11, '#e5bd62');
        this.fillCircle(0, 0, 5, '#0b3a35');
        break;
      default:
        this.fillCircle(0, 0, 4, 'red');
        break;
    }
  }

  drawClassicFace() {
    let grad = this.context.createRadialGradient(0, 0, this.radius - 32, 0, 0, this.radius);
    grad.addColorStop(0.0, 'white');
    grad.addColorStop(0.9, '#eee');
    grad.addColorStop(1.0, 'white');
    this.context.fillStyle = grad;
    this.context.fillRect(-this.radius, -this.radius, this.canvasWidth, this.canvasWidth);

    this.strokeCircle(0, 0, this.radius - 5, '#fff', 6);
    this.context.font = '36px';
    this.context.textAlign = 'center';
    this.context.textBaseline = 'middle';
    this.context.fillStyle = '#000';
    HOURS.forEach((num, index) => {
      let rad = 2 * Math.PI / 12 * index;
      let x = Math.cos(rad) * (this.radius - 38);
      let y = Math.sin(rad) * (this.radius - 38);
      this.context.fillText(num, x, y);
    })
    this.drawTickLines('#000', '#ccc', 2, 1, 20, 18, this.radius - 12);
  }

  drawCoolFace() {
    let grad = this.context.createRadialGradient(0, 0, this.radius * 0.15, 0, 0, this.radius);
    grad.addColorStop(0.0, '#24313a');
    grad.addColorStop(0.58, '#0d1820');
    grad.addColorStop(1.0, '#02080d');
    this.context.fillStyle = grad;
    this.context.fillRect(-this.radius, -this.radius, this.canvasWidth, this.canvasWidth);

    this.strokeCircle(0, 0, this.radius - 7, '#8ff7ff', 4);
    this.strokeCircle(0, 0, this.radius - 18, '#304a56', 2);
    this.strokeCircle(0, 0, this.radius * 0.52, '#20313a', 1);
    this.drawTickLines('#d8fbff', '#416474', 3, 1, 28, 16, this.radius - 18);
    this.drawHourDots('#8ff7ff', this.radius - 42, 4);
  }

  drawCyberpunkFace() {
    let grad = this.context.createRadialGradient(0, 0, this.radius * 0.08, 0, 0, this.radius);
    grad.addColorStop(0.0, '#231238');
    grad.addColorStop(0.62, '#0e071a');
    grad.addColorStop(1.0, '#03030b');
    this.context.fillStyle = grad;
    this.context.fillRect(-this.radius, -this.radius, this.canvasWidth, this.canvasWidth);

    this.strokeCircle(0, 0, this.radius - 7, '#ff2bd6', 3);
    this.strokeCircle(0, 0, this.radius - 17, '#00f6ff', 2);
    this.drawSegmentedRing(this.radius - 32, '#ff2bd6', 4, 12);
    this.drawSegmentedRing(this.radius - 52, '#00f6ff', 2, 8);
    this.drawAlternatingTicks('#00f6ff', '#ff2bd6');
    this.drawHourLabels(CLOCK_HOURS, '#fdf4ff', this.radius - 70, 24);
  }

  drawCuteFace() {
    let grad = this.context.createRadialGradient(0, 0, this.radius * 0.2, 0, 0, this.radius);
    grad.addColorStop(0.0, '#fffef7');
    grad.addColorStop(0.7, '#ffdff0');
    grad.addColorStop(1.0, '#ffd0e8');
    this.context.fillStyle = grad;
    this.context.fillRect(-this.radius, -this.radius, this.canvasWidth, this.canvasWidth);

    this.strokeCircle(0, 0, this.radius - 7, '#ff8fc7', 5);
    this.strokeCircle(0, 0, this.radius - 20, '#fff8c8', 6);
    this.drawPastelDots();
    this.drawHourLabels(CLOCK_HOURS, '#6a4b73', this.radius - 52, 28);
    this.drawTickLines('#ff8fc7', '#efbad7', 3, 1, 18, 10, this.radius - 18);
  }

  drawRetroFace() {
    let grad = this.context.createRadialGradient(0, 0, this.radius * 0.15, 0, 0, this.radius);
    grad.addColorStop(0.0, '#f7e8c7');
    grad.addColorStop(0.78, '#d9b873');
    grad.addColorStop(1.0, '#6d3f1d');
    this.context.fillStyle = grad;
    this.context.fillRect(-this.radius, -this.radius, this.canvasWidth, this.canvasWidth);

    this.strokeCircle(0, 0, this.radius - 8, '#6d3f1d', 6);
    this.strokeCircle(0, 0, this.radius - 20, '#c99742', 3);
    this.drawTickLines('#6d3f1d', '#b78b47', 4, 1, 27, 13, this.radius - 22);
    this.drawHourLabels(ROMAN_HOURS, '#4a2b16', this.radius - 60, 23);
  }

  drawArtDecoFace() {
    let grad = this.context.createRadialGradient(0, 0, this.radius * 0.12, 0, 0, this.radius);
    grad.addColorStop(0.0, '#145b50');
    grad.addColorStop(0.72, '#0b3a35');
    grad.addColorStop(1.0, '#041411');
    this.context.fillStyle = grad;
    this.context.fillRect(-this.radius, -this.radius, this.canvasWidth, this.canvasWidth);

    this.strokeCircle(0, 0, this.radius - 8, '#e5bd62', 4);
    this.strokeCircle(0, 0, this.radius - 23, '#8d6b2f', 2);
    this.drawDecoSpokes();
    this.drawDiamondMarkers();
    this.drawHourLabels(ROMAN_HOURS, '#f7dfa1', this.radius - 61, 22);
  }

  drawTickLines(majorColor: string, minorColor: string, majorWidth: number, minorWidth: number, majorLength: number,
    minorLength: number, outerRadius: number) {
    for (let i = 0; i < 60; i++) {
      let rad = 2 * Math.PI / 60 * i - Math.PI / 2;
      let outerX = Math.cos(rad) * outerRadius;
      let outerY = Math.sin(rad) * outerRadius;
      let length = i % 5 == 0 ? majorLength : minorLength;
      let innerX = Math.cos(rad) * (outerRadius - length);
      let innerY = Math.sin(rad) * (outerRadius - length);
      this.context.beginPath();
      this.context.moveTo(outerX, outerY);
      this.context.lineTo(innerX, innerY);
      this.context.strokeStyle = i % 5 == 0 ? majorColor : minorColor;
      this.context.lineWidth = i % 5 == 0 ? majorWidth : minorWidth;
      this.context.stroke();
    }
  }

  drawAlternatingTicks(cyan: string, magenta: string) {
    for (let i = 0; i < 60; i++) {
      let rad = 2 * Math.PI / 60 * i - Math.PI / 2;
      let outerRadius = this.radius - 18;
      let innerRadius = i % 5 == 0 ? this.radius - 42 : this.radius - 28;
      this.context.beginPath();
      this.context.moveTo(Math.cos(rad) * outerRadius, Math.sin(rad) * outerRadius);
      this.context.lineTo(Math.cos(rad) * innerRadius, Math.sin(rad) * innerRadius);
      this.context.strokeStyle = i % 10 == 0 ? magenta : cyan;
      this.context.lineWidth = i % 5 == 0 ? 4 : 1;
      this.context.stroke();
    }
  }

  drawHourLabels(labels: Array<string>, color: string, radius: number, fontSize: number) {
    this.context.font = `${fontSize}px`;
    this.context.textAlign = 'center';
    this.context.textBaseline = 'middle';
    this.context.fillStyle = color;
    labels.forEach((num, index) => {
      let rad = 2 * Math.PI / 12 * index - Math.PI / 2;
      this.context.fillText(num, Math.cos(rad) * radius, Math.sin(rad) * radius);
    })
  }

  drawHourDots(color: string, radius: number, dotRadius: number) {
    for (let i = 0; i < 12; i++) {
      let rad = 2 * Math.PI / 12 * i - Math.PI / 2;
      this.fillCircle(Math.cos(rad) * radius, Math.sin(rad) * radius, dotRadius, color);
    }
  }

  drawPastelDots() {
    const colors: Array<string> = ['#ff8fc7', '#7fd9ff', '#fff08a', '#b9efa7'];
    for (let i = 0; i < 24; i++) {
      let rad = 2 * Math.PI / 24 * i - Math.PI / 2;
      let dotRadius = i % 2 == 0 ? 5 : 3;
      this.fillCircle(Math.cos(rad) * (this.radius - 31), Math.sin(rad) * (this.radius - 31), dotRadius,
        colors[i % colors.length]);
    }
    this.drawStar(-this.radius * 0.34, -this.radius * 0.2, 8, 4, '#7fd9ff');
    this.drawStar(this.radius * 0.34, this.radius * 0.28, 7, 3, '#fff08a');
  }

  drawSegmentedRing(radius: number, color: string, width: number, count: number) {
    this.context.strokeStyle = color;
    this.context.lineWidth = width;
    for (let i = 0; i < count; i++) {
      let start = 2 * Math.PI / count * i + 0.08;
      let end = start + 2 * Math.PI / count * 0.55;
      this.context.beginPath();
      this.context.arc(0, 0, radius, start, end, false);
      this.context.stroke();
    }
  }

  drawDecoSpokes() {
    for (let i = 0; i < 12; i++) {
      let rad = 2 * Math.PI / 12 * i - Math.PI / 2;
      this.context.beginPath();
      this.context.moveTo(Math.cos(rad) * (this.radius * 0.35), Math.sin(rad) * (this.radius * 0.35));
      this.context.lineTo(Math.cos(rad) * (this.radius - 40), Math.sin(rad) * (this.radius - 40));
      this.context.strokeStyle = i % 3 == 0 ? '#e5bd62' : '#8d6b2f';
      this.context.lineWidth = i % 3 == 0 ? 2 : 1;
      this.context.stroke();
    }
    this.strokeCircle(0, 0, this.radius * 0.35, '#8d6b2f', 1);
  }

  drawDiamondMarkers() {
    for (let i = 0; i < 12; i++) {
      let rad = 2 * Math.PI / 12 * i;
      this.context.save();
      this.context.rotate(rad);
      this.context.translate(0, -this.radius + 35);
      this.context.rotate(Math.PI / 4);
      this.context.fillStyle = i % 3 == 0 ? '#f7dfa1' : '#e5bd62';
      this.context.fillRect(-5, -5, 10, 10);
      this.context.restore();
    }
  }

  drawStar(x: number, y: number, outerRadius: number, innerRadius: number, color: string) {
    this.context.save();
    this.context.beginPath();
    for (let i = 0; i < 10; i++) {
      let rad = -Math.PI / 2 + i * Math.PI / 5;
      let radius = i % 2 == 0 ? outerRadius : innerRadius;
      let pointX = x + Math.cos(rad) * radius;
      let pointY = y + Math.sin(rad) * radius;
      if (i == 0) {
        this.context.moveTo(pointX, pointY);
      } else {
        this.context.lineTo(pointX, pointY);
      }
    }
    this.context.closePath();
    this.context.fillStyle = color;
    this.context.fill();
    this.context.restore();
  }

  fillCircle(x: number, y: number, radius: number, color: string) {
    this.context.beginPath();
    this.context.fillStyle = color;
    this.context.arc(x, y, radius, 0, 2 * Math.PI, false);
    this.context.fill();
  }

  strokeCircle(x: number, y: number, radius: number, color: string, width: number) {
    this.context.beginPath();
    this.context.strokeStyle = color;
    this.context.lineWidth = width;
    this.context.arc(x, y, radius, 0, 2 * Math.PI, false);
    this.context.stroke();
  }

  getHourHandColor(): string {
    switch (this.style) {
      case ClockStyle.Style2:
        return '#d8fbff';
      case ClockStyle.Style3:
        return '#00f6ff';
      case ClockStyle.Style4:
        return '#6a4b73';
      case ClockStyle.Style5:
        return '#4a2b16';
      case ClockStyle.Style6:
        return '#f7dfa1';
      default:
        return '#000';
    }
  }

  getMinuteHandColor(): string {
    switch (this.style) {
      case ClockStyle.Style2:
        return '#8ff7ff';
      case ClockStyle.Style3:
        return '#ff2bd6';
      case ClockStyle.Style4:
        return '#ff8fc7';
      case ClockStyle.Style5:
        return '#6d3f1d';
      case ClockStyle.Style6:
        return '#e5bd62';
      default:
        return '#000';
    }
  }

  getSecondHandColor(): string {
    switch (this.style) {
      case ClockStyle.Style2:
        return '#ffffff';
      case ClockStyle.Style3:
        return '#fdf4ff';
      case ClockStyle.Style4:
        return '#7fd9ff';
      case ClockStyle.Style5:
        return '#bd2636';
      case ClockStyle.Style6:
        return '#62d0bb';
      default:
        return 'red';
    }
  }

  getHourHandWidth(): number {
    return this.style == ClockStyle.Style4 ? 9 : 8;
  }

  getMinuteHandWidth(): number {
    return this.style == ClockStyle.Style4 ? 6 : 5;
  }

  getSecondHandWidth(): number {
    return this.style == ClockStyle.Style3 ? 3 : 2;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.style == ClockStyle.Style2) {
        Stack() {
          Image($r('app.media.round_neon_clock_face'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)

          Image($r('app.media.round_neon_hour_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.hourAngle })

          Image($r('app.media.round_neon_minute_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.minuteAngle })

          Image($r('app.media.round_neon_second_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.secondAngle })

          Image($r('app.media.round_neon_center_cap'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
        }
        .width(this.canvasWidth)
        .height(this.canvasWidth)
      } else if (this.style == ClockStyle.Style3) {
        Stack() {
          Image($r('app.media.round_cyber_clock_face'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)

          Image($r('app.media.round_cyber_hour_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.hourAngle })

          Image($r('app.media.round_cyber_minute_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.minuteAngle })

          Image($r('app.media.round_cyber_second_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.secondAngle })

          Image($r('app.media.round_cyber_center_cap'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
        }
        .width(this.canvasWidth)
        .height(this.canvasWidth)
      } else if (this.style == ClockStyle.Style4) {
        Stack() {
          Image($r('app.media.round_style4_clock_face'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)

          Image($r('app.media.round_style4_hour_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.hourAngle })

          Image($r('app.media.round_style4_minute_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.minuteAngle })

          Image($r('app.media.round_style4_second_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.secondAngle })

          Image($r('app.media.round_style4_center_cap'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
        }
        .width(this.canvasWidth)
        .height(this.canvasWidth)
      } else if (this.style == ClockStyle.Style5) {
        Stack() {
          Image($r('app.media.round_style5_clock_face'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)

          Image($r('app.media.round_style5_hour_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.hourAngle })

          Image($r('app.media.round_style5_minute_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.minuteAngle })

          Image($r('app.media.round_style5_second_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.secondAngle })

          Image($r('app.media.round_style5_center_cap'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
        }
        .width(this.canvasWidth)
        .height(this.canvasWidth)
      } else if (this.style == ClockStyle.Style6) {
        Stack() {
          Image($r('app.media.round_style6_clock_face'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)

          Image($r('app.media.round_style6_hour_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.hourAngle })

          Image($r('app.media.round_style6_minute_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.minuteAngle })

          Image($r('app.media.round_style6_second_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.secondAngle })

          Image($r('app.media.round_style6_center_cap'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
        }
        .width(this.canvasWidth)
        .height(this.canvasWidth)
      } else if (this.style == ClockStyle.Style7) {
        Stack() {
          Image($r('app.media.round_style7_clock_face'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)

          Image($r('app.media.round_style7_hour_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.hourAngle })

          Image($r('app.media.round_style7_minute_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.minuteAngle })

          Image($r('app.media.round_style7_second_hand'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .rotate({ angle: this.secondAngle })

          Image($r('app.media.round_style7_center_cap'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
        }
        .width(this.canvasWidth)
        .height(this.canvasWidth)
      } else {
        Canvas(this.context)
          .width(this.canvasWidth)
          .height(this.canvasWidth)
          .borderRadius(this.canvasWidth * 0.5)
          .clip(true)
          .onReady(() => {
            this.listener.onUpdate(this.date);
          })
      }
    }
    .width('100%')
    .height('100%')
  }
}
