/**
 * Agent 模型
 * OpenClaw Agent 定义
 */

export enum AgentStatus {
  ACTIVE = 'active',
  IDLE = 'idle',
  BUSY = 'busy',
  ERROR = 'error',
  OFFLINE = 'offline'
}

export enum AgentType {
  MAIN = 'main',
  LEARNING = 'learning',
  NOTE = 'note',
  ACCOUNTING = 'accounting',
  REMINDER = 'reminder',
  CODING = 'coding',
  CUSTOM = 'custom'
}

export interface AgentIdentity {
  name: string;
  theme: string;
  emoji: string;
}

export interface AgentTools {
  profile: string;
  web?: {
    search: boolean;
  };
}

export interface AgentMetrics {
  totalConversations: number;
  totalMessages: number;
  avgResponseTime: number;
  lastActivityAt: number;
}

export class Agent {
  id: string = '';
  name: string = '';
  type: AgentType = AgentType.CUSTOM;
  status: AgentStatus = AgentStatus.OFFLINE;
  workspace: string = '';
  agentDir: string = '';
  identity?: AgentIdentity;
  tools?: AgentTools;
  model?: string;
  metrics?: AgentMetrics;
  createdAt: number = Date.now();
  updatedAt: number = Date.now();
  isActive: boolean = false;

  constructor(init?: Partial<Agent>) {
    if (init) {
      if (init.id !== undefined) this.id = init.id;
      if (init.name !== undefined) this.name = init.name;
      if (init.type !== undefined) this.type = init.type;
      if (init.status !== undefined) this.status = init.status;
      if (init.workspace !== undefined) this.workspace = init.workspace;
      if (init.agentDir !== undefined) this.agentDir = init.agentDir;
      if (init.identity !== undefined) this.identity = init.identity;
      if (init.tools !== undefined) this.tools = init.tools;
      if (init.model !== undefined) this.model = init.model;
      if (init.metrics !== undefined) this.metrics = init.metrics;
      if (init.createdAt !== undefined) this.createdAt = init.createdAt;
      if (init.updatedAt !== undefined) this.updatedAt = init.updatedAt;
      if (init.isActive !== undefined) this.isActive = init.isActive;
    }
  }

  get displayName(): string {
    return this.identity?.name || this.name || this.id;
  }

  get emoji(): string {
    return this.identity?.emoji || '🤖';
  }

  get theme(): string {
    return this.identity?.theme || '';
  }
}

export interface AgentFilter {
  type?: AgentType;
  status?: AgentStatus;
  isActive?: boolean;
}

export interface AgentSession {
  id: string;
  agentId: string;
  title: string;
  messageCount: number;
  createdAt: number;
  updatedAt: number;
}

export interface AgentMessage {
  id: string;
  sessionId: string;
  agentId: string;
  role: 'user' | 'agent' | 'system';
  content: string;
  timestamp: number;
  metadata?: Record<string, unknown>;
}
