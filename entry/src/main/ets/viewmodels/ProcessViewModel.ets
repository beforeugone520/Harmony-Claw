import { Process, ProcessStatus } from '../models/Process';
import { getProcessRepository } from '../repositories/ProcessRepository';

export class ProcessViewModel {
  private repository = getProcessRepository();

  processes: Process[] = [];
  isLoading: boolean = false;
  isTerminating: boolean = false;
  errorMessage: string = '';

  async initialize(): Promise<void> {
    try {
      await this.loadProcesses();
    } catch (e) {
      console.error(`[ProcessViewModel] Initialize failed: ${JSON.stringify(e)}`);
      this.processes = [];
    }
  }

  async loadProcesses(): Promise<void> {
    this.isLoading = true;
    try {
      this.processes = await this.repository.getProcesses();
    } catch (e) {
      console.error(`[ProcessViewModel] Failed to load processes: ${JSON.stringify(e)}`);
      this.processes = [];
    } finally {
      this.isLoading = false;
    }
  }

  async refresh(): Promise<void> {
    try {
      await this.loadProcesses();
    } catch (e) {
      console.error(`[ProcessViewModel] Refresh failed: ${JSON.stringify(e)}`);
    }
  }

  async terminateProcess(id: string): Promise<boolean> {
    this.isTerminating = true;
    this.errorMessage = '';
    try {
      const success = await this.repository.terminateProcess(id);
      if (success) {
        const index = this.processes.findIndex(p => p.id === id);
        if (index >= 0) {
          this.processes[index].status = ProcessStatus.STOPPED;
        }
        return true;
      } else {
        this.errorMessage = '终止进程失败';
        return false;
      }
    } finally {
      this.isTerminating = false;
    }
  }

  getRunningCount(): number {
    return this.processes.filter(p => p.status === ProcessStatus.RUNNING).length;
  }

  getTotalCpuUsage(): number {
    let sum = 0;
    for (let i = 0; i < this.processes.length; i++) {
      sum += this.processes[i].cpu;
    }
    return sum;
  }

  getTotalMemoryUsage(): number {
    let sum = 0;
    for (let i = 0; i < this.processes.length; i++) {
      sum += this.processes[i].memory;
    }
    return sum;
  }
}
