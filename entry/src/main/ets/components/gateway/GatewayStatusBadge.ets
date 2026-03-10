import { GatewayStatus } from '../../models/Gateway';

@Component
export struct GatewayStatusBadge {
  @Prop status: GatewayStatus;
  @Prop showText: boolean = true;

  private getStatusColor(): ResourceColor {
    switch (this.status) {
      case GatewayStatus.ONLINE:
        return $r('app.color.success');
      case GatewayStatus.OFFLINE:
        return $r('app.color.text_tertiary');
      case GatewayStatus.ERROR:
        return $r('app.color.error');
      case GatewayStatus.CONNECTING:
        return $r('app.color.warning');
      default:
        return $r('app.color.text_tertiary');
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
          .fontSize(12)
          .fontColor(this.getStatusColor())
      }
    }
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .borderRadius(4)
  }
}
