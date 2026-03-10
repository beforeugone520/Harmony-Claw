import { getHttpService } from './HttpService';
import { Gateway } from '../models/Gateway';

/**
 * OpenClaw API Service
 * Manages connection to OpenClaw Bridge Server and provides API access
 */
export class OpenClawAPIService {
  private http = getHttpService();
  private currentGateway: Gateway | null = null;

  /**
   * Set the current gateway for API calls
   */
  setGateway(gateway: Gateway): void {
    this.currentGateway = gateway;
    const baseUrl = `http://${gateway.host}:${gateway.port}`;
    this.http.setBaseUrl(baseUrl);
    console.log(`[OpenClawAPIService] Gateway set to ${baseUrl}`);
  }

  /**
   * Get current gateway
   */
  getCurrentGateway(): Gateway | null {
    return this.currentGateway;
  }

  /**
   * Check if a gateway is connected
   */
  isConnected(): boolean {
    return this.currentGateway !== null;
  }

  /**
   * Get the HTTP service configured for the current gateway
   */
  getHttpService() {
    return this.http;
  }

  /**
   * Clear current gateway connection
   */
  disconnect(): void {
    this.currentGateway = null;
    console.log('[OpenClawAPIService] Disconnected');
  }
}

let instance: OpenClawAPIService | null = null;

export function getOpenClawAPIService(): OpenClawAPIService {
  if (!instance) {
    instance = new OpenClawAPIService();
  }
  return instance;
}
