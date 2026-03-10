import { router } from '@kit.ArkUI';
import { Spacing as SP } from '../constants';

@Component
export struct DashboardPage {
  @State isLoading: boolean = false;

  build() {
    Column({ space: SP.L }) {
      // Stats Grid
      Row({ space: SP.M }) {
        Column({ space: SP.S }) {
          Text('5')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.brand_primary'))
          Text('Active Gateways')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
        .layoutWeight(1)
        .padding(SP.M)
        .backgroundColor($r('app.color.surface_card'))
        .borderRadius(12)

        Column({ space: SP.S }) {
          Text('12')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.success'))
          Text('Sessions')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
        .layoutWeight(1)
        .padding(SP.M)
        .backgroundColor($r('app.color.surface_card'))
        .borderRadius(12)
      }
      .width('100%')

      // Quick Actions
      Column({ space: SP.M }) {
        Text('Quick Actions')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .width('100%')

        Row({ space: SP.M }) {
          Button('Scan QR')
            .layoutWeight(1)
            .height(44)
            .backgroundColor($r('app.color.brand_primary'))
            .onClick(() => {})

          Button('Add Manual')
            .layoutWeight(1)
            .height(44)
            .backgroundColor($r('app.color.brand_secondary'))
            .onClick(() => {})
        }
        .width('100%')
      }
      .width('100%')
      .padding(SP.L)
      .backgroundColor($r('app.color.surface_card'))
      .borderRadius(12)
    }
    .width('100%')
    .padding(SP.L)
  }
}
