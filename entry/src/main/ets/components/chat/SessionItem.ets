import { Session, SessionStatus } from '../../models/Session';
import { Colors, Typography } from '../../styles/DesignTokens';
import { Spacing } from '../../styles/Spacing';
import { DateUtils } from '../../utils/DateUtils';

@Component
export struct SessionItem {
  @Prop session: Session;
  @Prop isSelected: boolean = false;
  onItemClick?: () => void;
  onDelete?: () => void;

  private getStatusColor(): ResourceColor {
    if (!this.session) return Colors.textTertiary;
    switch (this.session.status) {
      case SessionStatus.ACTIVE:
        return Colors.info;
      case SessionStatus.CLOSED:
        return Colors.textTertiary;
      case SessionStatus.ERROR:
        return Colors.error;
      default:
        return Colors.textTertiary;
    }
  }

  private getStatusText(): string {
    if (!this.session) return '未知';
    switch (this.session.status) {
      case SessionStatus.ACTIVE:
        return '进行中';
      case SessionStatus.CLOSED:
        return '已关闭';
      case SessionStatus.ERROR:
        return '错误';
      default:
        return '未知';
    }
  }

  build() {
    Row({ space: Spacing.md }) {
      // Icon
      Column() {
        Text('💬')
          .fontSize(20)
      }
      .width(48)
      .height(48)
      .backgroundColor(Colors.backgroundTertiary)
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)

      // Info
      Column({ space: Spacing.xs }) {
        Row() {
          Text(this.session?.title || '未命名会话')
            .fontSize(Typography.sizeBody)
            .fontWeight(Typography.weightMedium)
            .fontColor(Colors.textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          Text(this.getStatusText())
            .fontSize(Typography.sizeCaption)
            .fontColor(this.getStatusColor())
        }
        .width('100%')

        Text(this.session?.createdAt ? DateUtils.formatRelativeTime(this.session.createdAt) : '未知')
          .fontSize(Typography.sizeCaption)
          .fontColor(Colors.textTertiary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // Delete button
      Button('×')
        .width(32)
        .height(32)
        .backgroundColor('transparent')
        .fontColor(Colors.textTertiary)
        .fontSize(20)
        .onClick(() => {
          if (this.onDelete) {
            this.onDelete();
          }
        })
    }
    .width('100%')
    .height(72)
    .padding(Spacing.md)
    .backgroundColor(this.isSelected ? `${Colors.brandPrimary}10` : Colors.surfaceCard)
    .borderRadius(12)
    .border({
      width: this.isSelected ? 1 : 0,
      color: Colors.brandPrimary
    })
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick();
      }
    })
    // 列表项进入动画
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseOut })
        .combine(TransitionEffect.translate({ x: -20 }).animation({ duration: 300, curve: Curve.EaseOut })),
      TransitionEffect.OPACITY.animation({ duration: 200 })
    ))
  }
}
