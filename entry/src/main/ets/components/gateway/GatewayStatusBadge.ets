import { GatewayStatus } from '../../models/Gateway';
import { Colors, Typography } from '../../styles/DesignTokens';

@Component
export struct GatewayStatusBadge {
  @Prop status: GatewayStatus;
  @Prop showText: boolean = true;

  private getStatusColor(): ResourceColor {
    switch (this.status) {
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
    switch (this.status) {
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
    Row({ space: 6 }) {
      Circle()
        .width(8)
        .height(8)
        .fill(this.getStatusColor())

      if (this.showText) {
        Text(this.getStatusText())
          .fontSize(Typography.sizeCaption)
          .fontColor(this.getStatusColor())
      }
    }
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .backgroundColor(`${this.getStatusColor()}15`)
    .borderRadius(4)
  }
}
