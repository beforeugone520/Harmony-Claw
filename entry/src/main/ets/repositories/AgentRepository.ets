import { Agent, AgentStatus, AgentType, AgentSession, AgentMessage, AgentMetrics } from '../models/Agent';
import { getOpenClawAPIService } from '../services/OpenClawAPIService';
import { ApiEndpoints } from '../constants/ApiEndpoints';

// API 响应类型
class ApiResponse<T> {
  data: T | null = null;
  total: number = 0;
  error: string = '';
}

class AgentListResponse {
  data: Agent[] = [];
  total: number = 0;
}

class AgentApiData {
  id: string = '';
  name: string = '';
  type: string = '';
  status: string = '';
  workspace: string = '';
  isActive: boolean = false;
  lastActivityAt: number | null = null;
  identity: AgentIdentityData | null = null;
}

class AgentIdentityData {
  name: string = '';
  emoji: string = '';
  theme: string = '';
}

class StatusApiResponse {
  data: StatusData | null = null;
}

class StatusData {
  agentId: string = '';
  status: string = '';
  timestamp: number = 0;
}

class MetricsApiResponse {
  data: AgentMetrics | null = null;
}

class SendMessageResponse {
  data: MessageData | null = null;
}

class MessageData {
  messageId: string = '';
  agentId: string = '';
  content: string = '';
  timestamp: number = 0;
}

export class AgentRepository {
  private apiService = getOpenClawAPIService();

  private get http() {
    return this.apiService.getHttpService();
  }

  // 从 Bridge Server 获取 Agent 列表
  async getAgents(): Promise<Agent[]> {
    try {
      const response = await this.http.get<AgentListResponse>(ApiEndpoints.AGENTS);
      if (response.code === 200 && response.data) {
        return this.parseAgents(response.data.data);
      }
    } catch (e) {
      console.error('[AgentRepository] Failed to get agents from API:', e);
    }
    return [];
  }

  async getAgentById(id: string): Promise<Agent | null> {
    try {
      const path = `${ApiEndpoints.AGENTS}/${id}`;
      const response = await this.http.get<ApiResponse<AgentApiData>>(path);
      if (response.code === 200 && response.data && response.data.data) {
        return this.parseAgent(response.data.data);
      }
    } catch (e) {
      console.error(`[AgentRepository] Failed to get agent ${id}:`, e);
    }
    return null;
  }

  async checkAgentStatus(agentId: string): Promise<AgentStatus> {
    try {
      const path = `${ApiEndpoints.AGENTS}/${agentId}/status`;
      const response = await this.http.get<StatusApiResponse>(path);
      if (response.code === 200 && response.data && response.data.data) {
        return this.mapStatus(response.data.data.status);
      }
    } catch (e) {
      console.warn(`[AgentRepository] Failed to check status for ${agentId}:`, e);
    }
    return AgentStatus.IDLE;
  }

  async sendMessageToAgent(agentId: string, content: string): Promise<AgentMessage | null> {
    try {
      const path = ApiEndpoints.AGENT_SEND.replace('{id}', agentId);

      class SendBody {
        message: string = '';
      }
      const body = new SendBody();
      body.message = content;

      const response = await this.http.post<SendMessageResponse>(path, body);

      if (response.code === 200 && response.data && response.data.data) {
        const msg = new AgentMessage();
        msg.id = response.data.data.messageId;
        msg.sessionId = '';
        msg.agentId = agentId;
        msg.role = 'agent';
        msg.content = response.data.data.content;
        msg.timestamp = response.data.data.timestamp;
        return msg;
      }
    } catch (e) {
      console.error(`[AgentRepository] Failed to send message to ${agentId}:`, e);
    }
    return null;
  }

  async getAgentSessions(agentId: string): Promise<AgentSession[]> {
    // TODO: 从 Bridge Server 获取会话列表
    return [];
  }

  async getAgentMetrics(agentId: string): Promise<AgentMetrics | undefined> {
    try {
      const path = `${ApiEndpoints.AGENTS}/${agentId}/metrics`;
      const response = await this.http.get<MetricsApiResponse>(path);
      if (response.code === 200 && response.data && response.data.data) {
        return response.data.data;
      }
    } catch (e) {
      console.warn(`[AgentRepository] Failed to get metrics for ${agentId}:`, e);
    }
    return this.getMockMetrics(agentId);
  }

  private parseAgents(data: AgentApiData[]): Agent[] {
    const agents: Agent[] = [];
    for (const item of data) {
      const agent = this.parseAgent(item);
      agents.push(agent);
    }
    return agents;
  }

  private parseAgent(data: AgentApiData): Agent {
    const agent = new Agent();
    agent.id = data.id;
    agent.name = data.name;
    agent.workspace = data.workspace;
    agent.status = this.mapStatus(data.status);
    agent.type = this.mapAgentType(data.type);
    agent.isActive = data.isActive;

    if (data.identity) {
      agent.identity = {
        name: data.identity.name,
        emoji: data.identity.emoji,
        theme: data.identity.theme
      };
    }

    return agent;
  }

  private mapAgentType(type: string): AgentType {
    if (type === 'main') return AgentType.MAIN;
    if (type === 'learning') return AgentType.LEARNING;
    if (type === 'note') return AgentType.NOTE;
    if (type === 'accounting') return AgentType.ACCOUNTING;
    if (type === 'reminder') return AgentType.REMINDER;
    if (type === 'coding') return AgentType.CODING;
    return AgentType.CUSTOM;
  }

  private mapStatus(status: string): AgentStatus {
    const s = status.toLowerCase();
    if (s === 'active' || s === 'online') return AgentStatus.ACTIVE;
    if (s === 'busy') return AgentStatus.BUSY;
    if (s === 'error') return AgentStatus.ERROR;
    if (s === 'offline') return AgentStatus.OFFLINE;
    return AgentStatus.IDLE;
  }

  private getMockMetrics(agentId: string): AgentMetrics {
    return {
      totalConversations: Math.floor(Math.random() * 100) + 10,
      totalMessages: Math.floor(Math.random() * 500) + 50,
      avgResponseTime: Math.floor(Math.random() * 2000) + 500,
      lastActivityAt: Date.now() - Math.floor(Math.random() * 86400000)
    };
  }
}

let instance: AgentRepository | null = null;

export function getAgentRepository(): AgentRepository {
  if (!instance) {
    instance = new AgentRepository();
  }
  return instance;
}
