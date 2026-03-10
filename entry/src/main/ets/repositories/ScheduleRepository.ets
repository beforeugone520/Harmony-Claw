/**
 * Schedule Repository
 * 日程管理数据仓库
 */

import { ScheduleData, ScheduleEvent, SyncResult } from '../models/ScheduleModels';
import { getOpenClawAPIService } from '../services/OpenClawAPIService';
import { ApiEndpoints } from '../constants/ApiEndpoints';

export class ScheduleRepository {
  private apiService = getOpenClawAPIService();

  private get http() {
    return this.apiService.getHttpService();
  }

  async getScheduleData(): Promise<ScheduleData | null> {
    try {
      const response = await this.http.get<ScheduleData>(ApiEndpoints.DATA_SCHEDULE);
      if (response.code === 200 && response.data) {
        return response.data;
      }
    } catch (e) {
      console.error('[ScheduleRepository] Failed to get schedule data:', e);
    }
    return null;
  }

  async addEvent(event: ScheduleEvent): Promise<ScheduleEvent | null> {
    try {
      const response = await this.http.post<ScheduleEvent>(ApiEndpoints.DATA_SCHEDULE, event);
      if (response.code === 200 && response.data) {
        return response.data;
      }
    } catch (e) {
      console.error('[ScheduleRepository] Failed to add event:', e);
    }
    return null;
  }

  async markAsSynced(eventId: string): Promise<SyncResult | null> {
    try {
      const path = ApiEndpoints.DATA_SCHEDULE_SYNC.replace('{id}', eventId);
      const emptyBody: Record<string, string> = {};
      const response = await this.http.post<SyncResult>(path, emptyBody);
      if (response.code === 200 && response.data) {
        return response.data;
      }
    } catch (e) {
      console.error('[ScheduleRepository] Failed to mark as synced:', e);
    }
    return null;
  }

  // Mock data for development/testing
  getMockData(): ScheduleData {
    const now = Date.now();
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    return {
      version: '1.0',
      updatedAt: now,
      events: [
        {
          id: 'event_001',
          title: '项目评审会议',
          description: '与团队讨论Q2计划',
          startTime: today.getTime() + 10 * 3600000,
          endTime: today.getTime() + 11 * 3600000,
          location: '会议室A',
          category: '工作',
          isAllDay: false,
          recurrence: null,
          reminder: 15,
          syncedToCalendar: false,
          createdAt: now - 86400000
        },
        {
          id: 'event_002',
          title: '健身训练',
          description: '有氧运动30分钟',
          startTime: today.getTime() + 18 * 3600000,
          endTime: today.getTime() + 19 * 3600000,
          location: '健身房',
          category: '健康',
          isAllDay: false,
          recurrence: null,
          reminder: 30,
          syncedToCalendar: true,
          createdAt: now - 43200000
        },
        {
          id: 'event_003',
          title: '团队聚餐',
          description: '庆祝项目上线',
          startTime: tomorrow.getTime() + 12 * 3600000,
          endTime: tomorrow.getTime() + 14 * 3600000,
          location: '海底捞',
          category: '社交',
          isAllDay: false,
          recurrence: null,
          reminder: 60,
          syncedToCalendar: false,
          createdAt: now - 3600000
        }
      ],
      categories: ['工作', '个人', '健康', '学习', '社交', '娱乐']
    };
  }
}

let instance: ScheduleRepository | null = null;

export function getScheduleRepository(): ScheduleRepository {
  if (!instance) {
    instance = new ScheduleRepository();
  }
  return instance;
}
