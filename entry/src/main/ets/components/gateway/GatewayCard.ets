import { Gateway, GatewayStatus } from '../../models/Gateway';
import { Colors, Typography } from '../../styles/DesignTokens';
import { Spacing } from '../../styles/Spacing';
import { DateUtils } from '../../utils/DateUtils';

@Component
export struct GatewayCard {
  @Prop gateway: Gateway;
  @Prop isSelected: boolean = false;
  onConnect?: () => void;
  onDelete?: () => void;

  private getStatusColor(): ResourceColor {
    if (!this.gateway) return Colors.textTertiary;
    switch (this.gateway.status) {
      case GatewayStatus.ONLINE:
        return Colors.success;
      case GatewayStatus.OFFLINE:
        return Colors.textTertiary;
      case GatewayStatus.ERROR:
        return Colors.error;
      case GatewayStatus.CONNECTING:
        return Colors.warning;
      default:
        return Colors.textTertiary;
    }
  }

  private getStatusText(): string {
    if (!this.gateway) return '未知';
    switch (this.gateway.status) {
      case GatewayStatus.ONLINE:
        return '在线';
      case GatewayStatus.OFFLINE:
        return '离线';
      case GatewayStatus.ERROR:
        return '错误';
      case GatewayStatus.CONNECTING:
        return '连接中';
      default:
        return '未知';
    }
  }

  build() {
    Column({ space: Spacing.md }) {
      Row() {
        // Icon
        Column() {
          Text('G')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.textInverse)
        }
        .width(48)
        .height(48)
        .backgroundColor(Colors.brandPrimary)
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)

        // Info
        Column({ space: Spacing.xs }) {
          Text(this.gateway?.name || '未命名')
            .fontSize(Typography.sizeBody)
            .fontWeight(Typography.weightMedium)
            .fontColor(Colors.textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`${this.gateway?.host || 'unknown'}:${this.gateway?.port || 0}`)
            .fontSize(Typography.sizeCaption)
            .fontColor(Colors.textSecondary)

          Text(`v${this.gateway?.version || '1.0'}`)
            .fontSize(Typography.sizeOverline)
            .fontColor(Colors.textTertiary)
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

          Text(this.gateway?.lastSeen ? DateUtils.formatRelativeTime(this.gateway.lastSeen) : '未知')
            .fontSize(Typography.sizeOverline)
            .fontColor(Colors.textTertiary)
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      // Actions
      Row({ space: Spacing.md }) {
        if (this.gateway?.status === GatewayStatus.ONLINE) {
          Button(this.isSelected ? '已连接' : '连接')
            .layoutWeight(1)
            .height(36)
            .backgroundColor(this.isSelected ? Colors.success : Colors.brandPrimary)
            .fontSize(Typography.sizeSmall)
            .enabled(!this.isSelected)
            .onClick(() => {
              if (this.onConnect) {
                this.onConnect();
              }
            })
        } else {
          Button('刷新状态')
            .layoutWeight(1)
            .height(36)
            .backgroundColor(Colors.warning)
            .fontSize(Typography.sizeSmall)
            .onClick(() => {
              if (this.onConnect) {
                this.onConnect();
              }
            })
        }

        Button('删除')
          .width(80)
          .height(36)
          .backgroundColor(Colors.backgroundTertiary)
          .fontColor(Colors.error)
          .fontSize(Typography.sizeSmall)
          .onClick(() => {
            if (this.onDelete) {
              this.onDelete();
            }
          })
      }
      .width('100%')
      .margin({ top: Spacing.sm })
    }
    .width('100%')
    .padding(Spacing.lg)
    .backgroundColor(Colors.surfaceCard)
    .borderRadius(12)
    .border({
      width: this.isSelected ? 2 : 0,
      color: Colors.brandPrimary
    })
  }
}
