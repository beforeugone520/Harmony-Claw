import { Colors } from '../styles/DesignTokens';
import { Spacing, Layout } from '../styles/Spacing';

@Component
struct SessionListPage {
  @State sessionList: string[] = ['Session 1', 'Session 2', 'Session 3'];

  build() {
    Column({ space: Spacing.lg }) {
      // Header
      Row() {
        Text('Sessions')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.textPrimary)

        Blank()

        Button('+')
          .width(36)
          .height(36)
          .backgroundColor(Colors.brandPrimary)
          .fontColor(Colors.textInverse)
          .onClick(() => {})
      }
      .width('100%')
      .height(56)
      .padding({ left: Spacing.lg, right: Spacing.lg })

      // List
      List({ space: Spacing.md }) {
        ForEach(this.sessionList, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text(item)
                .fontSize(16)
                .fontColor(Colors.textPrimary)

              Blank()

              Text('Active')
                .fontSize(12)
                .fontColor(Colors.info)
            }
            .width('100%')
            .height(64)
            .padding({ left: Spacing.lg, right: Spacing.lg })
            .backgroundColor(Colors.surfaceCard)
            .borderRadius(8)
          }
        }, (item: string) => item)
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.backgroundPrimary)
  }
}
