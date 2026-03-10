import { router } from '@kit.ArkUI';
import { Spacing as SP } from '../constants';

@Entry
@Component
struct GatewayDetailPage {
  @State gatewayName: string = 'Gateway Name';
  @State gatewayStatus: string = 'Online';

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

        Text('Gateway Detail')
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
          // Info Card
          Column({ space: SP.M }) {
            Text(this.gatewayName)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))

            Text(this.gatewayStatus)
              .fontSize(14)
              .fontColor($r('app.color.success'))
          }
          .width('100%')
          .padding(SP.L)
          .backgroundColor($r('app.color.surface_card'))
          .borderRadius(12)

          // Actions
          Button('Connect')
            .width('100%')
            .height(48)
            .backgroundColor($r('app.color.brand_primary'))
            .fontColor($r('app.color.text_inverse'))
            .onClick(() => {})

          Button('Delete')
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
