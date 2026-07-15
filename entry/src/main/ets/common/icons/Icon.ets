import { getIconResource } from './IconMap'

@Component
export default struct Icon {
  @Prop name: string = ''
  @Prop iconSize: Length = 18
  @Prop color: ResourceColor = $r('app.color.main_text_color')

  build() {
    Row() {
      Image(getIconResource(this.name))
        .fillColor(this.color)
        .size({ width: this.iconSize, height: this.iconSize })
        .objectFit(ImageFit.Contain)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }
}
