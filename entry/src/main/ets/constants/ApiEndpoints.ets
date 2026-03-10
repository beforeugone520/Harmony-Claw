/**
 * API Endpoints Constants
 * OpenClaw Gateway API endpoints
 */

/**
 * OpenClaw Gateway API Endpoints
 *
 * OpenClaw 配置:
 * - 端口: 18789
 * - 认证: Token (ollama)
 * - 模式: local
 */
export class ApiEndpoints {
  // OpenClaw Bridge 配置 (Harmony-Claw Bridge Server)
  static readonly DEFAULT_HOST = 'localhost';
  static readonly DEFAULT_PORT = 8333;
  static readonly AUTH_TOKEN = 'ollama';

  // OpenClaw Control UI 端口
  static readonly CONTROL_UI_PORT = 18789;

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

  // Agent endpoints (OpenClaw specific)
  static readonly AGENTS = `${ApiEndpoints.BASE_API}/agents`;
  static readonly AGENT_SEND = `${ApiEndpoints.BASE_API}/agents/{id}/send`;
}
