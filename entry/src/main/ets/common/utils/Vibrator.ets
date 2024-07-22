import vibrator from '@ohos.vibrator';
import { BusinessError } from '@ohos.base';

export function startVibration() {
  try {
    // 按照固定时长振动
    vibrator.startVibration({
      type: 'time',
      duration: 15,
    }, {
      id: 0,
      usage: 'physicalFeedback'
    }, (error: BusinessError) => {
      if (error) {
        console.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
        return;
      }
      console.info('Succeed in starting vibration');
    });
  } catch (err) {
    let e: BusinessError = err as BusinessError;
    console.error(`An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
  }
}