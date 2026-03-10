import { ProcessStatus } from '../../models/Process';
import { Colors } from '../../styles/DesignTokens';

@Component
export struct ProcessStatusIcon {
  @Prop status: ProcessStatus;
  @Prop size: number = 12;

  private getStatusColor(): ResourceColor {
    switch (this.status) {
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

  build() {
    Circle()
      .width(this.size)
      .height(this.size)
      .fill(this.getStatusColor())
  }
}
