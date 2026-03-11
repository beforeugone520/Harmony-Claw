import { Process, ProcessStatus } from '../../models/Process';
import { Spacing as SP } from '../../constants';
import { DesignTokens as DT } from '../../constants/DesignTokens';

@Component
export struct ProcessCard {
  @Prop process: Process;

  private isDarkMode(): boolean {
    try {
      return AppStorage.get<boolean>('isSystemDarkMode') ?? false
    } catch {
      return false
    }
  }

  private getStatusColor(): string {
    switch (this.process.status) {
      case ProcessStatus.RUNNING:
        return DT.IOS_GREEN;
      case ProcessStatus.STOPPED:
        return this.isDarkMode() ? DT.DARK_TEXT_TERTIARY : DT.LIGHT_TEXT_TERTIARY;
      case ProcessStatus.ERROR:
        return DT.IOS_RED;
      case ProcessStatus.PENDING:
        return DT.IOS_ORANGE;
      default:
        return this.isDarkMode() ? DT.DARK_TEXT_TERTIARY : DT.LIGHT_TEXT_TERTIARY;
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
    Column({ space: SP.M }) {
      Row() {
        // Icon
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(48)
            .height(48)
            .fill(this.isDarkMode() ? '#2C2C2E' : '#E5E5EA')

          Text('⚡')
            .fontSize(22)
            .fontColor(DT.IOS_BLUE)
        }
        .width(48)
        .height(48)

        // Info
        Column({ space: SP.XS }) {
          Text(this.process.name)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.isDarkMode() ? DT.DARK_TEXT_PRIMARY : DT.LIGHT_TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`PID: ${this.process.pid}`)
            .fontSize(12)
            .fontColor(this.isDarkMode() ? DT.DARK_TEXT_SECONDARY : DT.LIGHT_TEXT_SECONDARY)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: SP.M })

        // Status
        Column({ space: SP.XS }) {
          Row({ space: SP.XS }) {
            Circle()
              .width(8)
              .height(8)
              .fill(this.getStatusColor())

            Text(this.getStatusText())
              .fontSize(12)
              .fontColor(this.getStatusColor())
              .fontWeight(FontWeight.Medium)
          }
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      // Memory info
      Row({ space: SP.L }) {
        Column({ space: SP.XS }) {
          Text('内存')
            .fontSize(11)
            .fontColor(this.isDarkMode() ? DT.DARK_TEXT_TERTIARY : DT.LIGHT_TEXT_TERTIARY)

          Text(`${this.process.memory.toFixed(0)} MB`)
            .fontSize(14)
            .fontColor(this.isDarkMode() ? DT.DARK_TEXT_PRIMARY : DT.LIGHT_TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)

        Column({ space: SP.XS }) {
          Text('CPU')
            .fontSize(11)
            .fontColor(this.isDarkMode() ? DT.DARK_TEXT_TERTIARY : DT.LIGHT_TEXT_TERTIARY)

          Text(`${this.process.cpu.toFixed(1)}%`)
            .fontSize(14)
            .fontColor(this.isDarkMode() ? DT.DARK_TEXT_PRIMARY : DT.LIGHT_TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ top: SP.S })
    }
    .width('100%')
    .padding(SP.L)
    .backgroundColor(this.isDarkMode() ? '#1C1C1E' : '#FFFFFF')
    .borderRadius(16)
    .shadow(this.isDarkMode() ? undefined : {
      radius: 8,
      color: 'rgba(0,0,0,0.06)',
      offsetX: 0,
      offsetY: 2
    })
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseOut })
        .combine(TransitionEffect.translate({ y: 20 }).animation({ duration: 300, curve: Curve.EaseOut })),
      TransitionEffect.OPACITY.animation({ duration: 200 })
    ))
  }
}
