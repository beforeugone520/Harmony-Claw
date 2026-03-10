import { router } from '@kit.ArkUI';
import { Colors } from '../styles/DesignTokens';
import { Spacing, Layout } from '../styles/Spacing';

@Component
struct SessionDetailPage {
  @State sessionName: string = 'Session Name';

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

        Text('Session Detail')
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
          Text(this.sessionName)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.textPrimary)

          Button('Close Session')
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
