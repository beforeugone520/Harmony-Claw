import { Spacing as SP } from '../constants';

@Component
struct MessageListPage {
  @State messageList: string[] = ['Message 1', 'Message 2'];

  build() {
    Column({ space: SP.L }) {
      // Header
      Row() {
        Text('Messages')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: SP.L, right: SP.L })

      // List
      List({ space: SP.M }) {
        ForEach(this.messageList, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text(item)
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))

              Blank()

              Text('New')
                .fontSize(12)
                .fontColor($r('app.color.warning'))
            }
            .width('100%')
            .height(64)
            .padding({ left: SP.L, right: SP.L })
            .backgroundColor($r('app.color.surface_card'))
            .borderRadius(8)
          }
        }, (item: string) => item)
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_primary'))
  }
}
