import { Colors } from '../styles/DesignTokens';

export enum BadgeStatus {
  SUCCESS = 'success',
  WARNING = 'warning',
  ERROR = 'error',
  INFO = 'info',
  DEFAULT = 'default'
}

@Component
export struct StatusBadge {
  @Prop status: BadgeStatus = BadgeStatus.DEFAULT;
  @Prop text: string = '';

  private getStatusColor(): ResourceColor {
    switch (this.status) {
      case BadgeStatus.SUCCESS:
        return Colors.success;
      case BadgeStatus.WARNING:
        return Colors.warning;
      case BadgeStatus.ERROR:
        return Colors.error;
      case BadgeStatus.INFO:
        return Colors.info;
      default:
        return Colors.textTertiary;
    }
  }

  build() {
    Row() {
      Circle()
        .width(8)
        .height(8)
        .fill(this.getStatusColor())

      Text(this.text)
        .fontSize(12)
        .fontColor(this.getStatusColor())
    }
    .padding(4)
    .backgroundColor(`${this.getStatusColor()}20`)
    .borderRadius(4)
  }
}
