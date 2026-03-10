import { Session, SessionStatus } from '../../models/Session';
import { Spacing as SP } from '../../constants';
import { DateUtils } from '../../utils/DateUtils';

@Component
export struct SessionItem {
  @Prop session: Session;
  @Prop isSelected: boolean = false;
  onItemClick?: () => void;
  onDelete?: () => void;

  private getStatusColor(): ResourceColor {
    if (!this.session) return $r('app.color.text_tertiary');
    switch (this.session.status) {
      case SessionStatus.ACTIVE:
        return $r('app.color.info');
      case SessionStatus.CLOSED:
        return $r('app.color.text_tertiary');
      case SessionStatus.ERROR:
        return $r('app.color.error');
      default:
        return $r('app.color.text_tertiary');
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
    Row({ space: SP.M }) {
      // Icon
      Column() {
        Text('💬')
          .fontSize(20)
      }
      .width(48)
      .height(48)
      .backgroundColor($r('app.color.background_tertiary'))
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)

      // Info
      Column({ space: SP.XS }) {
        Row() {
          Text(this.session?.title || '未命名会话')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          Text(this.getStatusText())
            .fontSize(12)
            .fontColor(this.getStatusColor())
        }
        .width('100%')

        Text(this.session?.createdAt ? DateUtils.formatRelativeTime(this.session.createdAt) : '未知')
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // Delete button
      Button('×')
        .width(32)
        .height(32)
        .backgroundColor('transparent')
        .fontColor($r('app.color.text_tertiary'))
        .fontSize(20)
        .onClick(() => {
          if (this.onDelete) {
            this.onDelete();
          }
        })
    }
    .width('100%')
    .height(72)
    .padding(SP.M)
    .backgroundColor(this.isSelected ? $r('app.color.brand_primary') : $r('app.color.surface_card'))
    .opacity(this.isSelected ? 0.1 : 1)
    .borderRadius(12)
    .border({
      width: this.isSelected ? 1 : 0,
      color: $r('app.color.brand_primary')
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
