import { Spacing as SP } from '../constants';

@Component
export struct LoadingState {
  @Prop message: string = 'Loading...';

  build() {
    Column({ space: SP.L }) {
      LoadingProgress()
        .width(48)
        .height(48)
        .color($r('app.color.brand_primary'))

      Text(this.message)
        .fontSize(16)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
