/**
 * Accounting Page
 * 记账与热量管理页面 - 优化版
 * 遵循主页设计系统规范
 */

import { router } from '@kit.ArkUI';
import { DesignTokens as DT, Spacing as SP, Typography as TYP, Animation as ANI } from '../constants';
import { AccountingViewModel } from '../viewmodels/AccountingViewModel';
import { LineChart } from '../components/charts/LineChart';
import { PieChart } from '../components/charts/PieChart';
import { BillRecord, BILL_CATEGORIES } from '../models/AccountingModels';
import { LoadingState } from '../components/LoadingState';
import { EmptyState } from '../components/EmptyState';
import { HmCard } from '../components/common/HmCard';

@Entry
@Component
struct AccountingPage {
  @State viewModel: AccountingViewModel = new AccountingViewModel();
  @State selectedTab: number = 0;
  @State isDark: boolean = false;
  @State headerOpacity: number = 0;

  // Safe area for immersive mode
  @State topSafeArea: number = 37  // 顶部状态栏高度

  aboutToAppear() {
    this.viewModel.loadData();
  }

  onPageShow() {
    this.viewModel.loadData();
  }

  // 统计卡片组件 - 使用设计系统
  @Builder
  StatCard(title: string, value: string, subtitle: string, color: string) {
    HmCard({
      cardPadding: SP.M,
      cardBgColor: DT.getSurfaceColor(this.isDark),
      cardBorderRadius: SP.RADIUS_L,
      shadowLevel: 'resting'
    }) {
      Column({ space: SP.XS }) {
        Text(title)
          .fontSize(TYP.SIZE_CAPTION)
          .fontColor(DT.getTextSecondary(this.isDark))

        Text(value)
          .fontSize(24)
          .fontWeight(TYP.WEIGHT_BOLD)
          .fontColor(color)

        Text(subtitle)
          .fontSize(TYP.SIZE_SMALL)
          .fontColor(DT.getTextSecondary(this.isDark))
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
  }

  // Tab切换器 - 按压反馈优化
  @Builder
  TabItem(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(TYP.SIZE_BODY)
        .fontWeight(this.selectedTab === index ? TYP.WEIGHT_MEDIUM : TYP.WEIGHT_NORMAL)
        .fontColor(this.selectedTab === index ? DT.BRAND_PRIMARY : DT.getTextSecondary(this.isDark))

      Divider()
        .width('60%')
        .height(2)
        .color(this.selectedTab === index ? DT.BRAND_PRIMARY : 'transparent')
        .margin({ top: 4 })
        .animation({ duration: ANI.DURATION_FAST, curve: Curve.EaseOut })
    }
    .layoutWeight(1)
    .height(40)
    .justifyContent(FlexAlign.Center)
    .scale({ x: this.selectedTab === index ? 1 : 0.97, y: this.selectedTab === index ? 1 : 0.97 })
    .animation(ANI.pressFeedbackFine())
    .onClick(() => {
      this.selectedTab = index;
    })
  }

  // 账单项 - 按压反馈优化
  @Builder
  BillItem(bill: BillRecord, index: number) {
    HmCard({
      cardPadding: SP.M,
      cardBgColor: DT.getSurfaceColor(this.isDark),
      cardBorderRadius: SP.RADIUS_M,
      cardClickable: true,
      shadowLevel: 'resting'
    }) {
      Row({ space: SP.M }) {
        // 分类图标
        Column() {
          Text(this.getCategoryIcon(bill.category))
            .fontSize(24)
        }
        .width(48)
        .height(48)
        .backgroundColor(this.getCategoryColor(bill.category) + '20')
        .borderRadius(SP.RADIUS_M)
        .justifyContent(FlexAlign.Center)

        // 账单信息
        Column({ space: SP.XS }) {
          Text((bill.items && bill.items.length > 0 ? bill.items.join(', ') : bill.category))
            .fontSize(TYP.SIZE_BODY)
            .fontColor(DT.getTextPrimary(this.isDark))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row({ space: SP.XS }) {
            Text(bill.category)
              .fontSize(TYP.SIZE_SMALL)
              .fontColor(DT.getTextSecondary(this.isDark))
              .padding({ left: 4, right: 4, top: 2, bottom: 2 })
              .backgroundColor(DT.LIGHT_BG_PRIMARY)
              .borderRadius(SP.RADIUS_XS)

            if (bill.calories > 0) {
              Text(`${bill.calories}大卡`)
                .fontSize(TYP.SIZE_SMALL)
                .fontColor(DT.WARNING)
            }
          }

          if (bill.note) {
            Text(bill.note)
              .fontSize(TYP.SIZE_SMALL)
              .fontColor(DT.getTextSecondary(this.isDark))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 金额和日期
        Column({ space: SP.XS }) {
          Text(`¥${bill.amount.toFixed(2)}`)
            .fontSize(TYP.SIZE_H3)
            .fontWeight(TYP.WEIGHT_MEDIUM)
            .fontColor(DT.getTextPrimary(this.isDark))

          Text(bill.date)
            .fontSize(TYP.SIZE_SMALL)
            .fontColor(DT.getTextSecondary(this.isDark))
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
    }
  }

  getCategoryIcon(category: string): string {
    const cat = BILL_CATEGORIES.find(c => c.name === category);
    return cat?.icon || '📦';
  }

  getCategoryColor(category: string): string {
    const cat = BILL_CATEGORIES.find(c => c.name === category);
    return cat?.color || '#B0B0B0';
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 内容区域
      Column({ space: 0 }) {
        // 顶部安全区域占位
        Column()
          .width('100%')
          .height(this.topSafeArea)
          .backgroundColor(DT.getBackgroundColor(this.isDark))

        // 头部导航栏 - 统一风格
        Row() {
          Button() {
            Text('‹')
              .fontSize(28)
              .fontWeight(TYP.WEIGHT_MEDIUM)
              .fontColor(DT.getTextPrimary(this.isDark))
          }
          .width(44)
          .height(44)
          .backgroundColor('transparent')
          .scale({ x: 1, y: 1 })
          .animation(ANI.pressFeedbackFine())
          .onClick(() => {
            router.back();
          })

          Text('记账热量')
            .fontSize(TYP.SIZE_H2)
            .fontWeight(TYP.WEIGHT_MEDIUM)
            .fontColor(DT.getTextPrimary(this.isDark))

          Blank()

          Button() {
            Text('↻')
              .fontSize(22)
              .fontColor(DT.BRAND_PRIMARY)
          }
          .width(44)
          .height(44)
          .backgroundColor('transparent')
          .enabled(!this.viewModel.isLoading)
          .scale({ x: 1, y: 1 })
          .animation(ANI.pressFeedbackFine())
          .onClick(() => {
            this.viewModel.loadData();
          })
        }
        .width('100%')
        .height(56)
        .padding({ left: SP.S, right: SP.M })
        .backgroundColor(DT.getBackgroundColor(this.isDark))

        // Tab切换器
        Row({ space: 0 }) {
          this.TabItem('概览', 0)
          this.TabItem('账单明细', 1)
        }
        .width('100%')
        .padding({ left: SP.L, right: SP.L, bottom: SP.M })
        .backgroundColor(DT.getBackgroundColor(this.isDark))

        if (this.viewModel.isLoading) {
          // 使用新的LoadingState组件
          LoadingState({
            message: '加载中...',
            mode: 'skeleton-card'
          })
            .layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: SP.L }) {
              if (this.selectedTab === 0) {
                // 概览Tab
                // 统计卡片行
                Row({ space: SP.M }) {
                  this.StatCard(
                    '本月支出',
                    `¥${this.viewModel.getMonthlyExpenses().toFixed(0)}`,
                    '累计金额',
                    DT.BRAND_PRIMARY
                  );

                  this.StatCard(
                    '今日热量',
                    `${this.viewModel.getTodayCalories()}`,
                    '大卡摄入',
                    DT.WARNING
                  );

                  this.StatCard(
                    '月均热量',
                    `${this.viewModel.getAverageDailyCalories()}`,
                    '大卡/天',
                    DT.SUCCESS
                  );
                }
                .width('100%')

                // 热量趋势图
                HmCard({
                  cardPadding: SP.L,
                  cardBgColor: DT.getSurfaceColor(this.isDark),
                  cardBorderRadius: SP.RADIUS_L
                }) {
                  LineChart({
                    data: this.viewModel.getCalorieTrend(7),
                    title: '最近7天热量趋势',
                    lineColor: DT.BRAND_PRIMARY,
                    targetColor: '#FF6B6B',
                    showTarget: true,
                    isDark: this.isDark
                  })
                }

                // 支出分类饼图
                HmCard({
                  cardPadding: SP.L,
                  cardBgColor: DT.getSurfaceColor(this.isDark),
                  cardBorderRadius: SP.RADIUS_L
                }) {
                  PieChart({
                    data: this.viewModel.getExpensesByCategory(),
                    title: '支出分类占比',
                    showLegend: true,
                    isDark: this.isDark
                  })
                }
              } else {
                // 账单明细Tab
                Column({ space: SP.M }) {
                  if (this.viewModel.bills.length === 0) {
                    // 使用新的EmptyState组件
                    EmptyState({
                      icon: '📭',
                      title: '暂无账单记录',
                      message: '与 accounting-bot 对话记录账单',
                      actionText: '刷新',
                      onAction: () => {
                        this.viewModel.loadData();
                      }
                    })
                      .padding({ top: 50 })
                  } else {
                    ForEach(this.viewModel.getRecentBills(20), (bill: BillRecord, index: number) => {
                      this.BillItem(bill, index)
                    }, (bill: BillRecord) => bill.id)
                  }
                }
                .width('100%')
              }

              // 底部间距
              Column().height(20)
            }
            .width('100%')
            .padding(SP.L)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(DT.getBackgroundColor(this.isDark))
    }
    .width('100%')
    .height('100%')
  }

  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 200, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
  }
}
