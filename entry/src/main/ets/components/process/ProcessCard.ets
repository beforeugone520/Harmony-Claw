import { Process, ProcessStatus } from '../../models/Process';
import { Colors, Typography } from '../../styles/DesignTokens';
import { Spacing, Layout } from '../../styles/Spacing';

@Component
export struct ProcessCard {
  @Prop process: Process;
  onTerminate?: () => void;

  private getStatusColor(): ResourceColor {
    switch (this.process.status) {
      case ProcessStatus.RUNNING:
        return Colors.success;
      case ProcessStatus.STOPPED:
        return Colors.textTertiary;
      case ProcessStatus.ERROR:
        return Colors.error;
      case ProcessStatus.PENDING:
        return Colors.warning;
      default:
        return Colors.textTertiary;
    }
  }

  private getStatusText(): string {
    switch (this.process.status) {
      case ProcessStatus.RUNNING:
        return '运行中';
      case ProcessStatus.STOPPED:
        return '已停止';
      case ProcessStatus.ERROR:
        return '错误';
      case ProcessStatus.PENDING:
        return '等待中';
      default:
        return '未知';
    }
  }

  build() {
    Column({ space: Spacing.md }) {
      Row() {
        // Icon
        Column() {
          Text('⚙️')
            .fontSize(20)
        }
        .width(48)
        .height(48)
        .backgroundColor(Colors.backgroundTertiary)
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)

        // Info
        Column({ space: Spacing.xs }) {
          Text(this.process.name)
            .fontSize(Typography.sizeBody)
            .fontWeight(Typography.weightMedium)
            .fontColor(Colors.textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`PID: ${this.process.pid}`)
            .fontSize(Typography.sizeCaption)
            .fontColor(Colors.textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: Spacing.md })

        // Status
        Column({ space: Spacing.xs }) {
          Row({ space: Spacing.xs }) {
            Circle()
              .width(8)
              .height(8)
              .fill(this.getStatusColor())

            Text(this.getStatusText())
              .fontSize(Typography.sizeCaption)
              .fontColor(this.getStatusColor())
          }
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      // Resources
      Row({ space: Spacing.lg }) {
        Column({ space: Spacing.xs }) {
          Text('CPU')
            .fontSize(Typography.sizeCaption)
            .fontColor(Colors.textTertiary)

          Text(`${this.process.cpu.toFixed(1)}%`)
            .fontSize(Typography.sizeBody)
            .fontColor(Colors.textPrimary)
        }
        .layoutWeight(1)

        Column({ space: Spacing.xs }) {
          Text('内存')
            .fontSize(Typography.sizeCaption)
            .fontColor(Colors.textTertiary)

          Text(`${this.process.memory.toFixed(0)} MB`)
            .fontSize(Typography.sizeBody)
            .fontColor(Colors.textPrimary)
        }
        .layoutWeight(1)

        // Terminate button
        if (this.process.status === ProcessStatus.RUNNING) {
          Button('终止')
            .width(80)
            .height(36)
            .backgroundColor(Colors.error)
            .fontColor(Colors.textInverse)
            .fontSize(Typography.sizeSmall)
            .onClick(() => {
              if (this.onTerminate) {
                this.onTerminate();
              }
            })
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(Spacing.lg)
    .backgroundColor(Colors.surfaceCard)
    .borderRadius(12)
    // 列表项进入动画
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseOut })
        .combine(TransitionEffect.translate({ y: 20 }).animation({ duration: 300, curve: Curve.EaseOut })),
      TransitionEffect.OPACITY.animation({ duration: 200 })
    ))
  }
}
