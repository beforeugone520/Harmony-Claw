export enum ProcessStatus {
  RUNNING = 'running',
  STOPPED = 'stopped',
  ERROR = 'error',
  PENDING = 'pending'
}

export class Process {
  id: string = '';
  name: string = '';
  gatewayId: string = '';
  status: ProcessStatus = ProcessStatus.PENDING;
  pid: number = 0;
  cpu: number = 0;
  memory: number = 0;
  createdAt: number = Date.now();

  constructor(init?: Partial<Process>) {
    if (init) {
      if (init.id !== undefined) this.id = init.id;
      if (init.name !== undefined) this.name = init.name;
      if (init.gatewayId !== undefined) this.gatewayId = init.gatewayId;
      if (init.status !== undefined) this.status = init.status;
      if (init.pid !== undefined) this.pid = init.pid;
      if (init.cpu !== undefined) this.cpu = init.cpu;
      if (init.memory !== undefined) this.memory = init.memory;
      if (init.createdAt !== undefined) this.createdAt = init.createdAt;
    }
  }
}
