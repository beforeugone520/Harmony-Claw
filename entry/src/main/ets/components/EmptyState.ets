import { Colors } from '../styles/DesignTokens';
import { Spacing } from '../styles/Spacing';

@Component
export struct EmptyState {
  @Prop title: string = 'No Data';
  @Prop message: string = 'There is nothing to display here.';

  build() {
    Column({ space: Spacing.lg }) {
      Column()
        .width(64)
        .height(64)
        .backgroundColor(Colors.backgroundTertiary)
        .borderRadius(32)

      Column({ space: Spacing.sm }) {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(Colors.textPrimary)

        Text(this.message)
          .fontSize(14)
          .fontColor(Colors.textSecondary)
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
