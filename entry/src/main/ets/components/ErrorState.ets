import { Spacing as SP } from '../constants';

@Component
export struct ErrorState {
  @Prop title: string = 'Error';
  @Prop message: string = 'Something went wrong.';

  build() {
    Column({ space: SP.L }) {
      Column()
        .width(64)
        .height(64)
        .backgroundColor($r('app.color.error'))
        .borderRadius(32)

      Column({ space: SP.S }) {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(this.message)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .textAlign(TextAlign.Center)
      }

      Button('Retry')
        .width(120)
        .height(44)
        .backgroundColor($r('app.color.brand_primary'))
        .fontColor($r('app.color.text_inverse'))
        .onClick(() => {})
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
