/**
 * Network Utility Functions
 */

export class NetworkUtils {
  private static readonly IP_REGEX = /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;

  static isValidIp(ip: string): boolean {
    return this.IP_REGEX.test(ip);
  }

  static isValidPort(port: number): boolean {
    return port > 0 && port <= 65535;
  }

  static validateGatewayAddress(ip: string, port: number): { valid: boolean; message: string } {
    if (!ip || ip.trim() === '') {
      return { valid: false, message: 'IP 地址不能为空' };
    }

    if (!this.isValidIp(ip)) {
      return { valid: false, message: 'IP 地址格式不正确' };
    }

    if (!this.isValidPort(port)) {
      return { valid: false, message: '端口必须在 1-65535 之间' };
    }

    return { valid: true, message: '' };
  }

  static buildUrl(ip: string, port: number, path: string = ''): string {
    return `http://${ip}:${port}${path}`;
  }
}
