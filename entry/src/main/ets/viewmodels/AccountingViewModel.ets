/**
 * Accounting ViewModel
 * 记账与热量视图模型
 */

import { BillRecord, DailyStats, MonthlyStats, AccountingData, ExpenseByCategory, CalorieTrend } from '../models/AccountingModels';
import { getAccountingRepository } from '../repositories/AccountingRepository';
import { getOpenClawAPIService } from '../services/OpenClawAPIService';
import { getGatewayRepository } from '../repositories/GatewayRepository';

export class AccountingViewModel {
  private repository = getAccountingRepository();
  private apiService = getOpenClawAPIService();
  private gatewayRepository = getGatewayRepository();

  bills: BillRecord[] = [];
  dailyStats: DailyStats[] = [];
  monthlyStats: MonthlyStats[] = [];
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
          console.log('[AccountingViewModel] Auto-connecting to gateway:', currentGateway.host, currentGateway.port);
          this.apiService.setGateway(currentGateway);
        } else {
          console.warn('[AccountingViewModel] No current gateway found, API calls may fail');
        }
      }

      const data = await this.repository.getAccountingData();
      if (data) {
        this.bills = data.bills || [];
        this.dailyStats = data.dailyStats || [];
        this.monthlyStats = data.monthlyStats || [];
      } else {
        // Use mock data if API returns null
        const mockData = this.repository.getMockData();
        this.bills = mockData.bills;
        this.dailyStats = mockData.dailyStats;
        this.monthlyStats = mockData.monthlyStats;
      }
    } catch (e) {
      console.error('[AccountingViewModel] Failed to load data:', e);
      this.errorMessage = '加载数据失败';
      // Fallback to mock data
      const mockData = this.repository.getMockData();
      this.bills = mockData.bills;
      this.dailyStats = mockData.dailyStats;
      this.monthlyStats = mockData.monthlyStats;
    } finally {
      this.isLoading = false;
    }
  }

  getBillsByDate(date: string): BillRecord[] {
    return this.bills.filter(bill => bill.date === date);
  }

  getCurrentMonthStats(): MonthlyStats | null {
    const now = new Date();
    const yearMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
    return this.monthlyStats.find(stat => stat.yearMonth === yearMonth) || null;
  }

  getTodayCalories(): number {
    const today = new Date().toISOString().split('T')[0];
    const todayStat = this.dailyStats.find(stat => stat.date === today);
    return todayStat?.totalCalories || 0;
  }

  getTodayExpenses(): number {
    const today = new Date().toISOString().split('T')[0];
    const todayStat = this.dailyStats.find(stat => stat.date === today);
    return todayStat?.totalAmount || 0;
  }

  getMonthlyExpenses(): number {
    const stats = this.getCurrentMonthStats();
    return stats?.totalAmount || 0;
  }

  getMonthlyCalories(): number {
    const stats = this.getCurrentMonthStats();
    return stats?.totalCalories || 0;
  }

  getRecentBills(limit: number = 10): BillRecord[] {
    return this.bills
      .slice()
      .sort((a, b) => b.createdAt - a.createdAt)
      .slice(0, limit);
  }

  getExpensesByCategory(): ExpenseByCategory[] {
    const categoryMap = new Map<string, number>();

    this.bills.forEach(bill => {
      const current = categoryMap.get(bill.category) || 0;
      categoryMap.set(bill.category, current + bill.amount);
    });

    const total = Array.from(categoryMap.values()).reduce((sum, amount) => sum + amount, 0);
    const colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7', '#DDA0DD', '#B0B0B0'];

    const result: ExpenseByCategory[] = [];
    let index = 0;
    categoryMap.forEach((amount, category) => {
      result.push({
        category: category,
        amount: amount,
        percentage: total > 0 ? (amount / total) * 100 : 0,
        color: colors[index % colors.length]
      });
      index++;
    });

    return result.sort((a, b) => b.amount - a.amount);
  }

  getCalorieTrend(days: number = 7): CalorieTrend[] {
    const result: CalorieTrend[] = [];
    const today = new Date();
    const targetCalories = 2000;

    for (let i = days - 1; i >= 0; i--) {
      const date = new Date(today);
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];

      const stat = this.dailyStats.find(s => s.date === dateStr);
      result.push({
        date: dateStr,
        calories: stat?.totalCalories || 0,
        target: targetCalories
      });
    }

    return result;
  }

  getAverageDailyCalories(): number {
    const stats = this.getCurrentMonthStats();
    return stats?.avgDailyCalories || 0;
  }

  getMealCount(): number {
    const today = new Date().toISOString().split('T')[0];
    const todayStat = this.dailyStats.find(stat => stat.date === today);
    return todayStat?.mealCount || 0;
  }
}
