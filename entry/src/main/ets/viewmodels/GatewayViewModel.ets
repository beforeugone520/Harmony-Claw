import { Gateway, GatewayStatus } from '../models/Gateway';
import { getGatewayRepository } from '../repositories/GatewayRepository';
import { getGatewayDiscoveryService, DiscoveredGateway, StatusCheckResult } from '../services/GatewayDiscoveryService';

export class GatewayViewModel {
  private repository = getGatewayRepository();
  private discovery = getGatewayDiscoveryService();

  gateways: Gateway[] = [];
  isLoading: boolean = false;
  isScanning: boolean = false;
  scanProgress: number = 0;
  currentGateway: Gateway | null = null;
  errorMessage: string = '';

  async initialize(): Promise<void> {
    this.isLoading = true;
    try {
      this.gateways = await this.repository.getAll();
      this.currentGateway = await this.repository.getCurrent();
    } catch (e) {
      console.error(`[GatewayViewModel] Initialize failed: ${JSON.stringify(e)}`);
      this.gateways = [];
      this.currentGateway = null;
    } finally {
      this.isLoading = false;
    }
  }

  async refresh(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      // 直接操作当前内存中的网关列表，避免从 storage 重新加载导致覆盖
      const updatedGateways: Gateway[] = [];
      for (let i = 0; i < this.gateways.length; i++) {
        const gateway = new Gateway(this.gateways[i]);
        try {
          const result = await this.repository.checkStatus(gateway);
          gateway.status = result.status;
          gateway.lastSeen = Date.now();
          if (result.error && i === 0) {
            this.errorMessage = result.error;
          }
        } catch (e) {
          console.error(`[GatewayViewModel] Failed to check status for gateway ${gateway?.id}: ${JSON.stringify(e)}`);
          gateway.status = GatewayStatus.ERROR;
        }
        updatedGateways.push(gateway);
        // 更新 storage 中的状态
        await this.repository.update(gateway);
      }
      this.gateways = updatedGateways;
    } catch (e) {
      console.error(`[GatewayViewModel] Refresh failed: ${JSON.stringify(e)}`);
      this.errorMessage = '刷新失败';
    } finally {
      this.isLoading = false;
    }
  }

  async checkGatewayStatus(gateway: Gateway): Promise<StatusCheckResult> {
    return await this.repository.checkStatus(gateway);
  }

  async updateGatewayStatus(gateway: Gateway, status: GatewayStatus): Promise<void> {
    // 创建新的网关对象替代直接修改，避免响应式冲突
    const index = this.gateways.findIndex(g => g.id === gateway.id);
    if (index !== -1) {
      const updatedGateway = new Gateway(this.gateways[index]);
      updatedGateway.status = status;
      this.gateways[index] = updatedGateway;
      // 如果当前选中的网关被更新，也更新 currentGateway
      if (this.currentGateway?.id === gateway.id) {
        this.currentGateway = updatedGateway;
      }
    }
  }

  async addGateway(gateway: Gateway, skipValidation: boolean = false): Promise<boolean> {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      if (!skipValidation) {
        console.log(`[GatewayViewModel] Testing ${gateway.host}:${gateway.port}`);
        const isValid = await this.repository.validateConnection(gateway);
        if (!isValid) {
          this.errorMessage = `无法连接到 ${gateway.host}:${gateway.port}`;
          return false;
        }
      }

      // 如果验证通过，设置状态为在线
      if (!skipValidation) {
        gateway.status = GatewayStatus.ONLINE;
        gateway.lastSeen = Date.now();
      }

      const newGateway = await this.repository.add(gateway);
      this.gateways.push(newGateway);
      return true;
    } catch (e) {
      this.errorMessage = '添加网关失败';
      return false;
    } finally {
      this.isLoading = false;
    }
  }

  async deleteGateway(id: string): Promise<void> {
    await this.repository.delete(id);
    this.gateways = this.gateways.filter(g => g.id !== id);
  }

  async connectGateway(gateway: Gateway): Promise<boolean> {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      const success = await this.repository.connect(gateway);
      if (success) {
        this.currentGateway = gateway;
        gateway.status = GatewayStatus.ONLINE;
        await this.repository.update(gateway);
        return true;
      } else {
        this.errorMessage = '连接失败';
        return false;
      }
    } finally {
      this.isLoading = false;
    }
  }

  async scanNetwork(startIp: string = '192.168.1.1', endIp: string = '192.168.1.254'): Promise<DiscoveredGateway[]> {
    this.isScanning = true;
    this.scanProgress = 0;
    try {
      const discovered = await this.discovery.scanNetwork(startIp, endIp);
      return discovered;
    } finally {
      this.isScanning = false;
      this.scanProgress = 100;
    }
  }

  getOnlineCount(): number {
    return this.gateways.filter(g => g.status === GatewayStatus.ONLINE).length;
  }

  getTotalCount(): number {
    return this.gateways.length;
  }
}
