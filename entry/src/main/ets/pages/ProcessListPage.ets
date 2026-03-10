/**
 * ProcessListPage.ets
 * 进程监控页面 - HarmonyOS 6 风格
 */
import { ProcessViewModel } from '../viewmodels/ProcessViewModel'
import { ProcessCard } from '../components/process/ProcessCard'
import { Process } from '../models/Process'
import { DesignTokens as DT, Spacing as SP, Typography as TYP } from '../constants'
import { HmInfoCard, ToastManager } from '../components/common'
import { LoadingState } from '../components/LoadingState'
import { EmptyState } from '../components/EmptyState'

@Entry
@Component
struct ProcessListPage {
  @State viewModel: ProcessViewModel = new ProcessViewModel()
  @State isRefreshing: boolean = false
  @State autoRefresh: boolean = false
  private refreshTimer: number = -1

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

  private async handleRefresh() {
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

  build() {
    Navigation() {
      Column({ space: SP.CARD_GAP }) {
        // Stats
        this.statsBuilder()

        // Content
        if (this.viewModel.isLoading && this.viewModel.processes.length === 0) {
          LoadingState({ message: '加载中...' })
        } else if (this.viewModel.processes.length === 0) {
          EmptyState({
            title: '暂无进程',
            message: '当前没有运行中的进程'
          })
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
      .backgroundColor(DT.LIGHT_BG_SECONDARY)
    }
    .title('进程监控')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .backgroundColor(DT.LIGHT_BG_SECONDARY)
  }
}
