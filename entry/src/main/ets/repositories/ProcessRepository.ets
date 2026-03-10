import { Process, ProcessStatus } from '../models/Process';
import { getHttpService } from '../services/HttpService';
import { ApiEndpoints } from '../constants/ApiEndpoints';

export class ProcessRepository {
  private http = getHttpService();

  async getProcesses(): Promise<Process[]> {
    try {
      const response = await this.http.get<Process[]>(ApiEndpoints.PROCESSES);
      if (response.code === 200) {
        return response.data;
      }
    } catch (e) {
      // Return mock data on error
    }
    return this.getMockProcesses();
  }

  async getProcessDetail(id: string): Promise<Process | null> {
    try {
      const response = await this.http.get<Process>(`${ApiEndpoints.PROCESSES}/${id}`);
      if (response.code === 200) {
        return response.data;
      }
    } catch (e) {
      // Return null on error
    }
    return null;
  }

  async terminateProcess(id: string): Promise<boolean> {
    try {
      const path = ApiEndpoints.PROCESS_TERMINATE.replace('{id}', id);
      const response = await this.http.delete<Process>(path);
      return response.code === 200;
    } catch (e) {
      return false;
    }
  }

  private getMockProcesses(): Process[] {
    const p1 = new Process();
    p1.id = '1';
    p1.name = 'API Server';
    p1.gatewayId = '1';
    p1.status = ProcessStatus.RUNNING;
    p1.pid = 1234;
    p1.cpu = 15.5;
    p1.memory = 256;

    const p2 = new Process();
    p2.id = '2';
    p2.name = 'Worker Process';
    p2.gatewayId = '1';
    p2.status = ProcessStatus.RUNNING;
    p2.pid = 1235;
    p2.cpu = 8.2;
    p2.memory = 128;

    return [p1, p2];
  }
}

let instance: ProcessRepository | null = null;

export function getProcessRepository(): ProcessRepository {
  if (!instance) {
    instance = new ProcessRepository();
  }
  return instance;
}
