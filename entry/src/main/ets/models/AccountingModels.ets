/**
 * Accounting Models
 * 记账与热量数据模型
 */

export interface BillRecord {
  id: string;
  date: string;
  category: string;
  amount: number;
  currency: string;
  items: string[];
  calories: number;
  note: string;
  createdAt: number;
}

export interface DailyStats {
  date: string;
  totalAmount: number;
  totalCalories: number;
  mealCount: number;
}

export interface MonthlyStats {
  yearMonth: string;
  totalAmount: number;
  totalCalories: number;
  avgDailyCalories: number;
}

export interface AccountingData {
  version: string;
  updatedAt: number;
  bills: BillRecord[];
  dailyStats: DailyStats[];
  monthlyStats: MonthlyStats[];
}

export interface BillCategory {
  name: string;
  icon: string;
  color: string;
}

export const BILL_CATEGORIES: BillCategory[] = [
  { name: '餐饮', icon: '🍽️', color: '#FF6B6B' },
  { name: '交通', icon: '🚗', color: '#4ECDC4' },
  { name: '购物', icon: '🛍️', color: '#45B7D1' },
  { name: '娱乐', icon: '🎮', color: '#96CEB4' },
  { name: '医疗', icon: '💊', color: '#FFEAA7' },
  { name: '教育', icon: '📚', color: '#DDA0DD' },
  { name: '其他', icon: '📦', color: '#B0B0B0' }
];

export interface CalorieTrend {
  date: string;
  calories: number;
  target: number;
}

export interface ExpenseByCategory {
  category: string;
  amount: number;
  percentage: number;
  color: string;
}
