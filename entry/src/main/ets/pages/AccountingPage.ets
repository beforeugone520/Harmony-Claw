/**
 * Accounting Page
 * 记账与热量管理页面
 */

import { router } from '@kit.ArkUI';
import { Spacing as SP } from '../constants';
import { AccountingViewModel } from '../viewmodels/AccountingViewModel';
import { LineChart } from '../components/charts/LineChart';
import { PieChart } from '../components/charts/PieChart';
import { BillRecord, BILL_CATEGORIES } from '../models/AccountingModels';

@Entry
@Component
struct AccountingPage {
  @State viewModel: AccountingViewModel = new AccountingViewModel();
  @State selectedTab: number = 0; // 0: overview, 1: bills

  aboutToAppear() {
    this.viewModel.loadData();
  }

  @Builder
  StatCard(title: string, value: string, subtitle: string, color: ResourceColor) {
    Column({ space: SP.XS }) {
      Text(title)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))

      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)

      Text(subtitle)
        .fontSize(10)
        .fontColor($r('app.color.text_tertiary'))
    }
    .layoutWeight(1)
    .padding(SP.M)
    .backgroundColor($r('app.color.background_primary'))
    .borderRadius(SP.RADIUS_M)
    .shadow({ radius: 4, color: $r('app.color.shadow'), offsetX: 0, offsetY: 1 })
  }

  @Builder
  BillItem(bill: BillRecord) {
    Row({ space: SP.M }) {
      // Category icon
      Column() {
        Text(this.getCategoryIcon(bill.category))
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .backgroundColor(this.getCategoryColor(bill.category) + '20')
      .borderRadius(SP.RADIUS_S)
      .justifyContent(FlexAlign.Center)

      // Bill info
      Column({ space: SP.XS }) {
        Text((bill.items && bill.items.length > 0 ? bill.items.join(', ') : bill.category))
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: SP.XS }) {
          Text(bill.category)
            .fontSize(10)
            .fontColor($r('app.color.text_secondary'))
            .padding({ left: 4, right: 4, top: 2, bottom: 2 })
            .backgroundColor($r('app.color.background_secondary'))
            .borderRadius(4)

          if (bill.calories > 0) {
            Text(`${bill.calories}大卡`)
              .fontSize(10)
              .fontColor($r('app.color.warning'))
          }
        }

        if (bill.note) {
          Text(bill.note)
            .fontSize(10)
            .fontColor($r('app.color.text_tertiary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // Amount and date
      Column({ space: SP.XS }) {
        Text(`¥${bill.amount.toFixed(2)}`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(bill.date)
          .fontSize(10)
          .fontColor($r('app.color.text_tertiary'))
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding(SP.M)
    .backgroundColor($r('app.color.background_primary'))
    .borderRadius(SP.RADIUS_M)
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
      Column({ space: 0 }) {
        // Header
        Row() {
          Button() {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(24)
              .fontColor([$r('app.color.text_primary')])
          }
          .width(40)
          .height(40)
          .backgroundColor('transparent')
          .onClick(() => {
            router.back();
          })

          Text('记账热量')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          Blank()

          Button() {
            SymbolGlyph($r('sys.symbol.arrow_clockwise'))
              .fontSize(20)
              .fontColor([$r('app.color.brand_primary')])
          }
          .width(40)
          .height(40)
          .backgroundColor('transparent')
          .enabled(!this.viewModel.isLoading)
          .onClick(() => {
            this.viewModel.loadData();
          })
        }
        .width('100%')
        .height(56)
        .padding({ left: SP.S, right: SP.M })

        // Tab Switcher
        Row({ space: 0 }) {
          Column() {
            Text('概览')
              .fontSize(14)
              .fontWeight(this.selectedTab === 0 ? FontWeight.Medium : FontWeight.Regular)
              .fontColor(this.selectedTab === 0 ? $r('app.color.brand_primary') : $r('app.color.text_secondary'))
            Divider()
              .width('60%')
              .height(2)
              .color(this.selectedTab === 0 ? $r('app.color.brand_primary') : 'transparent')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.selectedTab = 0;
          })

          Column() {
            Text('账单明细')
              .fontSize(14)
              .fontWeight(this.selectedTab === 1 ? FontWeight.Medium : FontWeight.Regular)
              .fontColor(this.selectedTab === 1 ? $r('app.color.brand_primary') : $r('app.color.text_secondary'))
            Divider()
              .width('60%')
              .height(2)
              .color(this.selectedTab === 1 ? $r('app.color.brand_primary') : 'transparent')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.selectedTab = 1;
          })
        }
        .width('100%')
        .padding({ left: SP.L, right: SP.L })

        if (this.viewModel.isLoading) {
          Column({ space: SP.M }) {
            LoadingProgress()
              .width(40)
              .height(40)
              .color($r('app.color.brand_primary'))

            Text('加载中...')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: SP.L }) {
              if (this.selectedTab === 0) {
                // Overview Tab
                // Stats Cards
                Row({ space: SP.M }) {
                  this.StatCard(
                    '本月支出',
                    `¥${this.viewModel.getMonthlyExpenses().toFixed(0)}`,
                    '累计金额',
                    $r('app.color.brand_primary')
                  );

                  this.StatCard(
                    '今日热量',
                    `${this.viewModel.getTodayCalories()}`,
                    '大卡摄入',
                    $r('app.color.warning')
                  );

                  this.StatCard(
                    '月均热量',
                    `${this.viewModel.getAverageDailyCalories()}`,
                    '大卡/天',
                    $r('app.color.success')
                  );
                }
                .width('100%')

                // Calorie Trend Chart
                LineChart({
                  data: this.viewModel.getCalorieTrend(7),
                  title: '最近7天热量趋势',
                  lineColor: $r('app.color.brand_primary'),
                  targetColor: '#FF6B6B',
                  showTarget: true
                })

                // Expense by Category
                PieChart({
                  data: this.viewModel.getExpensesByCategory(),
                  title: '支出分类占比',
                  showLegend: true
                })
              } else {
                // Bills Tab
                Column({ space: SP.M }) {
                  Text('最近账单')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_primary'))
                    .width('100%')

                  if (this.viewModel.bills.length === 0) {
                    Column({ space: SP.S }) {
                      Text('暂无账单记录')
                        .fontSize(14)
                        .fontColor($r('app.color.text_secondary'))

                      Text('与 accounting-bot 对话记录账单')
                        .fontSize(12)
                        .fontColor($r('app.color.text_tertiary'))
                    }
                    .width('100%')
                    .padding({ top: 50 })
                    .alignItems(HorizontalAlign.Center)
                  } else {
                    ForEach(this.viewModel.getRecentBills(20), (bill: BillRecord) => {
                      this.BillItem(bill)
                    }, (bill: BillRecord) => bill.id)
                  }
                }
                .width('100%')
              }

              // Bottom spacing
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
      .backgroundColor($r('app.color.background_secondary'))
    }
    .width('100%')
    .height('100%')
  }

  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 200, curve: Curve.EaseIn })
      .slide(SlideEffect.Left)
  }
}
