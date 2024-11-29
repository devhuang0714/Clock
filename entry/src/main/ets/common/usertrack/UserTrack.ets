// import { preInit, InternalPlugin, setLogEnabled, init, onEventObject } from '@umeng/analytics';
import common from '@ohos.app.ability.common';
import Logger from '../utils/HYLogger'

export declare class UTConfig {
  context: common.ApplicationContext;
}

export class UT {
  static preInit(config: UTConfig) {
    // preInit({
    //   context: config.context,
    //   plugins: [new InternalPlugin()]
    // })
  }

  static init() {
    // init()
    // //todo...判断debug，开启日志打印
    // setLogEnabled(true)
  }

  static onEvent(eventID: string, params: Record<string, string | number>) {
    // onEventObject(eventID, params)
    // Logger.info(`[UT] onEvent: ${eventID} params: ${JSON.stringify(params)}`)
  }

  static onPageStart(pageName: string, params: Record<string, string | number>) {
    UT.onEvent(`${pageName}_start`, params)
  }

  static onPageEnd(pageName: string, params: Record<string, string | number>) {
    UT.onEvent(`${pageName}_end`, params)
  }
}