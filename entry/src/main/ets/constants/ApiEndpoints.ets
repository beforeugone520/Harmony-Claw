/**
 * API Endpoints Constants
 * OpenClaw Gateway API endpoints
 */

export class ApiEndpoints {
  // Base paths
  static readonly BASE_API = '/api/v1';
  
  // Gateway endpoints
  static readonly GATEWAY_INFO = `${ApiEndpoints.BASE_API}/info`;
  static readonly GATEWAY_STATUS = `${ApiEndpoints.BASE_API}/status`;
  static readonly GATEWAY_HEALTH = `${ApiEndpoints.BASE_API}/health`;
  
  // Chat endpoints
  static readonly CHAT_SESSIONS = `${ApiEndpoints.BASE_API}/sessions`;
  static readonly CHAT_MESSAGES = `${ApiEndpoints.BASE_API}/messages`;
  static readonly CHAT_SEND = `${ApiEndpoints.BASE_API}/chat`;
  static readonly CHAT_STREAM = `${ApiEndpoints.BASE_API}/chat/stream`;
  
  // Process endpoints
  static readonly PROCESSES = `${ApiEndpoints.BASE_API}/processes`;
  static readonly PROCESS_TERMINATE = `${ApiEndpoints.BASE_API}/processes/{id}/terminate`;
  
  // Default port for OpenClaw gateway
  static readonly DEFAULT_PORT = 8333;
}
