import { router } from '@kit.ArkUI';
import { Colors } from '../styles/DesignTokens';
import { Spacing, Layout } from '../styles/Spacing';

@Entry
@Component
struct GatewayDetailPage {
  @State gatewayName: string = 'Gateway Name';
  @State gatewayStatus: string = 'Online';

  build() {
    Column({ space: Spacing.lg }) {
      // Header
      Row() {
        Button('Back')
          .width(60)
          .height(36)
          .backgroundColor(Colors.backgroundTertiary)
          .fontColor(Colors.textPrimary)
          .fontSize(14)
          .onClick(() => {
            router.back();
          })

        Text('Gateway Detail')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()
          .width(60)
      }
      .width('100%')
      .height(Layout.headerHeight)
      .padding({ left: Spacing.lg, right: Spacing.lg })
      .backgroundColor(Colors.surfaceCard)

      // Content
      Scroll() {
        Column({ space: Spacing.lg }) {
          // Info Card
          Column({ space: Spacing.md }) {
            Text(this.gatewayName)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.textPrimary)

            Text(this.gatewayStatus)
              .fontSize(14)
              .fontColor(Colors.success)
          }
          .width('100%')
          .padding(Spacing.lg)
          .backgroundColor(Colors.surfaceCard)
          .borderRadius(12)

          // Actions
          Button('Connect')
            .width('100%')
            .height(48)
            .backgroundColor(Colors.brandPrimary)
            .fontColor(Colors.textInverse)
            .onClick(() => {})

          Button('Delete')
            .width('100%')
            .height(48)
            .backgroundColor(Colors.error)
            .fontColor(Colors.textInverse)
            .onClick(() => {})
        }
        .width('100%')
        .padding(Spacing.lg)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.backgroundPrimary)
  }
}
