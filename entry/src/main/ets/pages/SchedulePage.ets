/**
 * Schedule Page
 * 日程管理页面 - 优化版
 * 遵循主页设计系统规范
 */

import { router } from '@kit.ArkUI';
import { DesignTokens as DT, Spacing as SP, Typography as TYP, Animation as ANI } from '../constants';
import { ScheduleViewModel } from '../viewmodels/ScheduleViewModel';
import { ScheduleEvent, CalendarDay, CalendarWeek, CalendarMonth, EVENT_CATEGORIES } from '../models/ScheduleModels';
import { getCalendarSyncService } from '../services/CalendarSyncService';
import { LoadingState } from '../components/LoadingState';
import { EmptyState } from '../components/EmptyState';
import { HmCard } from '../components/common/HmCard';

@Entry
@Component
struct SchedulePage {
  @State viewModel: ScheduleViewModel = new ScheduleViewModel();
  @State currentMonth: number = new Date().getMonth();
  @State currentYear: number = new Date().getFullYear();
  @State selectedDate: string = '';
  @State isSyncing: boolean = false;
  @State syncMessage: string = '';
  @State isDark: boolean = false;

  // Safe area for immersive mode
  @State topSafeArea: number = 37  // 顶部状态栏高度

  private calendarSyncService = getCalendarSyncService();
  private weekdays: string[] = ['日', '一', '二', '三', '四', '五', '六'];
  private syncMessageTimer: number = -1;

  private formatLocalDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  private parseDateString(dateStr: string): Date {
    const parts = dateStr.split('-').map(Number);
    return new Date(parts[0], parts[1] - 1, parts[2]);
  }

  aboutToAppear() {
    this.selectedDate = this.formatLocalDate(new Date());
    this.viewModel.loadData();
  }

  onPageShow() {
    this.viewModel.loadData();
  }

  aboutToDisappear() {
    if (this.syncMessageTimer !== -1) {
      clearTimeout(this.syncMessageTimer);
      this.syncMessageTimer = -1;
    }
  }

  private previousMonth() {
    if (this.currentMonth === 0) {
      this.currentMonth = 11;
      this.currentYear--;
    } else {
      this.currentMonth--;
    }
  }

  private nextMonth() {
    if (this.currentMonth === 11) {
      this.currentMonth = 0;
      this.currentYear++;
    } else {
      this.currentMonth++;
    }
  }

  private async syncToCalendar() {
    if (this.syncMessageTimer !== -1) {
      clearTimeout(this.syncMessageTimer);
      this.syncMessageTimer = -1;
    }

    const unsynced = this.viewModel.getUnsyncedEvents();
    if (unsynced.length === 0) {
      this.syncMessage = '没有需要同步的日程';
      this.syncMessageTimer = setTimeout(() => this.syncMessage = '', 2000);
      return;
    }

    this.isSyncing = true;
    this.syncMessage = '同步中...';

    try {
      const result = await this.viewModel.syncAllToCalendar();
      this.syncMessage = `同步完成: ${result.success}成功, ${result.failed}失败`;
    } catch (e) {
      this.syncMessage = '同步失败';
    } finally {
      this.isSyncing = false;
      this.syncMessageTimer = setTimeout(() => this.syncMessage = '', 3000);
    }
  }

  @Builder
  EventItem(event: ScheduleEvent) {
    HmCard({
      cardPadding: SP.M,
      cardBgColor: DT.getSurfaceColor(this.isDark),
      cardBorderRadius: SP.RADIUS_M,
      cardClickable: true,
      shadowLevel: 'resting'
    }) {
      Row({ space: SP.M }) {
        Column({ space: SP.XS }) {
          Text(this.viewModel.formatTime(event.startTime))
            .fontSize(TYP.SIZE_CAPTION)
            .fontWeight(TYP.WEIGHT_MEDIUM)
            .fontColor(DT.getTextPrimary(this.isDark))

          Text(this.viewModel.formatDuration(event.startTime, event.endTime))
            .fontSize(TYP.SIZE_SMALL)
            .fontColor(DT.getTextSecondary(this.isDark))
        }
        .width(50)
        .alignItems(HorizontalAlign.Start)

        Column() {
          Text(this.viewModel.getCategoryIcon(event.category))
            .fontSize(20)
        }
        .width(40)
        .height(40)
        .backgroundColor(this.viewModel.getCategoryColor(event.category) + '20')
        .borderRadius(SP.RADIUS_M)
        .justifyContent(FlexAlign.Center)

        Column({ space: SP.XS }) {
          Text(event.title)
            .fontSize(TYP.SIZE_BODY)
            .fontWeight(TYP.WEIGHT_MEDIUM)
            .fontColor(DT.getTextPrimary(this.isDark))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (event.location) {
            Row({ space: SP.XS }) {
              Text('📍')
                .fontSize(TYP.SIZE_SMALL)
                .fontColor(DT.getTextSecondary(this.isDark))
              Text(event.location)
                .fontSize(TYP.SIZE_SMALL)
                .fontColor(DT.getTextSecondary(this.isDark))
            }
          }

          if (event.description) {
            Text(event.description)
              .fontSize(TYP.SIZE_SMALL)
              .fontColor(DT.getTextSecondary(this.isDark))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        if (event.syncedToCalendar) {
          Text('✓')
            .fontSize(16)
            .fontColor(DT.SUCCESS)
        } else {
          Text('⏰')
            .fontSize(16)
            .fontColor(DT.getTextSecondary(this.isDark))
        }
      }
      .width('100%')
    }
  }

  @Builder
  CalendarDayCell(day: CalendarDay) {
    Column({ space: 2 }) {
      Text(day.dayOfMonth.toString())
        .fontSize(TYP.SIZE_BODY)
        .fontWeight(day.isToday ? TYP.WEIGHT_BOLD : TYP.WEIGHT_NORMAL)
        .fontColor(day.isCurrentMonth
          ? (day.isToday ? DT.BRAND_PRIMARY : DT.getTextPrimary(this.isDark))
          : DT.getTextSecondary(this.isDark))

      if (day.events.length > 0) {
        Row({ space: 2 }) {
          ForEach(day.events.slice(0, 3), (event: ScheduleEvent) => {
            Column()
              .width(4)
              .height(4)
              .backgroundColor(this.viewModel.getCategoryColor(event.category))
              .borderRadius(2)
          }, (event: ScheduleEvent) => event.id)
        }
      } else {
        Column().height(6)
      }
    }
    .layoutWeight(1)
    .height(50)
    .backgroundColor(this.selectedDate === day.date
      ? DT.BRAND_PRIMARY + '15'
      : (day.isToday ? DT.BRAND_PRIMARY + '08' : 'transparent'))
    .borderRadius(SP.RADIUS_S)
    .justifyContent(FlexAlign.Center)
    .scale({ x: 1, y: 1 })
    .animation(ANI.pressFeedbackFine())
    .onClick(() => {
      this.selectedDate = day.date;
    })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column({ space: 0 }) {
        // 顶部安全区域占位
        Column()
          .width('100%')
          .height(this.topSafeArea)
          .backgroundColor(DT.getBackgroundColor(this.isDark))

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

          Text('日程管理')
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

        if (this.viewModel.isLoading) {
          LoadingState({
            message: '加载中...',
            mode: 'skeleton-card'
          })
            .layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: SP.L }) {
              HmCard({
                cardPadding: SP.M,
                cardBgColor: DT.getSurfaceColor(this.isDark),
                cardBorderRadius: SP.RADIUS_L
              }) {
                Column({ space: SP.M }) {
                  Row() {
                    Button() {
                      Text('‹')
                        .fontSize(20)
                        .fontColor(DT.getTextSecondary(this.isDark))
                    }
                    .width(32)
                    .height(32)
                    .backgroundColor('transparent')
                    .scale({ x: 1, y: 1 })
                    .animation(ANI.pressFeedbackFine())
                    .onClick(() => this.previousMonth())

                    Text(`${this.currentYear}年${this.currentMonth + 1}月`)
                      .fontSize(TYP.SIZE_H3)
                      .fontWeight(TYP.WEIGHT_MEDIUM)
                      .fontColor(DT.getTextPrimary(this.isDark))

                    Button() {
                      Text('›')
                        .fontSize(20)
                        .fontColor(DT.getTextSecondary(this.isDark))
                    }
                    .width(32)
                    .height(32)
                    .backgroundColor('transparent')
                    .scale({ x: 1, y: 1 })
                    .animation(ANI.pressFeedbackFine())
                    .onClick(() => this.nextMonth())
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)

                  Row({ space: 0 }) {
                    ForEach(this.weekdays, (day: string) => {
                      Text(day)
                        .fontSize(TYP.SIZE_CAPTION)
                        .fontColor(DT.getTextSecondary(this.isDark))
                        .width('100%')
                        .textAlign(TextAlign.Center)
                    }, (day: string) => day)
                  }
                  .width('100%')

                  Column({ space: 0 }) {
                    ForEach(this.viewModel.generateCalendarMonth(this.currentYear, this.currentMonth).weeks,
                      (week: CalendarWeek, weekIndex: number) => {
                        Row({ space: 0 }) {
                          ForEach(week.days, (day: CalendarDay) => {
                            this.CalendarDayCell(day)
                          }, (day: CalendarDay) => day.date)
                        }
                        .width('100%')
                      }, (week: CalendarWeek, index: number) => `${this.currentYear}-${this.currentMonth}-${index}`)
                  }
                  .width('100%')
                }
                .width('100%')
              }

              Row({ space: SP.M }) {
                Button('同步到系统日历')
                  .layoutWeight(1)
                  .height(44)
                  .backgroundColor(DT.BRAND_PRIMARY)
                  .borderRadius(SP.RADIUS_M)
                  .fontSize(TYP.SIZE_BODY)
                  .fontWeight(TYP.WEIGHT_MEDIUM)
                  .enabled(!this.isSyncing)
                  .scale({ x: 1, y: 1 })
                  .animation(ANI.pressFeedbackFine())
                  .onClick(() => this.syncToCalendar())

                if (this.viewModel.getUnsyncedEvents().length > 0) {
                  Text(`${this.viewModel.getUnsyncedEvents().length}待同步`)
                    .fontSize(TYP.SIZE_CAPTION)
                    .fontColor(DT.WARNING)
                    .padding({ left: SP.S, right: SP.S })
                }
              }
              .width('100%')

              if (this.syncMessage) {
                Text(this.syncMessage)
                  .fontSize(TYP.SIZE_CAPTION)
                  .fontColor(DT.getTextSecondary(this.isDark))
                  .width('100%')
                  .textAlign(TextAlign.Center)
              }

              Column({ space: SP.M }) {
                Row() {
                  Text(`${this.selectedDate} 日程`)
                    .fontSize(TYP.SIZE_H3)
                    .fontWeight(TYP.WEIGHT_MEDIUM)
                    .fontColor(DT.getTextPrimary(this.isDark))

                  Blank()

                  Text(`${this.viewModel.getEventsByDate(new Date(this.selectedDate)).length}个事件`)
                    .fontSize(TYP.SIZE_CAPTION)
                    .fontColor(DT.getTextSecondary(this.isDark))
                }
                .width('100%')

                if (this.viewModel.getEventsByDate(this.parseDateString(this.selectedDate)).length === 0) {
                  EmptyState({
                    icon: '📅',
                    title: '暂无日程',
                    message: '与 note-bot 对话记录日程',
                    actionText: '刷新',
                    onAction: () => {
                      this.viewModel.loadData();
                    }
                  })
                    .padding({ top: 30, bottom: 30 })
                } else {
                  ForEach(this.viewModel.getEventsByDate(this.parseDateString(this.selectedDate)),
                    (event: ScheduleEvent) => {
                      this.EventItem(event)
                    }, (event: ScheduleEvent) => event.id)
                }
              }
              .width('100%')

              HmCard({
                cardPadding: SP.M,
                cardBgColor: DT.getSurfaceColor(this.isDark),
                cardBorderRadius: SP.RADIUS_L
              }) {
                Column({ space: SP.M }) {
                  Row() {
                    Text('今日日程')
                      .fontSize(TYP.SIZE_H3)
                      .fontWeight(TYP.WEIGHT_MEDIUM)
                      .fontColor(DT.getTextPrimary(this.isDark))

                    Blank()

                    Text(`${this.viewModel.getTodayEvents().length}个事件`)
                      .fontSize(TYP.SIZE_CAPTION)
                      .fontColor(DT.getTextSecondary(this.isDark))
                  }
                  .width('100%')

                  if (this.viewModel.getTodayEvents().length === 0) {
                    Text('今天没有安排')
                      .fontSize(TYP.SIZE_BODY)
                      .fontColor(DT.getTextSecondary(this.isDark))
                      .width('100%')
                      .padding({ top: 20, bottom: 20 })
                      .textAlign(TextAlign.Center)
                  } else {
                    ForEach(this.viewModel.getTodayEvents(),
                      (event: ScheduleEvent) => {
                        this.EventItem(event)
                      }, (event: ScheduleEvent) => event.id)
                  }
                }
                .width('100%')
              }

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
