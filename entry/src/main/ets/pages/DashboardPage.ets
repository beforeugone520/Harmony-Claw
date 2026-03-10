import { router } from '@kit.ArkUI';
import { Colors } from '../styles/DesignTokens';
import { Spacing, Layout } from '../styles/Spacing';

@Component
export struct DashboardPage {
  @State isLoading: boolean = false;

  build() {
    Column({ space: Spacing.lg }) {
      // Stats Grid
      Row({ space: Spacing.md }) {
        Column({ space: Spacing.sm }) {
          Text('5')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.brandPrimary)
          Text('Active Gateways')
            .fontSize(12)
            .fontColor(Colors.textSecondary)
        }
        .layoutWeight(1)
        .padding(Spacing.md)
        .backgroundColor(Colors.surfaceCard)
        .borderRadius(12)

        Column({ space: Spacing.sm }) {
          Text('12')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.success)
          Text('Sessions')
            .fontSize(12)
            .fontColor(Colors.textSecondary)
        }
        .layoutWeight(1)
        .padding(Spacing.md)
        .backgroundColor(Colors.surfaceCard)
        .borderRadius(12)
      }
      .width('100%')

      // Quick Actions
      Column({ space: Spacing.md }) {
        Text('Quick Actions')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Colors.textPrimary)
          .width('100%')

        Row({ space: Spacing.md }) {
          Button('Scan QR')
            .layoutWeight(1)
            .height(44)
            .backgroundColor(Colors.brandPrimary)
            .onClick(() => {})

          Button('Add Manual')
            .layoutWeight(1)
            .height(44)
            .backgroundColor(Colors.brandSecondary)
            .onClick(() => {})
        }
        .width('100%')
      }
      .width('100%')
      .padding(Spacing.lg)
      .backgroundColor(Colors.surfaceCard)
      .borderRadius(12)
    }
    .width('100%')
    .padding(Spacing.lg)
  }
}
