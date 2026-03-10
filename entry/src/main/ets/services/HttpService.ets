import { http } from '@kit.NetworkKit';
import { ApiEndpoints } from '../constants/ApiEndpoints';

export interface HttpResponse<T> {
  code: number;
  data: T;
  message: string;
}

interface ErrorWithCode {
  code?: number;
}

// API 返回的原始数据结构
class ApiResponseData {
  code?: number;
  data?: object;
  message?: string;

  constructor(obj?: object) {
    if (obj) {
      const o = obj as Record<string, object | number | string | undefined>;
      if (o.code !== undefined) this.code = o.code as number;
      if (o.data !== undefined) this.data = o.data as object;
      if (o.message !== undefined) this.message = o.message as string;
    }
  }

  hasCodeAndData(): boolean {
    return this.code !== undefined && this.data !== undefined;
  }
}

export class HttpService {
  private baseUrl: string = '';
  private timeout: number = 10000;
  private authToken: string = '';

  setBaseUrl(url: string): void {
    console.log(`[HttpService] Base URL set to: ${url}`);
    this.baseUrl = url;
  }

  setAuthToken(token: string): void {
    console.log(`[HttpService] Auth token set`);
    this.authToken = token;
  }

  getBaseUrl(): string {
    return this.baseUrl;
  }

  setTimeout(timeout: number): void {
    this.timeout = timeout;
  }

  private buildUrl(path: string): string {
    if (!this.baseUrl || this.baseUrl.length === 0) {
      console.error('[HttpService] Base URL is not set');
      return '';
    }
    return `${this.baseUrl}${path}`;
  }

  async get<T>(path: string, params?: Record<string, string>): Promise<HttpResponse<T>> {
    console.log(`[HttpService] GET ${path}`);
    return new Promise<HttpResponse<T>>((resolve, reject) => {
      const httpRequest = http.createHttp();
      let url = this.buildUrl(path);
      console.log(`[HttpService] Full URL: ${url}`);

      if (!url || url.length === 0) {
        reject({ code: -1, message: 'Base URL not set', data: null as T });
        return;
      }

      if (params) {
        const keys = Object.keys(params);
        if (keys.length > 0) {
          const queryParams = keys.map((key: string) => {
            return `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`;
          }).join('&');
          url += `?${queryParams}`;
        }
      }

      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };
      if (this.authToken) {
        headers['Authorization'] = `Bearer ${this.authToken}`;
      }

      httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: headers,
        connectTimeout: this.timeout,
        readTimeout: this.timeout
      }, (err, data) => {
        if (err) {
          console.error(`[HttpService] GET Error: ${err.code} - ${err.message}`);
          reject({ code: err.code, message: err.message, data: null as T });
        } else {
          console.log(`[HttpService] GET Success: ${data.responseCode}`);
          try {
            const jsonObj = JSON.parse(data.result.toString()) as object;
            const parsed = new ApiResponseData(jsonObj);
            // 检查是否已经是 { code, data, message } 格式
            if (parsed.hasCodeAndData()) {
              resolve({ code: parsed.code as number, data: parsed.data as T, message: parsed.message || 'success' });
            } else {
              // 包装为 HttpResponse 格式
              resolve({ code: data.responseCode, data: jsonObj as T, message: 'success' });
            }
          } catch (e) {
            // 不是 JSON，直接返回
            resolve({ code: data.responseCode, data: data.result as T, message: 'success' });
          }
        }
        httpRequest.destroy();
      });
    });
  }

  async post<T>(path: string, body: object): Promise<HttpResponse<T>> {
    console.log(`[HttpService] POST ${path}`);
    return new Promise<HttpResponse<T>>((resolve, reject) => {
      const httpRequest = http.createHttp();
      const url = this.buildUrl(path);
      console.log(`[HttpService] Full URL: ${url}`);

      if (!url || url.length === 0) {
        reject({ code: -1, message: 'Base URL not set', data: null as T });
        return;
      }

      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };
      if (this.authToken) {
        headers['Authorization'] = `Bearer ${this.authToken}`;
      }

      httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: JSON.stringify(body),
        connectTimeout: this.timeout,
        readTimeout: this.timeout
      }, (err, data) => {
        if (err) {
          reject({ code: err.code, message: err.message, data: null as T });
        } else {
          try {
            const jsonObj = JSON.parse(data.result.toString()) as object;
            const parsed = new ApiResponseData(jsonObj);
            if (parsed.hasCodeAndData()) {
              resolve({ code: parsed.code as number, data: parsed.data as T, message: parsed.message || 'success' });
            } else {
              resolve({ code: data.responseCode, data: jsonObj as T, message: 'success' });
            }
          } catch (e) {
            resolve({ code: data.responseCode, data: data.result as T, message: 'success' });
          }
        }
        httpRequest.destroy();
      });
    });
  }

  async delete<T>(path: string): Promise<HttpResponse<T>> {
    return new Promise<HttpResponse<T>>((resolve, reject) => {
      const httpRequest = http.createHttp();
      const url = this.buildUrl(path);

      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };
      if (this.authToken) {
        headers['Authorization'] = `Bearer ${this.authToken}`;
      }

      httpRequest.request(url, {
        method: http.RequestMethod.DELETE,
        header: headers,
        connectTimeout: this.timeout,
        readTimeout: this.timeout
      }, (err, data) => {
        if (err) {
          reject({ code: err.code, message: err.message, data: null as T });
        } else {
          try {
            const jsonObj = JSON.parse(data.result.toString()) as object;
            const parsed = new ApiResponseData(jsonObj);
            if (parsed.hasCodeAndData()) {
              resolve({ code: parsed.code as number, data: parsed.data as T, message: parsed.message || 'success' });
            } else {
              resolve({ code: data.responseCode, data: jsonObj as T, message: 'success' });
            }
          } catch (e) {
            resolve({ code: data.responseCode, data: data.result as T, message: 'success' });
          }
        }
        httpRequest.destroy();
      });
    });
  }

  async checkConnection(): Promise<boolean> {
    try {
      // Check root path as OpenClaw doesn't have a dedicated health endpoint
      const response = await this.get<object>('/');
      return response.code === 200 || response.code === 0;
    } catch (e) {
      // If we get any HTTP response, the server is running
      const error = e as ErrorWithCode;
      return error.code !== undefined && error.code > 0;
    }
  }
}

let instance: HttpService | null = null;

export function getHttpService(): HttpService {
  if (!instance) {
    instance = new HttpService();
  }
  return instance;
}
