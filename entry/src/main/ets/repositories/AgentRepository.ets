import { Agent, AgentStatus, AgentType, AgentSession, AgentMessage, AgentIdentity, AgentTools, AgentMetrics } from '../models/Agent';
import { getHttpService } from '../services/HttpService';
import { ApiEndpoints } from '../constants/ApiEndpoints';

export interface AgentConfig {
  id: string;
  name?: string;
  workspace?: string;
  agentDir?: string;
  identity?: AgentIdentity;
  tools?: AgentTools;
}

export interface OpenClawConfig {
  agents?: {
    list?: AgentConfig[];
    defaults?: {
      model?: {
        primary?: string;
      };
    };
  };
}

export class AgentRepository {
  private http = getHttpService();

  // 从 OpenClaw 配置解析 Agent 列表
  async getAgents(): Promise<Agent[]> {
    const agents: Agent[] = [];

    // 内置的 Agent 配置（从 openclaw.json 读取）
    const agentConfigs: AgentConfig[] = [
      {
        id: 'main',
        name: 'Main Agent',
        workspace: '/Users/beforeugone/.openclaw/workspace',
        tools: { profile: 'full' }
      },
      {
        id: 'learning-bot',
        name: 'learning-bot',
        workspace: '/Users/beforeugone/.openclaw/agents/学习整理bot-黎小学',
        agentDir: '/Users/beforeugone/.openclaw/agents/learning-bot/agent',
        identity: {
          name: '黎小学',
          theme: '热爱学习、知识整理、耐心细致',
          emoji: '📚'
        }
      },
      {
        id: 'note-bot',
        name: 'note-bot',
        workspace: '/Users/beforeugone/.openclaw/agents/记事bot-黎小记',
        agentDir: '/Users/beforeugone/.openclaw/agents/note-bot/agent',
        identity: {
          name: '黎小记',
          theme: '记录一切、井井有条、随时提醒',
          emoji: '📝'
        }
      },
      {
        id: 'accounting-bot',
        name: 'accounting-bot',
        workspace: '/Users/beforeugone/.openclaw/agents/记账bot-黎小财',
        agentDir: '/Users/beforeugone/.openclaw/agents/accounting-bot/agent',
        identity: {
          name: '黎小财',
          theme: '精打细算、理财助手、账目清晰',
          emoji: '💰'
        }
      },
      {
        id: 'reminder-bot',
        name: 'reminder-bot',
        workspace: '/Users/beforeugone/.openclaw/agents/定时提醒bot-黎小令',
        agentDir: '/Users/beforeugone/.openclaw/agents/定时提醒bot-黎小令',
        identity: {
          name: '黎小令',
          theme: '准时可靠、温柔贴心、高效执行',
          emoji: '⏰'
        }
      },
      {
        id: 'coding-bot',
        name: 'coding-bot',
        workspace: '/Users/beforeugone/.openclaw/agents/编程助手bot-黎小程',
        agentDir: '/Users/beforeugone/.openclaw/agents/编程助手bot-黎小程',
        identity: {
          name: '黎小程',
          theme: '专业高效、代码洁癖、热爱技术',
          emoji: '💻'
        }
      }
    ];

    for (const config of agentConfigs) {
      const agent = this.parseAgentConfig(config);
      // 检查 agent 是否在线
      agent.status = await this.checkAgentStatus(agent.id);
      agents.push(agent);
    }

    return agents;
  }

  async getAgentById(id: string): Promise<Agent | null> {
    const agents = await this.getAgents();
    return agents.find(a => a.id === id) || null;
  }

  async checkAgentStatus(agentId: string): Promise<AgentStatus> {
    try {
      // 尝试通过 API 检查 agent 状态
      const path = `${ApiEndpoints.AGENTS}/${agentId}/status`;
      const response = await this.http.get<{ status: string }>(path);
      if (response.code === 200 && response.data) {
        return this.mapStatus(response.data.status);
      }
    } catch (e) {
      // API 调用失败，假设 agent 处于 idle 状态
      console.warn(`[AgentRepository] Failed to check status for ${agentId}:`, e);
    }
    return AgentStatus.IDLE;
  }

  async sendMessageToAgent(agentId: string, content: string): Promise<AgentMessage | null> {
    try {
      const path = ApiEndpoints.AGENT_SEND.replace('{id}', agentId);
      const response = await this.http.post<{
        messageId: string;
        content: string;
        timestamp: number;
      }>(path, { message: content });

      if (response.code === 200 && response.data) {
        return {
          id: response.data.messageId,
          sessionId: '', // 需要从响应中获取
          agentId: agentId,
          role: 'agent',
          content: response.data.content,
          timestamp: response.data.timestamp
        };
      }
    } catch (e) {
      console.error(`[AgentRepository] Failed to send message to ${agentId}:`, e);
    }
    return null;
  }

  async getAgentSessions(agentId: string): Promise<AgentSession[]> {
    try {
      const path = `${ApiEndpoints.AGENTS}/${agentId}/sessions`;
      const response = await this.http.get<AgentSession[]>(path);
      if (response.code === 200 && response.data) {
        return response.data;
      }
    } catch (e) {
      console.warn(`[AgentRepository] Failed to get sessions for ${agentId}:`, e);
    }
    return [];
  }

  async getAgentMetrics(agentId: string): Promise<AgentMetrics | undefined> {
    try {
      const path = `${ApiEndpoints.AGENTS}/${agentId}/metrics`;
      const response = await this.http.get<AgentMetrics>(path);
      if (response.code === 200 && response.data) {
        return response.data;
      }
    } catch (e) {
      // 返回模拟数据
      return this.getMockMetrics(agentId);
    }
    return undefined;
  }

  private parseAgentConfig(config: AgentConfig): Agent {
    const agent = new Agent();
    agent.id = config.id;
    agent.name = config.name || config.id;
    agent.workspace = config.workspace || '';
    agent.agentDir = config.agentDir || '';
    agent.identity = config.identity;
    agent.tools = config.tools;
    agent.type = this.mapAgentType(config.id);
    agent.isActive = config.id === 'main'; // main agent 默认激活

    return agent;
  }

  private mapAgentType(id: string): AgentType {
    if (id === 'main') return AgentType.MAIN;
    if (id.includes('learning')) return AgentType.LEARNING;
    if (id.includes('note')) return AgentType.NOTE;
    if (id.includes('accounting')) return AgentType.ACCOUNTING;
    if (id.includes('reminder')) return AgentType.REMINDER;
    if (id.includes('coding')) return AgentType.CODING;
    return AgentType.CUSTOM;
  }

  private mapStatus(status: string): AgentStatus {
    switch (status.toLowerCase()) {
      case 'active':
      case 'online':
        return AgentStatus.ACTIVE;
      case 'busy':
        return AgentStatus.BUSY;
      case 'error':
        return AgentStatus.ERROR;
      case 'offline':
        return AgentStatus.OFFLINE;
      default:
        return AgentStatus.IDLE;
    }
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
