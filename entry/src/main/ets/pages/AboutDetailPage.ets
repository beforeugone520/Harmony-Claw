import { router } from '@kit.ArkUI';
import { DesignTokens as DT, Spacing as SP, Typography as TYP, Animation as ANI } from '../constants';

@Entry
@Component
struct AboutDetailPage {
  @State isDark: boolean = false
  @State title: string = ''
  @State content: string = ''

  // Safe area for immersive mode
  @State topSafeArea: number = 37

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params) {
      this.title = params['title'] || '';
      this.content = params['content'] || '';
    }
  }

  @Builder
  HeaderBuilder() {
    Row() {
      Button() {
        Text('‹')
          .fontSize(28)
          .fontWeight(TYP.WEIGHT_MEDIUM)
          .fontColor(DT.getTextPrimary(this.isDark))
      }
      .width(44)
      .height(44)
      .backgroundColor('transparent')
      .scale({ x: 1, y: 1 })
      .animation(ANI.pressFeedbackFine())
      .onClick(() => {
        router.back();
      })

      Text(this.title)
        .fontSize(TYP.SIZE_H2)
        .fontWeight(TYP.WEIGHT_MEDIUM)
        .fontColor(DT.getTextPrimary(this.isDark))

      Blank()
        .width(44)
    }
    .width('100%')
    .height(56)
    .padding({ left: SP.S, right: SP.M })
    .backgroundColor(DT.getBackgroundColor(this.isDark))
  }

  build() {
    Column({ space: 0 }) {
      // 顶部安全区域占位
      Column()
        .width('100%')
        .height(this.topSafeArea)
        .backgroundColor(DT.getBackgroundColor(this.isDark))

      // Header
      this.HeaderBuilder()

      // Content
      Scroll() {
        Text(this.content)
          .fontSize(TYP.SIZE_BODY)
          .fontColor(DT.getTextPrimary(this.isDark))
          .width('100%')
          .padding(SP.L)
          .lineHeight(24)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DT.getBackgroundColor(this.isDark))
  }

  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 200, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
  }
}
