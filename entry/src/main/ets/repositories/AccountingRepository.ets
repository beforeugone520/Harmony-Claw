/**
 * Accounting Repository
 * 记账与热量数据仓库
 */

import { AccountingData, BillRecord, DailyStats, MonthlyStats } from '../models/AccountingModels';
import { getOpenClawAPIService } from '../services/OpenClawAPIService';
import { ApiEndpoints } from '../constants/ApiEndpoints';

interface StatsData {
  daily: DailyStats[];
  monthly: MonthlyStats[];
}

export class AccountingRepository {
  private apiService = getOpenClawAPIService();

  private get http() {
    return this.apiService.getHttpService();
  }

  async getAccountingData(): Promise<AccountingData | null> {
    try {
      const response = await this.http.get<AccountingData>(ApiEndpoints.DATA_ACCOUNTING);
      if (response.code === 200 && response.data) {
        return response.data;
      }
    } catch (e) {
      console.error('[AccountingRepository] Failed to get accounting data:', e);
    }
    return null;
  }

  async addBill(bill: BillRecord): Promise<BillRecord | null> {
    try {
      const response = await this.http.post<BillRecord>(ApiEndpoints.DATA_ACCOUNTING, bill);
      if (response.code === 200 && response.data) {
        return response.data;
      }
    } catch (e) {
      console.error('[AccountingRepository] Failed to add bill:', e);
    }
    return null;
  }

  async getStats(period: string = 'month'): Promise<StatsData | null> {
    try {
      const response = await this.http.get<StatsData>(
        `${ApiEndpoints.DATA_ACCOUNTING_STATS}?period=${period}`
      );
      if (response.code === 200 && response.data) {
        return response.data;
      }
    } catch (e) {
      console.error('[AccountingRepository] Failed to get stats:', e);
    }
    return null;
  }

  // Mock data for development/testing
  getMockData(): AccountingData {
    const now = Date.now();
    const today = new Date();
    const dateStr = today.toISOString().split('T')[0];

    return {
      version: '1.0',
      updatedAt: now,
      bills: [
        {
          id: 'bill_001',
          date: dateStr,
          category: '餐饮',
          amount: 35.5,
          currency: 'CNY',
          items: ['午餐'],
          calories: 650,
          note: '公司食堂',
          createdAt: now - 3600000
        },
        {
          id: 'bill_002',
          date: dateStr,
          category: '交通',
          amount: 12.0,
          currency: 'CNY',
          items: ['地铁'],
          calories: 0,
          note: '通勤',
          createdAt: now - 7200000
        },
        {
          id: 'bill_003',
          date: new Date(today.getTime() - 86400000).toISOString().split('T')[0],
          category: '餐饮',
          amount: 48.0,
          currency: 'CNY',
          items: ['晚餐'],
          calories: 800,
          note: '外卖',
          createdAt: now - 90000000
        }
      ],
      dailyStats: [
        {
          date: dateStr,
          totalAmount: 47.5,
          totalCalories: 650,
          mealCount: 1
        },
        {
          date: new Date(today.getTime() - 86400000).toISOString().split('T')[0],
          totalAmount: 128.5,
          totalCalories: 1850,
          mealCount: 3
        }
      ],
      monthlyStats: [
        {
          yearMonth: `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}`,
          totalAmount: 3850.0,
          totalCalories: 52000,
          avgDailyCalories: 1675
        }
      ]
    };
  }
}

let instance: AccountingRepository | null = null;

export function getAccountingRepository(): AccountingRepository {
  if (!instance) {
    instance = new AccountingRepository();
  }
  return instance;
}
