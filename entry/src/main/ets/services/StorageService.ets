import { preferences } from '@kit.ArkData';
import { Gateway } from '../models/Gateway';
import { Session } from '../models/Session';

export class StorageKeys {
  static readonly GATEWAYS: string = 'gateways';
  static readonly CURRENT_GATEWAY_ID: string = 'current_gateway_id';
  static readonly SESSIONS: string = 'sessions';
  static readonly PROCESSES: string = 'processes';
  static readonly SETTINGS: string = 'settings';
}

export interface AppSettings {
  darkMode: boolean;
  notifications: boolean;
  autoRefresh: boolean;
  apiUrl: string;
  refreshInterval: number;
}

export class StorageService {
  private pref: preferences.Preferences | null = null;
  private storageName: string = 'harmony_claw_storage';

  async initialize(): Promise<void> {
    try {
      const context = getContext();
      this.pref = await preferences.getPreferences(context, this.storageName);
    } catch (e) {
      console.error(`[StorageService] Failed to initialize: ${JSON.stringify(e)}`);
      throw new Error(`StorageService initialize failed: ${JSON.stringify(e)}`);
    }
  }

  async set(key: string, value: string): Promise<void> {
    if (!this.pref) await this.initialize();
    await this.pref!.put(key, value);
    await this.pref!.flush();
  }

  async get(key: string, defaultValue: string = ''): Promise<string> {
    if (!this.pref) await this.initialize();
    return await this.pref!.get(key, defaultValue) as string;
  }

  async setObject<T extends object>(key: string, value: T): Promise<void> {
    await this.set(key, JSON.stringify(value));
  }

  async getObject<T extends object>(key: string, defaultValue: T | null = null): Promise<T | null> {
    const data = await this.get(key);
    if (!data) return defaultValue;
    try {
      return JSON.parse(data) as T;
    } catch {
      return defaultValue;
    }
  }

  async saveGateways(gateways: Gateway[]): Promise<void> {
    await this.setObject(StorageKeys.GATEWAYS, gateways);
  }

  async loadGateways(): Promise<Gateway[]> {
    const gateways = await this.getObject<Gateway[]>(StorageKeys.GATEWAYS, []);
    return gateways || [];
  }

  async saveSessions(sessions: Session[]): Promise<void> {
    await this.setObject(StorageKeys.SESSIONS, sessions);
  }

  async loadSessions(): Promise<Session[]> {
    const sessions = await this.getObject<Session[]>(StorageKeys.SESSIONS, []);
    return sessions || [];
  }

  async saveCurrentGatewayId(id: string): Promise<void> {
    await this.set(StorageKeys.CURRENT_GATEWAY_ID, id);
  }

  async getCurrentGatewayId(): Promise<string> {
    return await this.get(StorageKeys.CURRENT_GATEWAY_ID);
  }

  async saveSettings(settings: AppSettings): Promise<void> {
    await this.setObject(StorageKeys.SETTINGS, settings);
  }

  async loadSettings(): Promise<AppSettings> {
    const defaultSettings: AppSettings = {
      darkMode: false,
      notifications: true,
      autoRefresh: true,
      apiUrl: 'https://api.openclaw.io',
      refreshInterval: 30
    };
    const settings = await this.getObject<AppSettings>(StorageKeys.SETTINGS, defaultSettings);
    return settings || defaultSettings;
  }

  async delete(key: string): Promise<void> {
    if (!this.pref) await this.initialize();
    await this.pref!.delete(key);
    await this.pref!.flush();
  }

  async clear(): Promise<void> {
    if (!this.pref) await this.initialize();
    await this.pref!.clear();
    await this.pref!.flush();
  }
}

let instance: StorageService | null = null;

export function getStorageService(): StorageService {
  if (!instance) {
    instance = new StorageService();
  }
  return instance;
}
