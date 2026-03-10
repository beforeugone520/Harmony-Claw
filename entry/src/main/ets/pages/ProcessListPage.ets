/**
 * ProcessListPage.ets
 * 进程监控页面 - HarmonyOS 6 风格
 */
import { ProcessViewModel } from '../viewmodels/ProcessViewModel'
import { ProcessCard } from '../components/process/ProcessCard'
import { Process } from '../models/Process'
import { DesignTokens as DT, Spacing as SP, Typography as TYP } from '../constants'
import { HmButton, HmInfoCard, HmConfirmDialog, ToastManager } from '../components/common'
import { LoadingState } from '../components/LoadingState'
import { EmptyState } from '../components/EmptyState'

@Entry
@Component
struct ProcessListPage {
  @State viewModel: ProcessViewModel = new ProcessViewModel()
  @State isRefreshing: boolean = false
  @State showTerminateDialog: boolean = false
  @State processToTerminate: Process | null = null
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

  private async handleTerminateProcess() {
    if (!this.processToTerminate) return

    ToastManager.loading('终止中...')
    try {
      await this.viewModel.terminateProcess(this.processToTerminate.id)
      ToastManager.success('进程已终止')
    } catch (e) {
      ToastManager.error('终止失败')
    } finally {
      ToastManager.hideLoading()
      this.processToTerminate = null
    }
  }

  private toggleAutoRefresh() {
    this.autoRefresh = !this.autoRefresh
    if (this.autoRefresh) {
      this.startAutoRefresh()
      ToastManager.info('已开启自动刷新')
    } else {
      this.stopAutoRefresh()
      ToastManager.info('已关闭自动刷新')
    }
  }

  build() {
    Navigation() {
      Column({ space: SP.CARD_GAP }) {
        // 统计卡片区域
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
            infoTitle: 'CPU',
            infoValue: `${this.viewModel.getTotalCpuUsage().toFixed(1)}`,
            infoUnit: '%',
            infoIcon: '💻',
            infoIconBg: DT.BRAND_LIGHT,
            infoIconColor: DT.BRAND_PRIMARY
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

        // 工具栏
        Row({ space: SP.M }) {
          Row({ space: SP.S }) {
            Toggle({ type: ToggleType.Switch, isOn: $$this.autoRefresh })
              .selectedColor(DT.BRAND_PRIMARY)
              .onChange((isOn: boolean) => {
                this.toggleAutoRefresh()
              })
            Text('自动刷新')
              .fontSize(TYP.SIZE_CAPTION)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
          }

          Blank()

          HmButton({
            btnText: '刷新',
            btnType: 1,
            btnWidth: 80,
            btnDisabled: this.viewModel.isLoading,
            onBtnClick: () => this.handleRefresh()
          })
        }
        .width('100%')
        .height(48)
        .padding({
          left: SP.PAGE_HORIZONTAL,
          right: SP.PAGE_HORIZONTAL
        })

        // 进程列表
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
                    process: process,
                    onTerminate: () => {
                      this.processToTerminate = process
                      this.showTerminateDialog = true
                    }
                  })
                }
                .swipeAction({
                  end: {
                    builder: () => this.TerminateButton(process)
                  }
                })
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
    .overlay(
      HmConfirmDialog({
        confirmVisible: this.showTerminateDialog,
        confirmTitle: '终止进程',
        confirmMessage: `确定要终止进程"${this.processToTerminate?.name || '未知'}"吗？`,
        confirmBtnText: '终止',
        cancelBtnText: '取消',
        isDanger: true,
        onConfirm: () => {
          this.showTerminateDialog = false
          this.handleTerminateProcess()
        },
        onCancel: () => {
          this.showTerminateDialog = false
          this.processToTerminate = null
        }
      })
    )
  }

  @Builder
  TerminateButton(process: Process) {
    Column() {
      Text('⏹')
        .fontSize(20)
    }
    .width(64)
    .height(80)
    .backgroundColor(DT.ERROR)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.processToTerminate = process
      this.showTerminateDialog = true
    })
  }
}
