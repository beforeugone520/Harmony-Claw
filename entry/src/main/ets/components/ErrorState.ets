import { Colors } from '../styles/DesignTokens';
import { Spacing, Layout } from '../styles/Spacing';

@Component
export struct ErrorState {
  @Prop title: string = 'Error';
  @Prop message: string = 'Something went wrong.';

  build() {
    Column({ space: Spacing.lg }) {
      Column()
        .width(64)
        .height(64)
        .backgroundColor(Colors.error)
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

      Button('Retry')
        .width(120)
        .height(Layout.buttonHeightMedium)
        .backgroundColor(Colors.brandPrimary)
        .fontColor(Colors.textInverse)
        .onClick(() => {})
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
