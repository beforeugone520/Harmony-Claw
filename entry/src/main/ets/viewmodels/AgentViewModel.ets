import { Agent, AgentStatus, AgentType, AgentSession, AgentMessage, AgentMetrics } from '../models/Agent';
import { getAgentRepository } from '../repositories/AgentRepository';

export class AgentViewModel {
  private repository = getAgentRepository();

  agents: Agent[] = [];
  currentAgent: Agent | null = null;
  sessions: AgentSession[] = [];
  messages: AgentMessage[] = [];
  isLoading: boolean = false;
  isSending: boolean = false;
  errorMessage: string = '';

  async initialize(): Promise<void> {
    try {
      await this.loadAgents();
    } catch (e) {
      console.error(`[AgentViewModel] Initialize failed: ${JSON.stringify(e)}`);
      this.agents = [];
    }
  }

  async loadAgents(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      this.agents = await this.repository.getAgents();
      // 加载每个 agent 的指标
      for (const agent of this.agents) {
        agent.metrics = await this.repository.getAgentMetrics(agent.id);
      }
    } catch (e) {
      console.error(`[AgentViewModel] Failed to load agents: ${JSON.stringify(e)}`);
      this.errorMessage = '加载 Agent 失败';
    } finally {
      this.isLoading = false;
    }
  }

  async refresh(): Promise<void> {
    await this.loadAgents();
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
      const userMessage: AgentMessage = {
        id: Date.now().toString(),
        sessionId: '',
        agentId: this.currentAgent.id,
        role: 'user',
        content: content,
        timestamp: Date.now()
      };
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
        this.messages.push({
          id: `${Date.now()}_reply`,
          sessionId: '',
          agentId: this.currentAgent.id,
          role: 'agent',
          content: `[${this.currentAgent.displayName}] 收到您的消息: ${content}`,
          timestamp: Date.now()
        });
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
    return this.agents.filter(a =
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
