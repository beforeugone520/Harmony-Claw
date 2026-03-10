import { ProcessViewModel } from '../viewmodels/ProcessViewModel';
import { ProcessCard } from '../components/process/ProcessCard';
import { Process } from '../models/Process';
import { Colors, Typography } from '../styles/DesignTokens';
import { Spacing, Layout } from '../styles/Spacing';
import { LoadingState } from '../components/LoadingState';
import { EmptyState } from '../components/EmptyState';

@Entry
@Component
struct ProcessListPage {
  @State viewModel: ProcessViewModel = new ProcessViewModel();

  aboutToAppear() {
    this.viewModel.initialize();
  }

  private async handleRefresh() {
    await this.viewModel.refresh();
  }

  private async handleTerminateProcess(id: string) {
    await this.viewModel.terminateProcess(id);
  }

  build() {
    Column({ space: 0 }) {
      // Header
      Row() {
        Text('进程监控')
          .fontSize(Typography.sizeH3)
          .fontWeight(Typography.weightBold)
          .fontColor(Colors.textPrimary)

        Blank()

        Button('刷新')
          .width(80)
          .height(36)
          .backgroundColor(Colors.brandPrimary)
          .fontColor(Colors.textInverse)
          .fontSize(Typography.sizeSmall)
          .enabled(!this.viewModel.isLoading)
          .onClick(() => this.handleRefresh())
      }
      .width('100%')
      .height(Layout.headerHeight)
      .padding({ left: Spacing.lg, right: Spacing.lg })
      .backgroundColor(Colors.backgroundSecondary)

      // Stats
      Row({ space: Spacing.md }) {
        Column({ space: Spacing.xs }) {
          Text(String(this.viewModel.getRunningCount()))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.success)
          Text('运行中')
            .fontSize(Typography.sizeCaption)
            .fontColor(Colors.textSecondary)
        }
        .layoutWeight(1)

        Column({ space: Spacing.xs }) {
          Text(`${this.viewModel.getTotalCpuUsage().toFixed(1)}%`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.brandPrimary)
          Text('CPU 占用')
            .fontSize(Typography.sizeCaption)
            .fontColor(Colors.textSecondary)
        }
        .layoutWeight(1)

        Column({ space: Spacing.xs }) {
          Text(`${this.viewModel.getTotalMemoryUsage().toFixed(0)} MB`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.warning)
          Text('内存占用')
            .fontSize(Typography.sizeCaption)
            .fontColor(Colors.textSecondary)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding(Spacing.lg)
      .backgroundColor(Colors.surfaceCard)

      // Content
      if (this.viewModel.isLoading && this.viewModel.processes.length === 0) {
        LoadingState({ message: '加载中...' })
      } else if (this.viewModel.processes.length === 0) {
        EmptyState({
          title: '暂无进程',
          message: '当前没有运行中的进程'
        })
      } else {
        List({ space: Spacing.md }) {
          ForEach(this.viewModel.processes, (process: Process) => {
            ListItem() {
              ProcessCard({
                process: process,
                onTerminate: () => { this.handleTerminateProcess(process.id); }
              })
            }
          }, (process: Process) => process.id)
        }
        .width('100%')
        .padding(Spacing.lg)
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.backgroundPrimary)
  }

  // 页面转场动画
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 200, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
  }
}
