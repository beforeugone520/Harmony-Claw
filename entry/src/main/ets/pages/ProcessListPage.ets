/**
 * ProcessListPage.ets
 * 进程监控页面 - HarmonyOS 6 风格
 */
import { router } from '@kit.ArkUI'
import { ProcessViewModel } from '../viewmodels/ProcessViewModel'
import { ProcessCard } from '../components/process/ProcessCard'
import { Process } from '../models/Process'
import { DesignTokens as DT, Spacing as SP, Typography as TYP, Animation as ANI } from '../constants'
import { HmInfoCard, ToastManager } from '../components/common'
import { LoadingState } from '../components/LoadingState'
import { EmptyState } from '../components/EmptyState'

@Entry
@Component
struct ProcessListPage {
  @State viewModel: ProcessViewModel = new ProcessViewModel()
  @State isRefreshing: boolean = false
  @State autoRefresh: boolean = false
  @State isDark: boolean = false
  private refreshTimer: number = -1

  // Safe area for immersive mode
  @State topSafeArea: number = 37

  aboutToAppear() {
    this.viewModel.initialize()
    this.startAutoRefresh()
  }

  aboutToDisappear() {
    this.stopAutoRefresh()
  }

  private startAutoRefresh() {
    this.autoRefresh = true
    this.refreshTimer = setInterval(() => {
      if (this.autoRefresh && !this.viewModel.isLoading) {
        this.viewModel.refresh()
      }
    }, 10000)
  }

  private stopAutoRefresh() {
    this.autoRefresh = false
    if (this.refreshTimer !== -1) {
      clearInterval(this.refreshTimer)
      this.refreshTimer = -1
    }
  }

  private async handleRefresh(): Promise<void> {
    this.isRefreshing = true
    await this.viewModel.refresh()
    this.isRefreshing = false
    ToastManager.success('已刷新')
  }

  @Builder
  statsBuilder() {
    Row({ space: SP.CARD_GAP }) {
      HmInfoCard({
        infoTitle: '运行中',
        infoValue: String(this.viewModel.getRunningCount()),
        infoIcon: '⚙️',
        infoIconBg: DT.SUCCESS_BG,
        infoIconColor: DT.SUCCESS
      })
        .layoutWeight(1)

      HmInfoCard({
        infoTitle: '内存',
        infoValue: `${this.viewModel.getTotalMemoryUsage().toFixed(0)}`,
        infoUnit: 'MB',
        infoIcon: '💾',
        infoIconBg: DT.WARNING_BG,
        infoIconColor: DT.WARNING
      })
        .layoutWeight(1)
    }
    .width('100%')
    .padding({
      left: SP.PAGE_HORIZONTAL,
      right: SP.PAGE_HORIZONTAL,
      top: SP.M
    })
  }

  @Builder
  HeaderBuilder() {
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

      Text('进程监控')
        .fontSize(TYP.SIZE_H2)
        .fontWeight(TYP.WEIGHT_MEDIUM)
        .fontColor(DT.getTextPrimary(this.isDark))

      Blank()

      Button('↻')
        .width(44)
        .height(44)
        .backgroundColor('transparent')
        .fontColor(DT.BRAND_PRIMARY)
        .fontSize(22)
        .enabled(!this.viewModel.isLoading)
        .scale({ x: 1, y: 1 })
        .animation(ANI.pressFeedbackFine())
        .onClick(() => {
          this.handleRefresh()
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: SP.S, right: SP.M })
    .backgroundColor(DT.getBackgroundColor(this.isDark))
  }

  build() {
    Column({ space: 0 }) {
      // 顶部安全区域占位
      Column()
        .width('100%')
        .height(this.topSafeArea)
        .backgroundColor(DT.getBackgroundColor(this.isDark))

      // Header
      this.HeaderBuilder()

      // Stats
      this.statsBuilder()

      // Content
      if (this.viewModel.isLoading && this.viewModel.processes.length === 0) {
        LoadingState({ message: '加载中...', mode: 'skeleton-list' })
          .layoutWeight(1)
      } else if (this.viewModel.processes.length === 0) {
        EmptyState({
          icon: '⚙️',
          title: '暂无进程',
          message: '当前没有运行中的进程',
          actionText: '刷新',
          onAction: (): void => { this.handleRefresh() }
        })
          .layoutWeight(1)
      } else {
        Refresh({ refreshing: $$this.isRefreshing }) {
          List({ space: SP.CARD_GAP }) {
            ForEach(this.viewModel.processes, (process: Process) => {
              ListItem() {
                ProcessCard({
                  process: process
                })
              }
            }, (process: Process) => process.id)
          }
          .width('100%')
          .padding(SP.PAGE_HORIZONTAL)
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring)
        }
        .onRefreshing(() => this.handleRefresh())
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DT.getBackgroundColor(this.isDark))
  }

  // 页面转场动画
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 200, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
  }
}
