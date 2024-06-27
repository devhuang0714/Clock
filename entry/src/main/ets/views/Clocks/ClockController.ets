export interface ClockListener {
  onUpdate: (date: Date) => void
}

export class ClockController {
  private listeners: ClockListener[] = []

  registerListener(listener: ClockListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  unregisterListener(listener: ClockListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  public update(date: Date) {
    this.listeners.forEach(listener => {
      listener.onUpdate(date);
    })
  }
}