export enum MessageType {
  TEXT = 'text',
  IMAGE = 'image',
  FILE = 'file',
  SYSTEM = 'system'
}

export class Message {
  id: string = '';
  sessionId: string = '';
  type: MessageType = MessageType.TEXT;
  content: string = '';
  sender: string = '';
  timestamp: number = Date.now();
  isRead: boolean = false;

  constructor(init?: Partial<Message>) {
    if (init) {
      if (init.id !== undefined) this.id = init.id;
      if (init.sessionId !== undefined) this.sessionId = init.sessionId;
      if (init.type !== undefined) this.type = init.type;
      if (init.content !== undefined) this.content = init.content;
      if (init.sender !== undefined) this.sender = init.sender;
      if (init.timestamp !== undefined) this.timestamp = init.timestamp;
      if (init.isRead !== undefined) this.isRead = init.isRead;
    }
  }
}
