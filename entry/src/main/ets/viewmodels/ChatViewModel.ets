import { Session, SessionStatus } from '../models/Session';
import { Message, MessageType } from '../models/Message';
import { getChatRepository, SendMessageRequest } from '../repositories/ChatRepository';

export class ChatViewModel {
  private repository = getChatRepository();
  private idCounter: number = 0;

  private generateId(): string {
    return `${Date.now()}_${++this.idCounter}_${Math.random().toString(36).substr(2, 9)}`;
  }

  sessions: Session[] = [];
  currentSession: Session | null = null;
  messages: Message[] = [];
  isLoading: boolean = false;
  isSending: boolean = false;
  errorMessage: string = '';

  async initialize(): Promise<void> {
    try {
      await this.loadSessions();
    } catch (e) {
      console.error(`[ChatViewModel] Initialize failed: ${JSON.stringify(e)}`);
      this.sessions = [];
    }
  }

  async loadSessions(): Promise<void> {
    this.isLoading = true;
    try {
      this.sessions = await this.repository.getSessions();
    } catch (e) {
      console.error(`[ChatViewModel] Failed to load sessions: ${JSON.stringify(e)}`);
      this.sessions = [];
    } finally {
      this.isLoading = false;
    }
  }

  async createSession(title?: string): Promise<Session | null> {
    this.isLoading = true;
    try {
      const session = await this.repository.createSession({ title });
      if (session) {
        this.sessions.push(session);
        this.currentSession = session;
      }
      return session;
    } finally {
      this.isLoading = false;
    }
  }

  async selectSession(session: Session): Promise<void> {
    this.currentSession = session;
    await this.loadMessages(session.id);
  }

  async loadMessages(sessionId: string): Promise<void> {
    this.isLoading = true;
    try {
      this.messages = await this.repository.getMessages(sessionId);
    } finally {
      this.isLoading = false;
    }
  }

  async sendMessage(content: string): Promise<void> {
    if (!this.currentSession || !content.trim()) return;

    this.isSending = true;
    try {
      const userMessage = new Message();
      userMessage.id = this.generateId();
      userMessage.sessionId = this.currentSession.id;
      userMessage.content = content;
      userMessage.type = MessageType.TEXT;
      userMessage.sender = 'user';
      userMessage.timestamp = Date.now();
      userMessage.isRead = true;
      this.messages.push(userMessage);

      const request: SendMessageRequest = {
        sessionId: this.currentSession.id,
        content: content,
        type: MessageType.TEXT
      };

      const response = await this.repository.sendMessage(request);
      if (response) {
        this.messages.push(response);
      }
    } finally {
      this.isSending = false;
    }
  }

  async deleteSession(sessionId: string): Promise<void> {
    await this.repository.deleteSession(sessionId);
    this.sessions = this.sessions.filter(s => s.id !== sessionId);
    if (this.currentSession?.id === sessionId) {
      this.currentSession = null;
      this.messages = [];
    }
  }

  getActiveCount(): number {
    let count = 0;
    for (let i = 0; i < this.sessions.length; i++) {
      if (this.sessions[i].status === 'active') {
        count++;
      }
    }
    return count;
  }
}
