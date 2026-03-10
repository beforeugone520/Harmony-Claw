import { router } from '@kit.ArkUI';
import { Spacing as SP } from '../constants';

@Component
struct SessionDetailPage {
  @State sessionName: string = 'Session Name';

  build() {
    Column({ space: SP.L }) {
      // Header
      Row() {
        Button('Back')
          .width(60)
          .height(36)
          .backgroundColor($r('app.color.background_tertiary'))
          .fontColor($r('app.color.text_primary'))
          .fontSize(14)
          .onClick(() => {
            router.back();
          })

        Text('Session Detail')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()
          .width(60)
      }
      .width('100%')
      .height(56)
      .padding({ left: SP.L, right: SP.L })
      .backgroundColor($r('app.color.surface_card'))

      // Content
      Scroll() {
        Column({ space: SP.L }) {
          Text(this.sessionName)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Button('Close Session')
            .width('100%')
            .height(48)
            .backgroundColor($r('app.color.error'))
            .fontColor($r('app.color.text_inverse'))
            .onClick(() => {})
        }
        .width('100%')
        .padding(SP.L)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_primary'))
  }
}
