import { Agent, AgentStatus, AgentType, AgentSession, AgentMessage, AgentMetrics } from '../models/Agent';
import { getAgentRepository } from '../repositories/AgentRepository';
import { getOpenClawAPIService } from '../services/OpenClawAPIService';
import { Gateway } from '../models/Gateway';

export class AgentViewModel {
  private repository = getAgentRepository();
  private apiService = getOpenClawAPIService();

  agents: Agent[] = [];
  currentAgent: Agent | null = null;
  sessions: AgentSession[] = [];
  messages: AgentMessage[] = [];
  isLoading: boolean = false;
  isSending: boolean = false;
  errorMessage: string = '';
  currentGateway: Gateway | null = null;

  async initialize(): Promise<void> {
    // Check if there's already a connected gateway
    const currentGateway = this.apiService.getCurrentGateway();
    if (currentGateway) {
      this.currentGateway = currentGateway;
      try {
        await this.loadAgents();
      } catch (e) {
        console.error(`[AgentViewModel] Initialize failed: ${JSON.stringify(e)}`);
        this.agents = [];
      }
    } else {
      console.log('[AgentViewModel] No gateway connected, skipping agent load');
      this.agents = [];
    }
  }

  /**
   * Refresh agent list from current gateway
   */
  async refresh(): Promise<void> {
    // Re-check gateway connection
    const currentGateway = this.apiService.getCurrentGateway();
    if (currentGateway) {
      this.currentGateway = currentGateway;
    }
    await this.loadAgents();
  }

  /**
   * Set the current gateway and load agents from it
   */
  async setGateway(gateway: Gateway): Promise<void> {
    this.currentGateway = gateway;
    this.apiService.setGateway(gateway);
    console.log(`[AgentViewModel] Gateway set to ${gateway.host}:${gateway.port}`);
    await this.loadAgents();
  }

  async loadAgents(): Promise<void> {
    // Check if we have a connected gateway
    if (!this.currentGateway && !this.apiService.isConnected()) {
      console.log('[AgentViewModel] No gateway connected, cannot load agents');
      this.agents = [];
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';
    try {
      this.agents = await this.repository.getAgents();
      // Load metrics for each agent
      for (const agent of this.agents) {
        agent.metrics = await this.repository.getAgentMetrics(agent.id);
      }
      console.log(`[AgentViewModel] Loaded ${this.agents.length} agents`);
    } catch (e) {
      console.error(`[AgentViewModel] Failed to load agents: ${JSON.stringify(e)}`);
      this.errorMessage = '加载 Agent 失败';
      this.agents = [];
    } finally {
      this.isLoading = false;
    }
  }

  async selectAgent(agent: Agent): Promise<void> {
    this.currentAgent = agent;
    await this.loadAgentSessions(agent.id);
  }

  async loadAgentSessions(agentId: string): Promise<void> {
    this.isLoading = true;
    try {
      this.sessions = await this.repository.getAgentSessions(agentId);
    } catch (e) {
      console.error(`[AgentViewModel] Failed to load sessions: ${JSON.stringify(e)}`);
      this.sessions = [];
    } finally {
      this.isLoading = false;
    }
  }

  async sendMessage(content: string): Promise<void> {
    if (!this.currentAgent || !content.trim()) return;

    this.isSending = true;
    try {
      // 添加用户消息
      class UserMessage implements AgentMessage {
        id: string = '';
        sessionId: string = '';
        agentId: string = '';
        role: 'user' | 'agent' | 'system' = 'user';
        content: string = '';
        timestamp: number = 0;
      }
      const userMessage = new UserMessage();
      userMessage.id = Date.now().toString();
      userMessage.sessionId = '';
      userMessage.agentId = this.currentAgent.id;
      userMessage.role = 'user';
      userMessage.content = content;
      userMessage.timestamp = Date.now();
      this.messages.push(userMessage);

      // 发送给 agent
      const response = await this.repository.sendMessageToAgent(
        this.currentAgent.id,
        content
      );

      if (response) {
        this.messages.push(response);
      } else {
        // 模拟回复
        class ReplyMessage implements AgentMessage {
          id: string = '';
          sessionId: string = '';
          agentId: string = '';
          role: 'user' | 'agent' | 'system' = 'agent';
          content: string = '';
          timestamp: number = 0;
        }
        const reply = new ReplyMessage();
        reply.id = `${Date.now()}_reply`;
        reply.sessionId = '';
        reply.agentId = this.currentAgent.id;
        reply.role = 'agent';
        reply.content = `[${this.currentAgent.displayName}] 收到您的消息: ${content}`;
        reply.timestamp = Date.now();
        this.messages.push(reply);
      }
    } finally {
      this.isSending = false;
    }
  }

  async checkAgentStatus(agentId: string): Promise<AgentStatus> {
    return await this.repository.checkAgentStatus(agentId);
  }

  getActiveAgents(): Agent[] {
    return this.agents.filter(a => a.status === AgentStatus.ACTIVE || a.isActive);
  }

  getAgentsByType(type: AgentType): Agent[] {
    return this.agents.filter(a => a.type === type);
  }

  getOnlineCount(): number {
    return this.agents.filter((a: Agent) =>
      a.status === AgentStatus.ACTIVE ||
      a.status === AgentStatus.IDLE ||
      a.status === AgentStatus.BUSY
    ).length;
  }

  getBusyCount(): number {
    return this.agents.filter(a => a.status === AgentStatus.BUSY).length;
  }

  getTotalMessageCount(): number {
    return this.agents.reduce((sum, agent) => {
      return sum + (agent.metrics?.totalMessages || 0);
    }, 0);
  }
}
