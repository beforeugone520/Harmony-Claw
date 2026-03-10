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
        return $r('app.color.success');
      case BadgeStatus.WARNING:
        return $r('app.color.warning');
      case BadgeStatus.ERROR:
        return $r('app.color.error');
      case BadgeStatus.INFO:
        return $r('app.color.info');
      default:
        return $r('app.color.text_tertiary');
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
    .borderRadius(4)
  }
}
