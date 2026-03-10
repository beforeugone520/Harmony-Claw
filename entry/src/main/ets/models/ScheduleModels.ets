/**
 * Schedule Models
 * 日程管理数据模型
 */

export interface ScheduleEvent {
  id: string;
  title: string;
  description: string;
  startTime: number;
  endTime: number;
  location: string;
  category: string;
  isAllDay: boolean;
  recurrence: string | null;
  reminder: number;
  syncedToCalendar: boolean;
  createdAt: number;
}

export interface ScheduleData {
  version: string;
  updatedAt: number;
  events: ScheduleEvent[];
  categories: string[];
}

export interface EventCategory {
  name: string;
  icon: string;
  color: string;
}

export const EVENT_CATEGORIES: EventCategory[] = [
  { name: '工作', icon: '💼', color: '#FF6B6B' },
  { name: '个人', icon: '👤', color: '#4ECDC4' },
  { name: '健康', icon: '💪', color: '#45B7D1' },
  { name: '学习', icon: '📚', color: '#96CEB4' },
  { name: '社交', icon: '👥', color: '#FFEAA7' },
  { name: '娱乐', icon: '🎮', color: '#DDA0DD' }
];

export interface CalendarDay {
  date: string;
  dayOfMonth: number;
  isCurrentMonth: boolean;
  isToday: boolean;
  events: ScheduleEvent[];
}

export interface CalendarWeek {
  days: CalendarDay[];
}

export interface CalendarMonth {
  year: number;
  month: number;
  weeks: CalendarWeek[];
}

export interface SyncResult {
  success: boolean;
  eventId: string;
  calendarEventId?: string;
  error?: string;
}
