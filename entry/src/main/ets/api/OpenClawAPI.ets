/**
 * OpenClaw API DTOs
 * Request and response types for OpenClaw Gateway API
 */

import { Gateway, GatewayConfig, GatewayStats, GatewayFilter, GatewaySort } from '../models/Gateway';
import { Session, SessionFilter, SessionSummary } from '../models/Session';
import { Message, MessageFilter, MessageStats, MessageAggregation } from '../models/Message';
import { Process, ProcessFilter, ProcessStats } from '../models/Process';

// ============================================
// Common API Types
// ============================================

export interface PaginationParams {
  page: number;
  pageSize: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
  hasNext: boolean;
  hasPrev: boolean;
}

export interface APIError {
  code: string;
  message: string;
  details?: unknown;
  timestamp: number;
  path?: string;
}

export interface APIResponse<T> {
  success: boolean;
  data?: T;
  error?: APIError;
  meta?: {
    requestId: string;
    timestamp: number;
    duration: number;
  };
}

// ============================================
// Gateway API DTOs
// ============================================

// Requests
export interface CreateGatewayRequest {
  name: string;
  description: string;
  baseUrl: string;
  protocol: string;
  config: GatewayConfig;
  healthCheckUrl?: string;
  tags?: string[];
  priority?: number;
}

export interface UpdateGatewayRequest {
  name?: string;
  description?: string;
  baseUrl?: string;
  protocol?: string;
  config?: Partial<GatewayConfig>;
  isActive?: boolean;
  healthCheckUrl?: string;
  tags?: string[];
  priority?: number;
}

export interface ListGatewaysRequest extends PaginationParams {
  filter?: GatewayFilter;
  sort?: GatewaySort;
}

export interface HealthCheckRequest {
  gatewayId: string;
  timeout?: number;
}

// Responses
export type GatewayResponse = APIResponse<Gateway>;
export type GatewaysListResponse = APIResponse<PaginatedResponse<Gateway>>;
export type GatewayStatsResponse = APIResponse<GatewayStats>;

export interface HealthCheckResponse extends APIResponse<{
  gatewayId: string;
  healthy: boolean;
  responseTime: number;
  timestamp: number;
  details?: Record<string, unknown>;
}> {}

// ============================================
// Session API DTOs
// ============================================

// Requests
export interface CreateSessionRequest {
  gatewayId: string;
  userId?: string;
  type: string;
  context: {
    ipAddress: string;
    userAgent?: string;
    deviceId?: string;
    location?: string;
  };
  expiresIn?: number;  // seconds
  metadata?: Record<string, unknown>;
}

export interface UpdateSessionRequest {
  status?: string;
  metadata?: Record<string, unknown>;
}

export interface ListSessionsRequest extends PaginationParams {
  filter?: SessionFilter;
}

export interface TerminateSessionRequest {
  reason?: string;
}

// Responses
export type SessionResponse = APIResponse<Session>;
export type SessionsListResponse = APIResponse<PaginatedResponse<Session>>;
export type SessionSummaryResponse = APIResponse<SessionSummary>;

// ============================================
// Message API DTOs
// ============================================

// Requests
export interface SendMessageRequest {
  gatewayId: string;
  sessionId?: string;
  type: string;
  priority?: number;
  headers?: Record<string, string>;
  payload: unknown;
  parentId?: string;
  metadata?: Record<string, unknown>;
}

export interface ListMessagesRequest extends PaginationParams {
  filter?: MessageFilter;
}

export interface MessageAggregationRequest {
  gatewayId?: string;
  startTime: number;
  endTime: number;
  interval: '1m' | '5m' | '15m' | '1h' | '6h' | '1d';
}

export interface RetryMessageRequest {
  messageId: string;
  maxRetries?: number;
}

// Responses
export type MessageResponse = APIResponse<Message>;
export type MessagesListResponse = APIResponse<PaginatedResponse<Message>>;
export type MessageStatsResponse = APIResponse<MessageStats>;
export type MessageAggregationResponse = APIResponse<MessageAggregation[]>;

// ============================================
// Process API DTOs
// ============================================

// Requests
export interface CreateProcessRequest {
  gatewayId: string;
  name: string;
  description?: string;
  type: string;
  priority?: number;
  timeout?: number;
  steps?: string[];
  tags?: string[];
  metadata?: Record<string, unknown>;
}

export interface UpdateProcessRequest {
  status?: string;
  progress?: number;
}

export interface ListProcessesRequest extends PaginationParams {
  filter?: ProcessFilter;
}

export interface ProcessActionRequest {
  action: 'start' | 'pause' | 'resume' | 'cancel';
  reason?: string;
}

// Responses
export type ProcessResponse = APIResponse<Process>;
export type ProcessesListResponse = APIResponse<PaginatedResponse<Process>>;
export type ProcessStatsResponse = APIResponse<ProcessStats>;

// ============================================
// System API DTOs
// ============================================

export interface SystemStatusRequest {
  includeMetrics?: boolean;
  includeHealth?: boolean;
}

export interface SystemStatusResponse extends APIResponse<{
  version: string;
  status: 'healthy' | 'degraded' | 'unhealthy';
  uptime: number;
  timestamp: number;
  components: {
    name: string;
    status: 'up' | 'down' | 'warning';
    latency?: number;
    lastChecked: number;
  }[];
  metrics?: {
    totalRequests: number;
    requestsPerSecond: number;
    averageResponseTime: number;
    errorRate: number;
    cpuUsage: number;
    memoryUsage: number;
    activeConnections: number;
  };
}> {}

export interface SystemMetricsRequest {
  startTime: number;
  endTime: number;
  metrics: string[];
  interval?: string;
}

export interface SystemMetricsResponse extends APIResponse<{
  timeRange: {
    start: number;
    end: number;
  };
  metrics: {
    name: string;
    data: {
      timestamp: number;
      value: number;
    }[];
    aggregation: 'avg' | 'sum' | 'min' | 'max' | 'count';
  }[];
}> {}

// ============================================
// Configuration API DTOs
// ============================================

export interface GetConfigRequest {
  key?: string;
  namespace?: string;
}

export interface UpdateConfigRequest {
  key: string;
  value: unknown;
  namespace?: string;
}

export interface ConfigResponse extends APIResponse<{
  key: string;
  value: unknown;
  namespace: string;
  updatedAt: number;
  updatedBy?: string;
}> {}

export interface ConfigListResponse extends APIResponse<{
  namespace: string;
  configs: {
    key: string;
    value: unknown;
    updatedAt: number;
  }[];
}[]> {}

// ============================================
// WebSocket Events
// ============================================

export interface WebSocketMessage<T = unknown> {
  event: string;
  data: T;
  timestamp: number;
  id: string;
}

export type GatewayStatusEvent = WebSocketMessage<{
  gatewayId: string;
  oldStatus: string;
  newStatus: string;
  timestamp: number;
}>;

export type SessionEvent = WebSocketMessage<{
  sessionId: string;
  gatewayId: string;
  eventType: 'created' | 'updated' | 'terminated' | 'expired';
  session: Session;
}>;

export type MessageEvent = WebSocketMessage<{
  messageId: string;
  gatewayId: string;
  eventType: 'received' | 'processed' | 'failed' | 'retrying';
  message: Message;
}>;

export type ProcessEvent = WebSocketMessage<{
  processId: string;
  gatewayId: string;
  eventType: 'started' | 'progress' | 'completed' | 'failed' | 'cancelled';
  process: Process;
}>;

// ============================================
// API Client Configuration
// ============================================

export interface APIClientConfig {
  baseUrl: string;
  timeout: number;
  retries: number;
  retryDelay: number;
  headers?: Record<string, string>;
  enableLogging?: boolean;
  enableCache?: boolean;
}

export interface APIRequestConfig {
  timeout?: number;
  retries?: number;
  headers?: Record<string, string>;
  signal?: AbortSignal;
}

// ============================================
// Error Codes
// ============================================

export enum APIErrorCode {
  // General Errors
  UNKNOWN_ERROR = 'UNKNOWN_ERROR',
  INVALID_REQUEST = 'INVALID_REQUEST',
  UNAUTHORIZED = 'UNAUTHORIZED',
  FORBIDDEN = 'FORBIDDEN',
  NOT_FOUND = 'NOT_FOUND',
  RATE_LIMITED = 'RATE_LIMITED',
  SERVER_ERROR = 'SERVER_ERROR',
  SERVICE_UNAVAILABLE = 'SERVICE_UNAVAILABLE',
  
  // Gateway Errors
  GATEWAY_NOT_FOUND = 'GATEWAY_NOT_FOUND',
  GATEWAY_ALREADY_EXISTS = 'GATEWAY_ALREADY_EXISTS',
  GATEWAY_UNHEALTHY = 'GATEWAY_UNHEALTHY',
  GATEWAY_CONNECTION_FAILED = 'GATEWAY_CONNECTION_FAILED',
  
  // Session Errors
  SESSION_NOT_FOUND = 'SESSION_NOT_FOUND',
  SESSION_EXPIRED = 'SESSION_EXPIRED',
  SESSION_LIMIT_EXCEEDED = 'SESSION_LIMIT_EXCEEDED',
  
  // Message Errors
  MESSAGE_NOT_FOUND = 'MESSAGE_NOT_FOUND',
  MESSAGE_REJECTED = 'MESSAGE_REJECTED',
  MESSAGE_TIMEOUT = 'MESSAGE_TIMEOUT',
  INVALID_MESSAGE_FORMAT = 'INVALID_MESSAGE_FORMAT',
  
  // Process Errors
  PROCESS_NOT_FOUND = 'PROCESS_NOT_FOUND',
  PROCESS_ALREADY_RUNNING = 'PROCESS_ALREADY_RUNNING',
  PROCESS_EXECUTION_FAILED = 'PROCESS_EXECUTION_FAILED',
  PROCESS_TIMEOUT = 'PROCESS_TIMEOUT'
}
