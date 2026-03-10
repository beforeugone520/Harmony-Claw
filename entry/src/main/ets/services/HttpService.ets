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

export class HttpService {
  private baseUrl: string = '';
  private timeout: number = 10000;

  setBaseUrl(url: string): void {
    console.log(`[HttpService] Base URL set to: ${url}`);
    this.baseUrl = url;
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

      httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        connectTimeout: this.timeout,
        readTimeout: this.timeout
      }, (err, data) => {
        if (err) {
          console.error(`[HttpService] GET Error: ${err.code} - ${err.message}`);
          reject({ code: err.code, message: err.message, data: null as T });
        } else {
          console.log(`[HttpService] GET Success: ${data.responseCode}`);
          try {
            const result = JSON.parse(data.result.toString()) as HttpResponse<T>;
            resolve(result);
          } catch (e) {
            resolve({ code: 200, data: data.result as T, message: 'success' });
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

      httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        extraData: JSON.stringify(body),
        connectTimeout: this.timeout,
        readTimeout: this.timeout
      }, (err, data) => {
        if (err) {
          reject({ code: err.code, message: err.message, data: null as T });
        } else {
          try {
            const result = JSON.parse(data.result.toString()) as HttpResponse<T>;
            resolve(result);
          } catch (e) {
            resolve({ code: 200, data: data.result as T, message: 'success' });
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

      httpRequest.request(url, {
        method: http.RequestMethod.DELETE,
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        connectTimeout: this.timeout,
        readTimeout: this.timeout
      }, (err, data) => {
        if (err) {
          reject({ code: err.code, message: err.message, data: null as T });
        } else {
          try {
            const result = JSON.parse(data.result.toString()) as HttpResponse<T>;
            resolve(result);
          } catch (e) {
            resolve({ code: 200, data: data.result as T, message: 'success' });
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
