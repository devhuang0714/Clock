import {
  DEFAULT_CLOCK_WIDGET_ID,
  getClockWidgetConfigForSize,
  getClockWidgetSizeFromDimension
} from '../../views/Widgets/ClockWidgetConfig'
import { ClockWidgetView } from '../../views/Widgets/ClockWidgetView'

let clockWidgetStorage = new LocalStorage()

@Entry(clockWidgetStorage)
@Component
struct ClockWidgetCard {
  @LocalStorageProp('formId') formId: string = ''
  @LocalStorageProp('widgetStyleId') widgetStyleId: string = DEFAULT_CLOCK_WIDGET_ID
  @LocalStorageProp('formDimension') formDimension: number = 2
  private readonly actionType: string = 'router'
  private readonly abilityName: string = 'EntryAbility'

  build() {
    FormLink({
      action: this.actionType,
      abilityName: this.abilityName,
      params: {
        formId: this.formId,
        from: 'clock_widget'
      }
    }) {
      ClockWidgetView({
        config: getClockWidgetConfigForSize(
          this.widgetStyleId,
          getClockWidgetSizeFromDimension(this.formDimension)
        ),
        widgetSize: getClockWidgetSizeFromDimension(this.formDimension)
      })
    }
  }
}
