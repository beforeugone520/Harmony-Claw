/**
 * ProcessListPage.ets
 * 进程监控页面 - HarmonyOS 6 风格
 */
import { ProcessViewModel } from '../viewmodels/ProcessViewModel'
import { ProcessCard } from '../components/process/ProcessCard'
import { Process, ProcessStatus } from '../models/Process'
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
    // 启动自动刷新（每 10 秒）
    this.startAutoRefresh()
  }

  aboutToDisappear() {
    this.stopAutoRefresh()
  }

  // 启动自动刷新
  private startAutoRefresh() {
    this.autoRefresh = true
    this.refreshTimer = setInterval(() => {
      if (this.autoRefresh && !this.viewModel.isLoading) {
        this.viewModel.refresh()
      }
    }, 10000)
  }

  // 停止自动刷新
  private stopAutoRefresh() {
    this.autoRefresh = false
    if (this.refreshTimer !== -1) {
      clearInterval(this.refreshTimer)
      this.refreshTimer = -1
    }
  }

  // 手动刷新
  private async handleRefresh() {
    this.isRefreshing = true
    await this.viewModel.refresh()
    this.isRefreshing = false
    ToastManager.success('已刷新')
  }

  // 终止进程
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

  // 切换自动刷新
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
          // 运行中进程数
          HmInfoCard({
            title: '运行中',
            value: String(this.viewModel.getRunningCount()),
            icon: $r('app.media.ic_process'),
            iconBgColor: DT.SUCCESS_BG,
            iconColor: DT.SUCCESS
          })
          .layoutWeight(1)

          // CPU 占用
          HmInfoCard({
            title: 'CPU',
            value: `${this.viewModel.getTotalCpuUsage().toFixed(1)}`,
            unit: '%',
            icon: $r('app.media.ic_cpu'),
            iconBgColor: DT.BRAND_LIGHT,
            iconColor: DT.BRAND_PRIMARY
          })
          .layoutWeight(1)

          // 内存占用
          HmInfoCard({
            title: '内存',
            value: `${this.viewModel.getTotalMemoryUsage().toFixed(0)}`,
            unit: 'MB',
            icon: $r('app.media.ic_memory'),
            iconBgColor: DT.WARNING_BG,
            iconColor: DT.WARNING
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
          // 自动刷新开关
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

          // 手动刷新按钮
          HmButton({
            text: '刷新',
            type: 1, // SECONDARY
            size: 0, // SMALL
            width: 80,
            disabled: this.viewModel.isLoading,
            loading: this.viewModel.isLoading,
            onClick: () => this.handleRefresh()
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
    // 终止确认对话框
    .overlay(
      HmConfirmDialog({
        visible: this.showTerminateDialog,
        title: '终止进程',
        message: `确定要终止进程"${this.processToTerminate?.name || '未知'}"吗？`,
        confirmText: '终止',
        cancelText: '取消',
        danger: true,
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

  // 终止按钮构建器
  @Builder
  TerminateButton(process: Process) {
    Column() {
      Image($r('app.media.ic_stop'))
        .width(24)
        .height(24)
        .fillColor(Color.White)
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
