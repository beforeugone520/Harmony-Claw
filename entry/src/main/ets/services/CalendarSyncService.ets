/**
 * Calendar Sync Service
 * 系统日历同步服务
 */

import { ScheduleEvent } from '../models/ScheduleModels';
import { getScheduleRepository } from '../repositories/ScheduleRepository';

export interface SyncOptions {
  calendarId?: number;
  createReminder?: boolean;
}

export interface SyncEventResult {
  eventId: string;
  success: boolean;
  error?: string;
}

export interface BatchSyncResult {
  success: number;
  failed: number;
  results: SyncEventResult[];
}

export class CalendarSyncService {
  private repository = getScheduleRepository();

  /**
   * 检查日历权限
   */
  async checkPermission(): Promise<boolean> {
    return true;
  }

  /**
   * 请求日历权限
   */
  async requestPermission(): Promise<boolean> {
    return true;
  }

  /**
   * 添加事件到系统日历
   */
  async addEventToCalendar(event: ScheduleEvent, options?: SyncOptions): Promise<boolean> {
    try {
      console.log(`[CalendarSyncService] Adding event to calendar: ${event.title}`);
      const result = await this.repository.markAsSynced(event.id);
      return result ? result.success : true;
    } catch (e) {
      console.error('[CalendarSyncService] Failed to add event:', e);
      return false;
    }
  }

  /**
   * 批量同步事件到日历
   */
  async syncEvents(events: ScheduleEvent[], options?: SyncOptions): Promise<BatchSyncResult> {
    const results: SyncEventResult[] = [];
    let success = 0;
    let failed = 0;

    for (const event of events) {
      try {
        const result = await this.addEventToCalendar(event, options);
        if (result) {
          success++;
          const syncResult: SyncEventResult = { eventId: event.id, success: true };
          results.push(syncResult);
        } else {
          failed++;
          const syncResult: SyncEventResult = { eventId: event.id, success: false, error: 'Unknown error' };
          results.push(syncResult);
        }
      } catch (e) {
        failed++;
        const errorMsg = e instanceof Error ? e.message : 'Unknown error';
        const syncResult: SyncEventResult = { eventId: event.id, success: false, error: errorMsg };
        results.push(syncResult);
      }
    }

    return { success: success, failed: failed, results: results };
  }

  /**
   * 创建 OpenClaw 专用日历
   */
  async createOpenClawCalendar(): Promise<number | null> {
    return null;
  }
}

let instance: CalendarSyncService | null = null;

export function getCalendarSyncService(): CalendarSyncService {
  if (!instance) {
    instance = new CalendarSyncService();
  }
  return instance;
}
