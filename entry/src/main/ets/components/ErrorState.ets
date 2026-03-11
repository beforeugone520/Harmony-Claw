import { Spacing as SP } from '../constants';
import { DesignTokens as DT } from '../constants/DesignTokens';

@Component
export struct ErrorState {
  @Prop title: string = 'Error';
  @Prop message: string = 'Something went wrong.';
  @Prop isDark: boolean = false;

  build() {
    Column({ space: SP.L }) {
      Column()
        .width(64)
        .height(64)
        .backgroundColor(DT.ERROR)
        .borderRadius(32)

      Column({ space: SP.S }) {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isDark ? DT.DARK_TEXT_PRIMARY : DT.LIGHT_TEXT_PRIMARY)

        Text(this.message)
          .fontSize(14)
          .fontColor(this.isDark ? DT.DARK_TEXT_SECONDARY : DT.LIGHT_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
      }

      Button('Retry')
        .width(120)
        .height(44)
        .backgroundColor(DT.BRAND_PRIMARY)
        .fontColor('#FFFFFF')
        .onClick(() => {})
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
