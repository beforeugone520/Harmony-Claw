import { Colors } from '../styles/DesignTokens';
import { Spacing } from '../styles/Spacing';

@Component
export struct LoadingState {
  @Prop message: string = 'Loading...';

  build() {
    Column({ space: Spacing.lg }) {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(Colors.brandPrimary)

      Text(this.message)
        .fontSize(16)
        .fontColor(Colors.textSecondary)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
