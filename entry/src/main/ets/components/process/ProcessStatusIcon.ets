import { ProcessStatus } from '../../models/Process';

@Component
export struct ProcessStatusIcon {
  @Prop status: ProcessStatus;
  @Prop size: number = 12;

  private getStatusColor(): ResourceColor {
    switch (this.status) {
      case ProcessStatus.RUNNING:
        return $r('app.color.success');
      case ProcessStatus.STOPPED:
        return $r('app.color.text_tertiary');
      case ProcessStatus.ERROR:
        return $r('app.color.error');
      case ProcessStatus.PENDING:
        return $r('app.color.warning');
      default:
        return $r('app.color.text_tertiary');
    }
  }

  build() {
    Circle()
      .width(this.size)
      .height(this.size)
      .fill(this.getStatusColor())
  }
}
