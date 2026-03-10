import { Gateway, GatewayStatus } from '../models/Gateway';
import { getStorageService } from '../services/StorageService';
import { getOpenClawAPIService } from '../services/OpenClawAPIService';
import { getGatewayDiscoveryService, StatusCheckResult } from '../services/GatewayDiscoveryService';

export class GatewayRepository {
  private storage = getStorageService();
  private api = getOpenClawAPIService();
  private discovery = getGatewayDiscoveryService();

  async getAll(): Promise<Gateway[]> {
    return await this.storage.loadGateways();
  }

  private idCounter: number = 0;

  private generateId(): string {
    return `${Date.now()}_${++this.idCounter}_${Math.random().toString(36).substr(2, 9)}`;
  }

  async add(gateway: Gateway): Promise<Gateway> {
    const gateways = await this.getAll();
    const newGateway = new Gateway();
    newGateway.id = this.generateId();
    newGateway.name = gateway.name;
    newGateway.host = gateway.host;
    newGateway.port = gateway.port;
    newGateway.protocol = gateway.protocol;
    newGateway.status = gateway.status;
    newGateway.version = gateway.version;
    newGateway.lastSeen = gateway.lastSeen;
    newGateway.isFavorite = gateway.isFavorite;
    gateways.push(newGateway);
    await this.storage.saveGateways(gateways);
    return newGateway;
  }

  async update(gateway: Gateway): Promise<Gateway> {
    const gateways = await this.getAll();
    for (let i = 0; i < gateways.length; i++) {
      if (gateways[i].id === gateway.id) {
        gateways[i] = gateway;
        break;
      }
    }
    await this.storage.saveGateways(gateways);
    return gateway;
  }

  async delete(id: string): Promise<void> {
    const gateways = await this.getAll();
    const filtered: Gateway[] = [];
    for (let i = 0; i < gateways.length; i++) {
      if (gateways[i].id !== id) {
        filtered.push(gateways[i]);
      }
    }
    await this.storage.saveGateways(filtered);
  }

  async getById(id: string): Promise<Gateway | null> {
    const gateways = await this.getAll();
    for (let i = 0; i < gateways.length; i++) {
      if (gateways[i].id === id) {
        return gateways[i];
      }
    }
    return null;
  }

  async getCurrent(): Promise<Gateway | null> {
    const currentId = await this.storage.getCurrentGatewayId();
    if (!currentId) return null;
    return await this.getById(currentId);
  }

  async setCurrent(id: string): Promise<void> {
    await this.storage.saveCurrentGatewayId(id);
  }

  async validateConnection(gateway: Gateway): Promise<boolean> {
    return await this.discovery.validateGateway(gateway.host, gateway.port);
  }

  async checkStatus(gateway: Gateway): Promise<StatusCheckResult> {
    return await this.discovery.checkOnlineStatus(gateway);
  }

  async connect(gateway: Gateway): Promise<boolean> {
    const isValid = await this.validateConnection(gateway);
    if (isValid) {
      // Set base URL for all subsequent API calls
      const http = this.api['http']; // Access private http service
      if (http) {
        http.setBaseUrl(`http://${gateway.host}:${gateway.port}`);
      }
      await this.setCurrent(gateway.id);
    }
    return isValid;
  }

  setBaseUrl(url: string): void {
    const http = this.api['http'];
    if (http) {
      http.setBaseUrl(url);
    }
  }
}

let instance: GatewayRepository | null = null;

export function getGatewayRepository(): GatewayRepository {
  if (!instance) {
    instance = new GatewayRepository();
  }
  return instance;
}
