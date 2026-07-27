import { BusinessError } from '@kit.BasicServicesKit';
import { audio } from '@kit.AudioKit';
import { media } from '@kit.MediaKit';
import HYLogger from './HYLogger';

const TAG: string = 'ClockSoundPlayer';

export const FLIP_CLOCK_PAGE_SOUND: string = 'sounds/flip_clock_page.wav';
export const ROUND_CLOCK_TICK_SOUND: string = 'sounds/round_clock_tick.wav';

class ClockSoundPlayer {
  private soundPoolPromise?: Promise<media.SoundPool>
  private soundIdPromises: Map<string, Promise<number>> = new Map()

  play(rawFilePath: string): void {
    if (!this.isEnabled()) {
      return
    }

    this.load(rawFilePath)
      .then(async (soundId: number) => {
        if (!this.isEnabled()) {
          return
        }
        const soundPool = await this.getSoundPool()
        await soundPool.play(soundId, {
          loop: 0,
          rate: audio.AudioRendererRate.RENDER_RATE_NORMAL,
          leftVolume: 1,
          rightVolume: 1,
          priority: 1
        })
      })
      .catch((error: BusinessError) => {
        HYLogger.warn(`${TAG} play ${rawFilePath} failed: ${JSON.stringify(error)}`)
      })
  }

  private isEnabled(): boolean {
    return AppStorage.get<boolean>('soundEnabled') !== false
  }

  private getSoundPool(): Promise<media.SoundPool> {
    if (this.soundPoolPromise) {
      return this.soundPoolPromise
    }

    const audioRendererInfo: audio.AudioRendererInfo = {
      usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
      rendererFlags: 1
    }

    this.soundPoolPromise = new Promise<media.SoundPool>((resolve, reject) => {
      media.createSoundPool(4, audioRendererInfo, (error: BusinessError, soundPool: media.SoundPool) => {
        if (error) {
          reject(error)
          return
        }
        resolve(soundPool)
      })
    })

    this.soundPoolPromise.catch(() => {
      this.soundPoolPromise = undefined
    })

    return this.soundPoolPromise
  }

  private load(rawFilePath: string): Promise<number> {
    const cachedSoundIdPromise = this.soundIdPromises.get(rawFilePath)
    if (cachedSoundIdPromise) {
      return cachedSoundIdPromise
    }

    const soundIdPromise = this.loadRawFile(rawFilePath)
    this.soundIdPromises.set(rawFilePath, soundIdPromise)
    soundIdPromise.catch(() => {
      this.soundIdPromises.delete(rawFilePath)
    })
    return soundIdPromise
  }

  private async loadRawFile(rawFilePath: string): Promise<number> {
    const soundPool = await this.getSoundPool()
    const context = getContext()
    const fileDescriptor = await context.resourceManager.getRawFd(rawFilePath)
    try {
      return await soundPool.load(fileDescriptor.fd, fileDescriptor.offset, fileDescriptor.length)
    } finally {
      try {
        await context.resourceManager.closeRawFd(rawFilePath)
      } catch (error) {
        HYLogger.warn(`${TAG} close raw fd ${rawFilePath} failed: ${JSON.stringify(error)}`)
      }
    }
  }
}

export default new ClockSoundPlayer();
