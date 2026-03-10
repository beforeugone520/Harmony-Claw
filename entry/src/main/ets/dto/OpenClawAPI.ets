export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

export interface GatewayInfo {
  id: string;
  name: string;
  version: string;
  status: string;
}

export interface SessionInfo {
  id: string;
  gatewayId: string;
  type: string;
  status: string;
}
