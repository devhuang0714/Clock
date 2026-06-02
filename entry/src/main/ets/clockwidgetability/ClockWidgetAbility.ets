import { Want } from '@kit.AbilityKit'
import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { ClockWidgetConfigManager } from '../models/ClockWidgetConfigManager'

const TAG: string = 'ClockWidgetAbility'

export default class ClockWidgetAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    if (want == undefined || want.parameters == undefined) {
      hilog.error(0x0000, TAG, 'onAddForm want or parameters is undefined')
      return formBindingData.createFormBindingData('')
    }

    const formId = (want.parameters[formInfo.FormParam.IDENTITY_KEY] as string) ?? ''
    const dimension = (want.parameters[formInfo.FormParam.DIMENSION_KEY] as number) ?? 2
    ClockWidgetConfigManager.addFormId(this.context, formId)
    ClockWidgetConfigManager.saveFormDimension(this.context, formId, dimension)

    return formBindingData.createFormBindingData(
      ClockWidgetConfigManager.createFormData(this.context, formId, dimension)
    )
  }

  onUpdateForm(formId: string): void {
    const dimension = ClockWidgetConfigManager.getFormDimension(this.context, formId)
    ClockWidgetConfigManager.updateForm(this.context, formId, dimension)
  }

  onSizeChanged(formId: string, newDimension: formInfo.FormDimension): void {
    ClockWidgetConfigManager.saveFormDimension(this.context, formId, newDimension as number)
    ClockWidgetConfigManager.updateForm(this.context, formId, newDimension as number)
  }

  onRemoveForm(formId: string): void {
    ClockWidgetConfigManager.removeFormId(this.context, formId)
  }

  onAcquireFormState(want: Want): formInfo.FormState {
    return formInfo.FormState.READY
  }
}
