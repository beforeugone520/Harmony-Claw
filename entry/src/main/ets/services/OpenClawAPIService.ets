/**
 * OpenClaw API Service
 * 统一封装 OpenClaw 后端 API 调用
 */

import { getHttpService, HttpResponse } from './HttpService';
import { ApiEndpoints } from '../constants/ApiEndpoints';
import {
  Gateway,
  GatewayConfig,
  GatewayStats,
  GatewayFilter,
  GatewaySort
} from '../models/Gateway';
import { Session, SessionFilter, SessionSummary } from '../models/Session';
import { Message, MessageFilter, MessageStats } from '../models/Message';
import { Process, ProcessFilter, ProcessStats } from '../models/Process';
import {
  APIResponse,
  PaginatedResponse,
  PaginationParams,
  CreateGatewayRequest,
  UpdateGatewayRequest,
  CreateSessionRequest,
  UpdateSessionRequest,
  SendMessageRequest,
  CreateProcessRequest,
  UpdateProcessRequest,
  ProcessActionRequest,
  SystemStatusResponse,
  SystemMetricsRequest,
  SystemMetricsResponse,
  ConfigResponse,
  ConfigListResponse,
  UpdateConfigRequest
} from '../api/OpenClawAPI';

export class OpenClawAPIService {
  private http = getHttpService();

  // ============================================
  // Gateway API
  // ============================================

  async getGatewayInfo(): Promise<APIResponse<Gateway>> {
    return await this.http.get<Gateway>(ApiEndpoints.GATEWAY_INFO);
  }

  async getGatewayStatus(): Promise<APIResponse<{
    status: string;
    uptime: number;
    version: string;
    timestamp: number;
  }>> {
    return await this.http.get(ApiEndpoints.GATEWAY_STATUS);
  }

  async healthCheck(): Promise<APIResponse<{ healthy: boolean; responseTime: number }>> {
    return await this.http.get(ApiEndpoints.GATEWAY_HEALTH);
  }

  async listGateways(
    params?: PaginationParams & { filter?: GatewayFilter; sort?: GatewaySort }
  ): Promise<APIResponse<PaginatedResponse<Gateway>>> {
    return await this.http.get(ApiEndpoints.GATEWAY_INFO, params as Record<string, string>);
  }

  async createGateway(request: CreateGatewayRequest): Promise<APIResponse<Gateway>> {
    return await this.http.post(ApiEndpoints.GATEWAY_INFO, request);
  }

  async updateGateway(id: string, request: UpdateGatewayRequest): Promise<APIResponse<Gateway>> {
    return await this.http.post(`${ApiEndpoints.GATEWAY_INFO}/${id}`, request);
  }

  async deleteGateway(id: string): Promise<APIResponse<void>> {
    return await this.http.delete(`${ApiEndpoints.GATEWAY_INFO}/${id}`);
  }

  async getGatewayStats(id: string): Promise<APIResponse<GatewayStats>> {
    return await this.http.get(`${ApiEndpoints.GATEWAY_INFO}/${id}/stats`);
  }

  // ============================================
  // Session API
  // ============================================

  async listSessions(
    params?: PaginationParams & { filter?: SessionFilter }
  ): Promise<APIResponse<PaginatedResponse<Session>>> {
    return await this.http.get(ApiEndpoints.CHAT_SESSIONS, params as Record<string, string>);
  }

  async getSession(id: string): Promise<APIResponse<Session>> {
    return await this.http.get(`${ApiEndpoints.CHAT_SESSIONS}/${id}`);
  }

  async createSession(request: CreateSessionRequest): Promise<APIResponse<Session>> {
    return await this.http.post(ApiEndpoints.CHAT_SESSIONS, request);
  }

  async updateSession(id: string, request: UpdateSessionRequest): Promise<APIResponse<Session>> {
    return await this.http.post(`${ApiEndpoints.CHAT_SESSIONS}/${id}`, request);
  }

  async deleteSession(id: string): Promise<APIResponse<void>> {
    return await this.http.delete(`${ApiEndpoints.CHAT_SESSIONS}/${id}`);
  }

  async terminateSession(id: string, reason?: string): Promise<APIResponse<void>> {
    return await this.http.post(`${ApiEndpoints.CHAT_SESSIONS}/${id}/terminate`, { reason });
  }

  async getSessionSummary(id: string): Promise<APIResponse<SessionSummary>> {
    return await this.http.get(`${ApiEndpoints.CHAT_SESSIONS}/${id}/summary`);
  }

  // ============================================
  // Message API
  // ============================================

  async listMessages(
    params?: PaginationParams & { filter?: MessageFilter }
  ): Promise<APIResponse<PaginatedResponse<Message>>> {
    return await this.http.get(ApiEndpoints.CHAT_MESSAGES, params as Record<string, string>);
  }

  async getMessage(id: string): Promise<APIResponse<Message>> {
    return await this.http.get(`${ApiEndpoints.CHAT_MESSAGES}/${id}`);
  }

  async sendMessage(request: SendMessageRequest): Promise<APIResponse<Message>> {
    return await this.http.post(ApiEndpoints.CHAT_SEND, request);
  }

  async sendMessageStream(
    request: SendMessageRequest,
    onChunk: (chunk: string) => void
  ): Promise<void> {
    // TODO: Implement SSE streaming
    // For now, fallback to regular send
    const response = await this.sendMessage(request);
    if (response.data) {
      onChunk(response.data.content || '');
    }
  }

  async retryMessage(messageId: string, maxRetries?: number): Promise<APIResponse<Message>> {
    return await this.http.post(`${ApiEndpoints.CHAT_MESSAGES}/${messageId}/retry`, {
      maxRetries
    });
  }

  async getMessageStats(): Promise<APIResponse<MessageStats>> {
    return await this.http.get(`${ApiEndpoints.CHAT_MESSAGES}/stats`);
  }

  // ============================================
  // Process API
  // ============================================

  async listProcesses(
    params?: PaginationParams & { filter?: ProcessFilter }
  ): Promise<APIResponse<PaginatedResponse<Process>>> {
    return await this.http.get(ApiEndpoints.PROCESSES, params as Record<string, string>);
  }

  async getProcess(id: string): Promise<APIResponse<Process>> {
    return await this.http.get(`${ApiEndpoints.PROCESSES}/${id}`);
  }

  async createProcess(request: CreateProcessRequest): Promise<APIResponse<Process>> {
    return await this.http.post(ApiEndpoints.PROCESSES, request);
  }

  async updateProcess(id: string, request: UpdateProcessRequest): Promise<APIResponse<Process>> {
    return await this.http.post(`${ApiEndpoints.PROCESSES}/${id}`, request);
  }

  async deleteProcess(id: string): Promise<APIResponse<void>> {
    return await this.http.delete(`${ApiEndpoints.PROCESSES}/${id}`);
  }

  async executeProcessAction(
    id: string,
    request: ProcessActionRequest
  ): Promise<APIResponse<Process>> {
    return await this.http.post(`${ApiEndpoints.PROCESSES}/${id}/action`, request);
  }

  async terminateProcess(id: string, reason?: string): Promise<APIResponse<void>> {
    const path = ApiEndpoints.PROCESS_TERMINATE.replace('{id}', id);
    return await this.http.delete(path);
  }

  async restartProcess(id: string): Promise<APIResponse<Process>> {
    return await this.http.post(`${ApiEndpoints.PROCESSES}/${id}/restart`, {});
  }

  async getProcessStats(): Promise<APIResponse<ProcessStats>> {
    return await this.http.get(`${ApiEndpoints.PROCESSES}/stats`);
  }

  // ============================================
  // System API
  // ============================================

  async getSystemStatus(includeMetrics?: boolean): Promise<SystemStatusResponse> {
    const params = includeMetrics ? { includeMetrics: 'true' } : undefined;
    return await this.http.get('/api/v1/system/status', params);
  }

  async getSystemMetrics(request: SystemMetricsRequest): Promise<SystemMetricsResponse> {
    return await this.http.post('/api/v1/system/metrics', request);
  }

  // ============================================
  // Config API
  // ============================================

  async getConfig(namespace?: string, key?: string): Promise<ConfigListResponse> {
    const params: Record<string, string> = {};
    if (namespace) params.namespace = namespace;
    if (key) params.key = key;
    return await this.http.get('/api/v1/config', params);
  }

  async updateConfig(request: UpdateConfigRequest): Promise<ConfigResponse> {
    return await this.http.post('/api/v1/config', request);
  }

  async deleteConfig(namespace: string, key: string): Promise<APIResponse<void>> {
    return await this.http.delete(`/api/v1/config/${namespace}/${key}`);
  }
}

let instance: OpenClawAPIService | null = null;

export function getOpenClawAPIService(): OpenClawAPIService {
  if (!instance) {
    instance = new OpenClawAPIService();
  }
  return instance;
}
