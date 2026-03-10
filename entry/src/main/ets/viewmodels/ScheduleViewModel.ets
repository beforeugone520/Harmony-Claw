/**
 * Schedule ViewModel
 * 日程管理视图模型
 */

import { ScheduleEvent, CalendarDay, CalendarWeek, CalendarMonth, EVENT_CATEGORIES } from '../models/ScheduleModels';
import { getScheduleRepository } from '../repositories/ScheduleRepository';
import { getOpenClawAPIService } from '../services/OpenClawAPIService';
import { getGatewayRepository } from '../repositories/GatewayRepository';

class SyncResult {
  success: number = 0;
  failed: number = 0;
}

export class ScheduleViewModel {
  private repository = getScheduleRepository();
  private apiService = getOpenClawAPIService();
  private gatewayRepository = getGatewayRepository();

  events: ScheduleEvent[] = [];
  isLoading: boolean = false;
  errorMessage: string = '';

  async loadData(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      // Auto-connect to current gateway if not connected
      if (!this.apiService.isConnected()) {
        const currentGateway = await this.gatewayRepository.getCurrent();
        if (currentGateway) {
          console.log('[ScheduleViewModel] Auto-connecting to gateway:', currentGateway.host, currentGateway.port);
          this.apiService.setGateway(currentGateway);
        } else {
          console.warn('[ScheduleViewModel] No current gateway found, API calls may fail');
        }
      }

      const data = await this.repository.getScheduleData();
      if (data) {
        this.events = data.events || [];
      } else {
        // Use mock data if API returns null
        const mockData = this.repository.getMockData();
        this.events = mockData.events;
      }
    } catch (e) {
      console.error('[ScheduleViewModel] Failed to load data:', e);
      this.errorMessage = '加载数据失败';
      // Fallback to mock data
      const mockData = this.repository.getMockData();
      this.events = mockData.events;
    } finally {
      this.isLoading = false;
    }
  }

  getTodayEvents(): ScheduleEvent[] {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    return this.events
      .filter(event => event.startTime >= today.getTime() && event.startTime < tomorrow.getTime())
      .sort((a, b) => a.startTime - b.startTime);
  }

  getUnsyncedEvents(): ScheduleEvent[] {
    return this.events
      .filter(event => !event.syncedToCalendar)
      .sort((a, b) => a.startTime - b.startTime);
  }

  getEventsByDate(date: Date): ScheduleEvent[] {
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(startOfDay);
    endOfDay.setDate(endOfDay.getDate() + 1);

    return this.events
      .filter(event => event.startTime >= startOfDay.getTime() && event.startTime < endOfDay.getTime())
      .sort((a, b) => a.startTime - b.startTime);
  }

  getEventsByMonth(year: number, month: number): ScheduleEvent[] {
    const startOfMonth = new Date(year, month, 1);
    const endOfMonth = new Date(year, month + 1, 1);

    return this.events
      .filter(event => event.startTime >= startOfMonth.getTime() && event.startTime < endOfMonth.getTime())
      .sort((a, b) => a.startTime - b.startTime);
  }

  /**
   * 格式化本地日期为 YYYY-MM-DD 格式
   * 解决时区问题，使用本地时间而非UTC时间
   */
  private formatLocalDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  /**
   * 判断两个日期是否为同一天（本地时间）
   */
  private isSameDay(date1: Date, date2: Date): boolean {
    return date1.getFullYear() === date2.getFullYear() &&
           date1.getMonth() === date2.getMonth() &&
           date1.getDate() === date2.getDate();
  }

  generateCalendarMonth(year: number, month: number): CalendarMonth {
    const weeks: CalendarWeek[] = [];
    const firstDay = new Date(year, month, 1);

    // Get the first Sunday before or on the first day of the month
    const startDate = new Date(firstDay);
    startDate.setDate(startDate.getDate() - firstDay.getDay());

    const today = new Date();
    const todayStr = this.formatLocalDate(today);

    // Generate 6 weeks to cover all possible month layouts
    for (let week = 0; week < 6; week++) {
      const days: CalendarDay[] = [];

      for (let day = 0; day < 7; day++) {
        const currentDate = new Date(startDate);
        currentDate.setDate(startDate.getDate() + week * 7 + day);

        const dateStr = this.formatLocalDate(currentDate);
        const isCurrentMonth = currentDate.getMonth() === month;
        const isToday = this.isSameDay(currentDate, today);

        const dayEvents = this.events.filter(event => {
          const eventDate = new Date(event.startTime);
          return this.isSameDay(eventDate, currentDate);
        });

        days.push({
          date: dateStr,
          dayOfMonth: currentDate.getDate(),
          isCurrentMonth: isCurrentMonth,
          isToday: isToday,
          events: dayEvents
        });
      }

      weeks.push({ days: days });
    }

    return {
      year: year,
      month: month,
      weeks: weeks
    };
  }

  async syncToCalendar(event: ScheduleEvent): Promise<boolean> {
    try {
      const result = await this.repository.markAsSynced(event.id);
      if (result && result.success) {
        event.syncedToCalendar = true;
        return true;
      }
    } catch (e) {
      console.error('[ScheduleViewModel] Failed to sync event:', e);
    }
    return false;
  }

  async syncAllToCalendar(): Promise<SyncResult> {
    const unsynced = this.getUnsyncedEvents();
    let success = 0;
    let failed = 0;

    for (const event of unsynced) {
      const result = await this.syncToCalendar(event);
      if (result) {
        success++;
      } else {
        failed++;
      }
    }

    return { success: success, failed: failed };
  }

  getCategoryColor(category: string): string {
    const cat = EVENT_CATEGORIES.find(c => c.name === category);
    return cat?.color || '#B0B0B0';
  }

  getCategoryIcon(category: string): string {
    const cat = EVENT_CATEGORIES.find(c => c.name === category);
    return cat?.icon || '📅';
  }

  formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  formatDuration(startTime: number, endTime: number): string {
    const duration = endTime - startTime;
    const hours = Math.floor(duration / 3600000);
    const minutes = Math.floor((duration % 3600000) / 60000);

    if (hours > 0) {
      return `${hours}小时${minutes > 0 ? minutes + '分钟' : ''}`;
    }
    return `${minutes}分钟`;
  }
}