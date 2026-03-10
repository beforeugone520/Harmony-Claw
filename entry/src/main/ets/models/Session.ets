export enum SessionStatus {
  ACTIVE = 'active',
  CLOSED = 'closed',
  ERROR = 'error'
}

export enum SessionType {
  WEB = 'web',
  API = 'api',
  CLI = 'cli'
}

export class Session {
  id: string = '';
  gatewayId: string = '';
  title: string = '';
  type: SessionType = SessionType.WEB;
  status: SessionStatus = SessionStatus.ACTIVE;
  createdAt: number = Date.now();

  constructor(init?: Partial<Session>) {
    if (init) {
      if (init.id !== undefined) this.id = init.id;
      if (init.gatewayId !== undefined) this.gatewayId = init.gatewayId;
      if (init.title !== undefined) this.title = init.title;
      if (init.type !== undefined) this.type = init.type;
      if (init.status !== undefined) this.status = init.status;
      if (init.createdAt !== undefined) this.createdAt = init.createdAt;
    }
  }
}
