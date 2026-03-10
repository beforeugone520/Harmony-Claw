import { http } from '@kit.NetworkKit';
import { ApiEndpoints } from '../constants/ApiEndpoints';
import { Gateway, GatewayStatus } from '../models/Gateway';

export interface DiscoveredGateway {
  ip: string;
  port: number;
  info?: Gateway;
}

export interface StatusCheckResult {
  status: GatewayStatus;
  error?: string;
}

export class GatewayDiscoveryService {
  private timeout: number = 3000;

  async validateGateway(ip: string, port: number): Promise<boolean> {
    return new Promise<boolean>((resolve) => {
      const httpRequest = http.createHttp();
      const url = `http://${ip}:${port}`;
      console.log(`[Discovery] Testing: ${url}`);

      httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: this.timeout,
        readTimeout: this.timeout
      }, (err, data) => {
        if (err) {
          console.error(`[Discovery] Connection failed: ${err.code} - ${err.message}`);
          resolve(false);
        } else {
          // OpenClaw returns HTML SPA page with 200 status when running
          // Check if response contains OpenClaw title or just accept HTTP 200
          try {
            const responseText = data.result?.toString() || '';
            const isOpenClaw = responseText.includes('OpenClaw') ||
                              responseText.includes('openclaw');
            console.log(`[Discovery] Response received, isOpenClaw: ${isOpenClaw}, length: ${responseText.length}`);
            resolve(true); // Any successful HTTP response means server is running
          } catch (e) {
            console.error(`[Discovery] Error processing response: ${JSON.stringify(e)}`);
            resolve(false);
          }
        }
        httpRequest.destroy();
      });
    });
  }

  async scanNetwork(startIp: string, endIp: string, port: number = ApiEndpoints.DEFAULT_PORT): Promise<DiscoveredGateway[]> {
    const results: DiscoveredGateway[] = [];
    const start = this.ipToNumber(startIp);
    const end = this.ipToNumber(endIp);

    const promises: Promise<void>[] = [];

    for (let i = start; i <= end && i <= start + 50; i++) {
      const ip = this.numberToIp(i);
      const promise = this.validateGateway(ip, port).then((isValid: boolean) => {
        if (isValid) {
          const discovered: DiscoveredGateway = { ip: ip, port: port };
          results.push(discovered);
        }
      });
      promises.push(promise);
    }

    await Promise.all(promises);
    return results;
  }

  async checkOnlineStatus(gateway: Gateway): Promise<StatusCheckResult> {
    try {
      const isOnline = await this.validateGateway(gateway.host, gateway.port);
      const result: StatusCheckResult = { 
        status: isOnline ? GatewayStatus.ONLINE : GatewayStatus.OFFLINE,
        error: isOnline ? undefined : '无法连接到网关'
      };
      return result;
    } catch (e) {
      const result: StatusCheckResult = { 
        status: GatewayStatus.OFFLINE, 
        error: `检测失败: ${JSON.stringify(e)}` 
      };
      return result;
    }
  }

  private ipToNumber(ip: string): number {
    const parts = ip.split('.');
    return (parseInt(parts[0]) << 24) + (parseInt(parts[1]) << 16) + (parseInt(parts[2]) << 8) + parseInt(parts[3]);
  }

  private numberToIp(num: number): string {
    return [
      (num >>> 24) & 0xFF,
      (num >>> 16) & 0xFF,
      (num >>> 8) & 0xFF,
      num & 0xFF
    ].join('.');
  }
}

let instance: GatewayDiscoveryService | null = null;

export function getGatewayDiscoveryService(): GatewayDiscoveryService {
  if (!instance) {
    instance = new GatewayDiscoveryService();
  }
  return instance;
}
