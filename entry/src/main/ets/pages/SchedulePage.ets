/**
 * Schedule Page
 * 日程管理页面
 */

import { router } from '@kit.ArkUI';
import { Spacing as SP } from '../constants';
import { ScheduleViewModel } from '../viewmodels/ScheduleViewModel';
import { ScheduleEvent, CalendarDay, CalendarWeek, CalendarMonth, EVENT_CATEGORIES } from '../models/ScheduleModels';
import { getCalendarSyncService } from '../services/CalendarSyncService';

@Entry
@Component
struct SchedulePage {
  @State viewModel: ScheduleViewModel = new ScheduleViewModel();
  @State currentMonth: number = new Date().getMonth();
  @State currentYear: number = new Date().getFullYear();
  @State selectedDate: string = this.formatLocalDate(new Date());
  @State isSyncing: boolean = false;
  @State syncMessage: string = '';

  private calendarSyncService = getCalendarSyncService();
  private weekdays: string[] = ['日', '一', '二', '三', '四', '五', '六'];

  private formatLocalDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
  private parseDateString(dateStr: string): Date {
    const parts = dateStr.split('-').map(Number);
    const year = parts[0];
    const month = parts[1];
    const day = parts[2];
    return new Date(year, month - 1, day);
  }

  aboutToAppear() {
    this.viewModel.loadData();
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
    const unsynced = this.viewModel.getUnsyncedEvents();
    if (unsynced.length === 0) {
      this.syncMessage = '没有需要同步的日程';
      setTimeout(() => this.syncMessage = '', 2000);
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
      setTimeout(() => this.syncMessage = '', 3000);
    }
  }

  @Builder
  EventItem(event: ScheduleEvent) {
    Row({ space: SP.M }) {
      // Time indicator
      Column({ space: SP.XS }) {
        Text(this.viewModel.formatTime(event.startTime))
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(this.viewModel.formatDuration(event.startTime, event.endTime))
          .fontSize(10)
          .fontColor($r('app.color.text_tertiary'))
      }
      .width(50)
      .alignItems(HorizontalAlign.Start)

      // Category indicator
      Column() {
        Text(this.viewModel.getCategoryIcon(event.category))
          .fontSize(20)
      }
      .width(40)
      .height(40)
      .backgroundColor(this.viewModel.getCategoryColor(event.category) + '20')
      .borderRadius(SP.RADIUS_S)
      .justifyContent(FlexAlign.Center)

      // Event info
      Column({ space: SP.XS }) {
        Text(event.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (event.location) {
          Row({ space: SP.XS }) {
            Text('📍')
              .fontSize(10)
              .fontColor($r('app.color.text_tertiary'))

            Text(event.location)
              .fontSize(10)
              .fontColor($r('app.color.text_tertiary'))
          }
        }

        if (event.description) {
          Text(event.description)
            .fontSize(10)
            .fontColor($r('app.color.text_secondary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // Sync status
      if (event.syncedToCalendar) {
        SymbolGlyph($r('sys.symbol.checkmark_circle_fill'))
          .fontSize(16)
          .fontColor(['#4ECDC4'])
      } else {
        SymbolGlyph($r('sys.symbol.clock'))
          .fontSize(16)
          .fontColor([$r('app.color.text_tertiary')])
      }
    }
    .width('100%')
    .padding(SP.M)
    .backgroundColor($r('app.color.background_primary'))
    .borderRadius(SP.RADIUS_M)
  }

  @Builder
  CalendarDayCell(day: CalendarDay) {
    Column({ space: 2 }) {
      Text(day.dayOfMonth.toString())
        .fontSize(14)
        .fontWeight(day.isToday ? FontWeight.Bold : FontWeight.Regular)
        .fontColor(day.isCurrentMonth
          ? (day.isToday ? $r('app.color.brand_primary') : $r('app.color.text_primary'))
          : $r('app.color.text_tertiary'))

      // Event dots
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
      ? $r('app.color.brand_primary') + '15'
      : (day.isToday ? $r('app.color.brand_primary') + '08' : 'transparent'))
    .borderRadius(SP.RADIUS_S)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.selectedDate = day.date;
    })
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

          Text('日程管理')
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
              // Calendar Section
              Column({ space: SP.M }) {
                // Calendar header
                Row() {
                  Button() {
                    SymbolGlyph($r('sys.symbol.chevron_left'))
                      .fontSize(16)
                      .fontColor([$r('app.color.text_secondary')])
                  }
                  .width(32)
                  .height(32)
                  .backgroundColor('transparent')
                  .onClick(() => this.previousMonth())

                  Text(`${this.currentYear}年${this.currentMonth + 1}月`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_primary'))

                  Button() {
                    SymbolGlyph($r('sys.symbol.chevron_right'))
                      .fontSize(16)
                      .fontColor([$r('app.color.text_secondary')])
                  }
                  .width(32)
                  .height(32)
                  .backgroundColor('transparent')
                  .onClick(() => this.nextMonth())
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)

                // Weekday headers
                Row({ space: 0 }) {
                  ForEach(this.weekdays, (day: string) => {
                    Text(day)
                      .fontSize(12)
                      .fontColor($r('app.color.text_secondary'))
                      .width('100%')
                      .textAlign(TextAlign.Center)
                  }, (day: string) => day)
                }
                .width('100%')

                // Calendar grid
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
              .padding(SP.M)
              .backgroundColor($r('app.color.background_primary'))
              .borderRadius(SP.RADIUS_L)

              // Sync button
              Row({ space: SP.M }) {
                Button('同步到系统日历')
                  .layoutWeight(1)
                  .height(44)
                  .backgroundColor($r('app.color.brand_primary'))
                  .borderRadius(SP.RADIUS_S)
                  .enabled(!this.isSyncing)
                  .onClick(() => this.syncToCalendar())

                if (this.viewModel.getUnsyncedEvents().length > 0) {
                  Text(`${this.viewModel.getUnsyncedEvents().length}待同步`)
                    .fontSize(12)
                    .fontColor($r('app.color.warning'))
                    .padding({ left: SP.S, right: SP.S })
                }
              }
              .width('100%')

              if (this.syncMessage) {
                Text(this.syncMessage)
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                  .width('100%')
                  .textAlign(TextAlign.Center)
              }

              // Selected date events
              Column({ space: SP.M }) {
                Row() {
                  Text(`${this.selectedDate} 日程`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_primary'))

                  Blank()

                  Text(`${this.viewModel.getEventsByDate(new Date(this.selectedDate)).length}个事件`)
                    .fontSize(12)
                    .fontColor($r('app.color.text_secondary'))
                }
                .width('100%')

                if (this.viewModel.getEventsByDate(this.parseDateString(this.selectedDate)).length === 0) {
                  Column({ space: SP.S }) {
                    Text('暂无日程')
                      .fontSize(14)
                      .fontColor($r('app.color.text_secondary'))

                    Text('与 note-bot 对话记录日程')
                      .fontSize(12)
                      .fontColor($r('app.color.text_tertiary'))
                  }
                  .width('100%')
                  .padding({ top: 30, bottom: 30 })
                  .alignItems(HorizontalAlign.Center)
                } else {
                  ForEach(this.viewModel.getEventsByDate(this.parseDateString(this.selectedDate)),
                    (event: ScheduleEvent) => {
                      this.EventItem(event)
                    }, (event: ScheduleEvent) => event.id)
                }
              }
              .width('100%')

              // Today's events summary
              Column({ space: SP.M }) {
                Row() {
                  Text('今日日程')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_primary'))

                  Blank()

                  Text(`${this.viewModel.getTodayEvents().length}个事件`)
                    .fontSize(12)
                    .fontColor($r('app.color.text_secondary'))
                }
                .width('100%')

                if (this.viewModel.getTodayEvents().length === 0) {
                  Text('今天没有安排')
                    .fontSize(12)
                    .fontColor($r('app.color.text_tertiary'))
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
              .padding(SP.M)
              .backgroundColor($r('app.color.background_primary'))
              .borderRadius(SP.RADIUS_L)

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
