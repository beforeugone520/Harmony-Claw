import { Session, SessionStatus, SessionType } from '../models/Session';
import { Message, MessageType } from '../models/Message';
import { getStorageService } from '../services/StorageService';
import { getHttpService, HttpResponse } from '../services/HttpService';
import { ApiEndpoints } from '../constants/ApiEndpoints';

export interface CreateSessionRequest {
  title?: string;
  type?: string;
}

export interface SendMessageRequest {
  sessionId: string;
  content: string;
  type?: MessageType;
}

export class ChatRepository {
  private storage = getStorageService();
  private http = getHttpService();
  private idCounter: number = 0;

  private generateId(): string {
    return `${Date.now()}_${++this.idCounter}_${Math.random().toString(36).substr(2, 9)}`;
  }

  async getSessions(): Promise<Session[]> {
    try {
      const response = await this.http.get<Session[]>(ApiEndpoints.CHAT_SESSIONS);
      if (response.code === 200) {
        await this.storage.saveSessions(response.data);
        return response.data;
      }
    } catch (e) {
      // Fallback to local storage
    }
    return await this.storage.loadSessions();
  }

  async createSession(request: CreateSessionRequest): Promise<Session | null> {
    try {
      const response = await this.http.post<Session>(ApiEndpoints.CHAT_SESSIONS, request);
      if (response.code === 200) {
        return response.data;
      }
    } catch (e) {
      // Create local session
      let sessionType = SessionType.WEB;
      if (request.type === 'api') {
        sessionType = SessionType.API;
      } else if (request.type === 'cli') {
        sessionType = SessionType.CLI;
      }
      const session = new Session();
      session.id = this.generateId();
      session.title = request.title || 'New Session';
      session.type = sessionType;
      session.status = SessionStatus.ACTIVE;
      const sessions = await this.storage.loadSessions();
      sessions.push(session);
      await this.storage.saveSessions(sessions);
      return session;
    }
    return null;
  }

  async getMessages(sessionId: string): Promise<Message[]> {
    try {
      const response = await this.http.get<Message[]>(
        `${ApiEndpoints.CHAT_MESSAGES}?sessionId=${sessionId}`
      );
      if (response.code === 200) {
        return response.data;
      }
    } catch (e) {
      // Return empty array on error
    }
    return [];
  }

  async sendMessage(request: SendMessageRequest): Promise<Message | null> {
    const message = new Message();
    message.id = Date.now().toString();
    message.sessionId = request.sessionId;
    message.content = request.content;
    message.type = request.type || MessageType.TEXT;
    message.sender = 'user';
    message.timestamp = Date.now();
    message.isRead = true;

    try {
      interface SendMessageBody {
        sessionId: string;
        message: string;
      }
      const body: SendMessageBody = {
        sessionId: request.sessionId,
        message: request.content
      };
      const response = await this.http.post<Message>(ApiEndpoints.CHAT_SEND, body);
      if (response.code === 200) {
        return response.data;
      }
    } catch (e) {
      // Return local message on error
    }
    return message;
  }

  async deleteSession(sessionId: string): Promise<void> {
    try {
      await this.http.delete<Session>(`${ApiEndpoints.CHAT_SESSIONS}/${sessionId}`);
    } catch (e) {
      // Delete from local storage
    }
    // Delete from local storage
    const sessions = await this.storage.loadSessions();
    const filtered = sessions.filter(s => s.id !== sessionId);
    await this.storage.saveSessions(filtered);

    // Also delete associated messages
    await this.clearSessionMessages(sessionId);
  }

  // ===== Local Message Storage =====

  async saveMessage(message: Message): Promise<void> {
    const messages = await this.getAllMessages();
    messages.push(message);
    await this.storage.setObject('messages', messages);
  }

  async getAllMessages(): Promise<Message[]> {
    const result = await this.storage.getObject<Message[]>('messages', []);
    return result ?? [];
  }

  async clearSessionMessages(sessionId: string): Promise<void> {
    const messages = await this.getAllMessages();
    const filtered = messages.filter(m => m.sessionId !== sessionId);
    await this.storage.setObject('messages', filtered);
  }

  async markMessagesAsRead(sessionId: string): Promise<void> {
    const messages = await this.getAllMessages();
    let updated = false;
    for (const msg of messages) {
      if (msg.sessionId === sessionId && !msg.isRead && msg.sender !== 'user') {
        msg.isRead = true;
        updated = true;
      }
    }
    if (updated) {
      await this.storage.setObject('messages', messages);
    }
  }

  async getUnreadCount(sessionId: string): Promise<number> {
    const messages = await this.getMessages(sessionId);
    return messages.filter(m => !m.isRead && m.sender !== 'user').length;
  }
}

let instance: ChatRepository | null = null;

export function getChatRepository(): ChatRepository {
  if (!instance) {
    instance = new ChatRepository();
  }
  return instance;
}
