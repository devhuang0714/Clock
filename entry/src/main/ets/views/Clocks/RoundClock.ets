import HYLogger from '../../common/utils/HYLogger';
import { display } from '@kit.ArkUI';
import { ClockController, ClockListener } from './ClockController'

const HOURS: Array<string> = ['3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '1', '2'];
const TAG: string = 'Index';

@Component({ freezeWhenInactive: true })
export struct RoundClock {
  controller: ClockController = new ClockController()
  date: Date = new Date()
  @State canvasWidth: number = 300; // 300是表盘默认大小
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private radius: number = 150; // 默认表盘半径
  private listener: ClockListener = {
    onUpdate: (date) => {
      this.context.clearRect(0, 0, this.canvasWidth, this.canvasWidth);
      this.drawBackGround();
      this.drawHour(date.getHours(), date.getMinutes());
      this.drawMinute(date.getMinutes());
      this.drawSecond(date.getSeconds());
      this.drawDot();
      this.context.translate(-this.radius, -this.radius);
    }
  }

  aboutToAppear() {
    this.getSize();
    this.controller.registerListener(this.listener)
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

  drawBackGround() {
    this.context.save();

    // 绘制背景
    let grad = this.context.createRadialGradient(this.radius, this.radius, this.radius - 32, this.radius,
      this.radius, this.radius);
    grad.addColorStop(0.0, 'white');
    grad.addColorStop(0.9, '#eee');
    grad.addColorStop(1.0, 'white');
    this.context.fillStyle = grad
    this.context.fillRect(0, 0, this.canvasWidth, this.canvasWidth);

    // 绘制外圈圆
    this.context.translate(this.radius, this.radius);
    this.context.lineWidth = 6;
    this.context.beginPath();
    this.context.strokeStyle = '#fff';
    this.context.arc(0, 0, this.radius - 5, 0, 2 * Math.PI, false);
    this.context.stroke();

    // 绘制时间文字
    this.context.font = '36px';
    this.context.textAlign = "center";
    this.context.textBaseline = "middle";
    this.context.fillStyle = '#000';
    HOURS.forEach((num, index) => {
      this.context.save();
      let rad = 2 * Math.PI / 12 * index;
      let x = Math.cos(rad) * (this.radius - 38);
      let y = Math.sin(rad) * (this.radius - 38);
      this.context.fillText(num, x, y);
    })

    // 绘制刻度
    for (let i = 0; i < 60; i++) {
      let rad = 2 * Math.PI / 60 * i;
      let x = Math.cos(rad) * (this.radius - 12);
      let y = Math.sin(rad) * (this.radius - 12);
      this.context.beginPath();
      this.context.moveTo(x, y);
      if (i % 5 == 0) {
        let x1 = Math.cos(rad) * (this.radius - 20);
        let y1 = Math.sin(rad) * (this.radius - 20);
        this.context.strokeStyle = '#000';
        this.context.lineWidth = 2;
        this.context.lineTo(x1, y1);
      } else {
        let x1 = Math.cos(rad) * (this.radius - 18);
        let y1 = Math.sin(rad) * (this.radius - 18);
        this.context.strokeStyle = '#ccc';
        this.context.lineWidth = 1;
        this.context.lineTo(x1, y1);
      }
      this.context.stroke();
    }
  }

  // 绘制时针
  drawHour(hour: number, minute: number) {
    this.context.save();
    this.context.beginPath();
    this.context.lineWidth = 8;
    this.context.lineCap = 'round';
    let rad = 2 * Math.PI / 12 * hour;
    let mrad = 2 * Math.PI / 12 / 60 * minute;
    this.context.rotate(rad + mrad);
    this.context.moveTo(0, 10);
    this.context.strokeStyle = '#000';
    this.context.lineTo(0, -this.radius / 2);
    this.context.stroke();
    this.context.restore();
  }

  // 绘制分针
  drawMinute(minute: number) {
    this.context.save();
    this.context.beginPath();
    this.context.lineWidth = 5;
    this.context.lineCap = 'round';
    let rad = 2 * Math.PI / 60 * minute;
    this.context.rotate(rad);
    this.context.moveTo(0, 10);
    this.context.strokeStyle = '#000';
    this.context.lineTo(0, -this.radius + 40);
    this.context.stroke();
    this.context.restore();
  }

  // 绘制秒针
  drawSecond(second: number) {
    this.context.save();
    this.context.beginPath();
    this.context.lineWidth = 2;
    this.context.lineCap = 'round';
    let rad = 2 * Math.PI / 60 * second;
    this.context.rotate(rad);
    this.context.moveTo(0, 10);
    this.context.strokeStyle = 'red';
    this.context.lineTo(0, -this.radius + 21);
    this.context.stroke();
    this.context.restore();
  }

  // 绘制中心点
  drawDot() {
    this.context.save();
    this.context.beginPath();
    this.context.fillStyle = 'red';
    this.context.arc(0, 0, 4, 0, 2 * Math.PI, false);
    this.context.fill();
    this.context.restore();
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Canvas(this.context)
        .width(this.canvasWidth)
        .height(this.canvasWidth)
        .borderRadius(this.canvasWidth * 0.5)
        .clip(true)
        .onReady(() => {
          this.listener.onUpdate(this.date);
        })
    }
    .width('100%')
    .height('100%')
  }
}