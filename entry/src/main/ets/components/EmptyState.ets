import { Spacing as SP } from '../constants';

@Component
export struct EmptyState {
  @Prop title: string = 'No Data';
  @Prop message: string = 'There is nothing to display here.';

  build() {
    Column({ space: SP.L }) {
      Column()
        .width(64)
        .height(64)
        .backgroundColor($r('app.color.background_tertiary'))
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
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
