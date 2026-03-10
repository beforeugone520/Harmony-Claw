import { Process, ProcessStatus } from '../models/Process';
import { getOpenClawAPIService } from '../services/OpenClawAPIService';
import { ApiEndpoints } from '../constants/ApiEndpoints';

class ProcessApiData {
  id: string = '';
  name: string = '';
  gatewayId: string = '';
  status: string = 'running';
  pid: number = 0;
  cpu: number = 0;
  memory: number = 0;
  command?: string = '';
  createdAt: number = Date.now();
}

class RestartRequest {
  force: boolean = false;
}

export class ProcessRepository {
  private apiService = getOpenClawAPIService();

  private get http() {
    return this.apiService.getHttpService();
  }

  async getProcesses(): Promise<Process[]> {
    if (!this.apiService.isConnected()) {
      console.log('[ProcessRepository] No gateway connected, using mock data');
      return this.getMockProcesses();
    }

    try {
      console.log('[ProcessRepository] Fetching processes from API...');
      const response = await this.http.get<ProcessApiData[]>(ApiEndpoints.PROCESSES);
      console.log('[ProcessRepository] Process response code:', response.code);

      if (!response.data) {
        console.log('[ProcessRepository] No data in response');
        return this.getMockProcesses();
      }

      const responseData = response.data;

      // 如果是数组直接返回
      if (Array.isArray(responseData)) {
        const processes = this.parseProcesses(responseData);
        console.log(`[ProcessRepository] Loaded ${processes.length} processes (direct array)`);
        return processes;
      }

      // 如果是包装格式，尝试提取 data 字段
      const extracted = this.extractArrayFromResponse(responseData);
      if (extracted !== null) {
        const processes = this.parseProcesses(extracted);
        console.log(`[ProcessRepository] Loaded ${processes.length} processes (wrapped)`);
        return processes;
      }

      console.log('[ProcessRepository] Unrecognized response format');
    } catch (e) {
      console.error('[ProcessRepository] Failed to get processes:', e);
    }

    return this.getMockProcesses();
  }

  async getProcessDetail(id: string): Promise<Process | null> {
    if (!this.apiService.isConnected()) {
      return this.getMockProcessById(id);
    }

    try {
      const response = await this.http.get<ProcessApiData>(`${ApiEndpoints.PROCESSES}/${id}`);
      if ((response.code === 200 || response.code === 0) && response.data) {
        const responseData = response.data;

        // 尝试提取包装的数据
        const extracted = this.extractSingleFromResponse(responseData);
        if (extracted !== null) {
          return this.parseProcess(extracted);
        }

        return this.parseProcess(responseData);
      }
    } catch (e) {
      console.error(`[ProcessRepository] Failed to get process detail for ${id}:`, e);
    }

    return this.getMockProcessById(id);
  }

  async restartProcess(id: string): Promise<boolean> {
    if (!this.apiService.isConnected()) {
      console.warn('[ProcessRepository] No gateway connected');
      return false;
    }

    try {
      const path = `${ApiEndpoints.PROCESSES}/${id}/restart`;
      const body = new RestartRequest();
      const response = await this.http.post<ProcessApiData>(path, body);
      return response.code === 200 || response.code === 0;
    } catch (e) {
      console.error(`[ProcessRepository] Failed to restart process ${id}:`, e);
      return false;
    }
  }

  async terminateProcess(id: string): Promise<boolean> {
    if (!this.apiService.isConnected()) {
      console.warn('[ProcessRepository] No gateway connected');
      return false;
    }

    try {
      const path = ApiEndpoints.PROCESS_TERMINATE.replace('{id}', id);
      const response = await this.http.delete<ProcessApiData>(path);
      return response.code === 200 || response.code === 0;
    } catch (e) {
      console.error(`[ProcessRepository] Failed to terminate process ${id}:`, e);
      return false;
    }
  }

  // 从响应中提取数组 - 使用 JSON 解析避免类型问题
  private extractArrayFromResponse(responseData: object): ProcessApiData[] | null {
    try {
      const jsonStr = JSON.stringify(responseData);
      interface DataWrapper {
        data?: ProcessApiData[];
      }
      const parsed: DataWrapper = JSON.parse(jsonStr) as DataWrapper;
      const dataValue = parsed.data;
      if (dataValue !== undefined && Array.isArray(dataValue)) {
        return dataValue;
      }
    } catch {
      // 解析失败，返回 null
    }
    return null;
  }

  // 从响应中提取单个对象
  private extractSingleFromResponse(responseData: object): ProcessApiData | null {
    try {
      const jsonStr = JSON.stringify(responseData);
      interface DataWrapper {
        data?: ProcessApiData;
      }
      const parsed: DataWrapper = JSON.parse(jsonStr) as DataWrapper;
      const dataValue = parsed.data;
      if (dataValue !== undefined && dataValue !== null && typeof dataValue === 'object' && !Array.isArray(dataValue)) {
        return dataValue;
      }
    } catch {
      // 解析失败，返回 null
    }
    return null;
  }

  private parseProcesses(data: ProcessApiData[]): Process[] {
    const processes: Process[] = [];
    for (const item of data) {
      processes.push(this.parseProcess(item));
    }
    return processes;
  }

  private parseProcess(data: ProcessApiData): Process {
    const process = new Process();
    process.id = data.id;
    process.name = data.name;
    process.gatewayId = data.gatewayId;
    process.status = this.mapStatus(data.status);
    process.pid = data.pid;
    process.cpu = data.cpu || 0;
    process.memory = data.memory || 0;
    process.createdAt = data.createdAt || Date.now();
    return process;
  }

  private mapStatus(status: string): ProcessStatus {
    switch (status.toLowerCase()) {
      case 'running':
        return ProcessStatus.RUNNING;
      case 'stopped':
        return ProcessStatus.STOPPED;
      case 'error':
        return ProcessStatus.ERROR;
      case 'pending':
        return ProcessStatus.PENDING;
      default:
        return ProcessStatus.RUNNING;
    }
  }

  private getMockProcessById(id: string): Process | null {
    const allProcesses = this.getMockProcesses();
    return allProcesses.find(p => p.id === id) || null;
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
