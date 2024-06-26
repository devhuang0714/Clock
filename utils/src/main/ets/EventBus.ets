import emitter from '@ohos.events.emitter';

export class Events {
  static readonly HOME_PAGE_APPEAR: number = 1001;
  static readonly HOME_SCROLL_TO_TOP: number = 1002;
  static readonly BILL_DID_UPDATED: number = 2001;
}

export class EventBus {
  static on(event: number, callback: (data: emitter.EventData) => void) {
    let innerEvent: emitter.InnerEvent = {
      eventId: event
    };

    emitter.on(innerEvent, (data) => {
      callback(data)
    })
  }

  static once(event: number, callback: (data: emitter.EventData) => void) {
    let innerEvent: emitter.InnerEvent = {
      eventId: event
    };

    emitter.once(innerEvent, (data) => {
      callback(data)
    })
  }

  static off(event: number) {
    emitter.off(event)
  }

  static emit(event: number, data?: emitter.EventData) {
    let innerEvent: emitter.InnerEvent = {
      eventId: event
    };

    emitter.emit(innerEvent, data)
  }
}