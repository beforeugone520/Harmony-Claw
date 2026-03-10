export enum LogLevel {
  DEBUG = 'debug',
  INFO = 'info',
  WARN = 'warn',
  ERROR = 'error'
}

export class LogEntry {
  id: string = '';
  level: LogLevel = LogLevel.INFO;
  message: string = '';
  source: string = '';
  timestamp: number = Date.now();

  constructor(init?: Partial<LogEntry>) {
    if (init) {
      Object.assign(this, init);
    }
  }
}
