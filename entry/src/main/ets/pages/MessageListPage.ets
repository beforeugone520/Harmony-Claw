import { Colors } from '../styles/DesignTokens';
import { Spacing, Layout } from '../styles/Spacing';

@Component
struct MessageListPage {
  @State messageList: string[] = ['Message 1', 'Message 2'];

  build() {
    Column({ space: Spacing.lg }) {
      // Header
      Row() {
        Text('Messages')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.textPrimary)

        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: Spacing.lg, right: Spacing.lg })

      // List
      List({ space: Spacing.md }) {
        ForEach(this.messageList, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text(item)
                .fontSize(16)
                .fontColor(Colors.textPrimary)

              Blank()

              Text('New')
                .fontSize(12)
                .fontColor(Colors.warning)
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
