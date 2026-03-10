export enum GatewayStatus {
  ONLINE = 'online',
  OFFLINE = 'offline',
  ERROR = 'error',
  CONNECTING = 'connecting'
}

export enum GatewayProtocol {
  HTTP = 'http',
  HTTPS = 'https',
  WS = 'ws',
  WSS = 'wss'
}

export class Gateway {
  id: string = '';
  name: string = '';
  host: string = '';
  port: number = 8080;
  protocol: GatewayProtocol = GatewayProtocol.HTTP;
  status: GatewayStatus = GatewayStatus.OFFLINE;
  version: string = '1.0.0';
  lastSeen: number = Date.now();
  isFavorite: boolean = false;

  constructor(init?: Partial<Gateway>) {
    if (init) {
      if (init.id !== undefined) this.id = init.id;
      if (init.name !== undefined) this.name = init.name;
      if (init.host !== undefined) this.host = init.host;
      if (init.port !== undefined) this.port = init.port;
      if (init.protocol !== undefined) this.protocol = init.protocol;
      if (init.status !== undefined) this.status = init.status;
      if (init.version !== undefined) this.version = init.version;
      if (init.lastSeen !== undefined) this.lastSeen = init.lastSeen;
      if (init.isFavorite !== undefined) this.isFavorite = init.isFavorite;
    }
  }
}
