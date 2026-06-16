import dataPreferences from '@ohos.data.preferences'
import { formBindingData, formProvider } from '@kit.FormKit'
import { AppConstants } from '../common/constants/Constants'
import {
  DEFAULT_CLOCK_WIDGET_ID,
  getClockWidgetConfigForSize,
  getClockWidgetSizeFromDimension
} from '../views/Widgets/ClockWidgetConfig'

const defaultWidgetKey = 'defaultClockWidgetId'
const formIdListKey = 'clockWidgetFormIdList'
const pendingWidgetKey = 'pendingClockWidgetId'
const pendingDimensionKey = 'pendingClockWidgetDimension'
const pendingCreatedAtKey = 'pendingClockWidgetCreatedAt'
const pendingWidgetTtlMs = 5 * 60 * 1000

export const CLOCK_WIDGET_STYLE_PARAM: string = 'clock_widget_style_id'

export interface ClockWidgetFormData {
  formId: string
  widgetStyleId: string
  formDimension: number
}

export class ClockWidgetConfigManager {
  private static getPreferences(context?: Context): dataPreferences.Preferences {
    return dataPreferences.getPreferencesSync(context ?? getContext(), {
      name: AppConstants.BUNDLE_NAME
    })
  }

  static getDefaultWidgetId(context?: Context): string {
    const preferences = ClockWidgetConfigManager.getPreferences(context)
    return preferences.getSync(defaultWidgetKey, DEFAULT_CLOCK_WIDGET_ID) as string
  }

  static setDefaultWidgetId(widgetId: string, context?: Context): void {
    const preferences = ClockWidgetConfigManager.getPreferences(context)
    preferences.putSync(defaultWidgetKey, widgetId)
    preferences.flush()
  }

  static addFormId(context: Context, formId: string): void {
    const preferences = ClockWidgetConfigManager.getPreferences(context)
    const formIds = ClockWidgetConfigManager.getFormIds(context)
    if (formIds.indexOf(formId) < 0) {
      formIds.push(formId)
      preferences.putSync(formIdListKey, formIds)
      preferences.flush()
    }
  }

  static removeFormId(context: Context, formId: string): void {
    const preferences = ClockWidgetConfigManager.getPreferences(context)
    const formIds = ClockWidgetConfigManager.getFormIds(context)
    const index = formIds.indexOf(formId)
    if (index >= 0) {
      formIds.splice(index, 1)
      preferences.putSync(formIdListKey, formIds)
    }
    preferences.deleteSync(ClockWidgetConfigManager.getFormDimensionKey(formId))
    preferences.deleteSync(ClockWidgetConfigManager.getFormWidgetIdKey(formId))
    preferences.flush()
  }

  static getFormIds(context?: Context): string[] {
    const preferences = ClockWidgetConfigManager.getPreferences(context)
    return preferences.getSync(formIdListKey, []) as string[]
  }

  static saveFormDimension(context: Context, formId: string, dimension: number): void {
    const preferences = ClockWidgetConfigManager.getPreferences(context)
    preferences.putSync(ClockWidgetConfigManager.getFormDimensionKey(formId), dimension)
    preferences.flush()
  }

  static getFormDimension(context: Context, formId: string, fallback: number = 2): number {
    const preferences = ClockWidgetConfigManager.getPreferences(context)
    return preferences.getSync(ClockWidgetConfigManager.getFormDimensionKey(formId), fallback) as number
  }

  static saveFormWidgetId(context: Context, formId: string, widgetId: string): void {
    const preferences = ClockWidgetConfigManager.getPreferences(context)
    preferences.putSync(ClockWidgetConfigManager.getFormWidgetIdKey(formId), widgetId)
    preferences.flush()
  }

  static getFormWidgetId(context: Context, formId: string, fallback?: string): string {
    const preferences = ClockWidgetConfigManager.getPreferences(context)
    const key = ClockWidgetConfigManager.getFormWidgetIdKey(formId)
    const savedWidgetId = preferences.getSync(key, '') as string
    if (savedWidgetId.length > 0) {
      return savedWidgetId
    }

    const resolvedWidgetId = fallback ?? ClockWidgetConfigManager.getDefaultWidgetId(context)
    preferences.putSync(key, resolvedWidgetId)
    preferences.flush()
    return resolvedWidgetId
  }

  static savePendingWidgetId(context: Context, widgetId: string, dimension: number): void {
    const preferences = ClockWidgetConfigManager.getPreferences(context)
    preferences.putSync(pendingWidgetKey, widgetId)
    preferences.putSync(pendingDimensionKey, dimension)
    preferences.putSync(pendingCreatedAtKey, Date.now())
    preferences.flush()
  }

  static consumePendingWidgetId(context: Context, dimension: number): string {
    const preferences = ClockWidgetConfigManager.getPreferences(context)
    const pendingDimension = preferences.getSync(pendingDimensionKey, 0) as number
    const pendingWidgetId = preferences.getSync(pendingWidgetKey, '') as string
    const pendingCreatedAt = preferences.getSync(pendingCreatedAtKey, 0) as number
    preferences.deleteSync(pendingWidgetKey)
    preferences.deleteSync(pendingDimensionKey)
    preferences.deleteSync(pendingCreatedAtKey)
    preferences.flush()

    if (
      pendingDimension == dimension &&
      pendingWidgetId.length > 0 &&
      Date.now() - pendingCreatedAt <= pendingWidgetTtlMs
    ) {
      return pendingWidgetId
    }
    return ''
  }

  static createFormData(context: Context, formId: string, dimension: number, widgetId?: string): ClockWidgetFormData {
    const size = getClockWidgetSizeFromDimension(dimension)
    const widgetConfig = getClockWidgetConfigForSize(
      widgetId ?? ClockWidgetConfigManager.getFormWidgetId(context, formId),
      size
    )

    return {
      formId: formId,
      widgetStyleId: widgetConfig.id,
      formDimension: dimension
    }
  }

  static updateForm(context: Context, formId: string, dimension: number): void {
    const formData = ClockWidgetConfigManager.createFormData(context, formId, dimension)
    const bindingData = formBindingData.createFormBindingData(formData)
    formProvider.updateForm(formId, bindingData)
  }

  static updateAllForms(context?: Context): void {
    const realContext = context ?? getContext()
    const formIds = ClockWidgetConfigManager.getFormIds(realContext)
    formIds.forEach((formId: string) => {
      const dimension = ClockWidgetConfigManager.getFormDimension(realContext, formId)
      ClockWidgetConfigManager.updateForm(realContext, formId, dimension)
    })
  }

  private static getFormDimensionKey(formId: string): string {
    return `${formId}_clock_widget_dimension`
  }

  private static getFormWidgetIdKey(formId: string): string {
    return `${formId}_clock_widget_style_id`
  }
}
