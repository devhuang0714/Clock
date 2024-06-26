import { Icons } from '../constants/Constants'

//todo...待研究，ResourceColor类型不能声明@Sate
@Component
export default struct IconFont {
  @State unicode: string = ''
  @State fontSize: number = 14
  // @State fontColor: ResourceColor | Color | number = Color.Black

  build() {
    Text(this.unicode)
      .fontFamily(Icons.FONT_FAMILY)
      .fontSize(this.fontSize)
      // .fontColor(this.fontColor)
      .textAlign(TextAlign.Center)
  }
}