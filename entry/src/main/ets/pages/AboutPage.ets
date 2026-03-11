import { router } from '@kit.ArkUI';
import { DesignTokens as DT, Spacing as SP, Typography as TYP, Animation as ANI } from '../constants';

@Entry
@Component
struct AboutPage {
  @State isDark: boolean = false

  // Safe area for immersive mode
  @State topSafeArea: number = 37

  // 开源许可内容
  private licenseContent: string = `
开源许可

本应用使用了以下开源项目：

1. ArkUI
Copyright (c) OpenHarmony
License: Apache 2.0

2. HarmonyOS SDK
Copyright (c) Huawei

感谢开源社区的贡献！
`;

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

      Text('关于应用')
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

  @Builder
  AboutRow(title: string, onClick: () => void) {
    Row() {
      Text(title)
        .fontSize(TYP.SIZE_BODY)
        .fontColor(DT.getTextPrimary(this.isDark))

      Blank()

      Text('›')
        .fontSize(20)
        .fontColor(DT.getTextSecondary(this.isDark))
    }
    .width('100%')
    .height(48)
    .scale({ x: 1, y: 1 })
    .animation(ANI.pressFeedbackFine())
    .onClick(onClick)
  }

  private showLicense(): void {
    router.pushUrl({
      url: 'pages/AboutDetailPage',
      params: { title: '开源许可', content: this.licenseContent }
    }).catch((err: Error) => {
      console.error(`[AboutPage] Failed to navigate: ${JSON.stringify(err)}`);
    });
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
        Column({ space: SP.L }) {
          // 应用信息卡片
          Column({ space: SP.M }) {
            Column()
              .width(80)
              .height(80)
              .backgroundColor(DT.BRAND_PRIMARY)
              .borderRadius(20)
              .margin({ bottom: SP.M })

            Text('Harmony Claw')
              .fontSize(TYP.SIZE_H2)
              .fontWeight(TYP.WEIGHT_BOLD)
              .fontColor(DT.getTextPrimary(this.isDark))

            Text('Version 1.0.0')
              .fontSize(TYP.SIZE_BODY)
              .fontColor(DT.getTextSecondary(this.isDark))

            Text('Build 20240309')
              .fontSize(TYP.SIZE_SMALL)
              .fontColor(DT.getTextTertiary(this.isDark))
          }
          .width('100%')
          .padding(SP.XL)
          .backgroundColor(DT.getSurfaceColor(this.isDark))
          .borderRadius(SP.RADIUS_L)
          .alignItems(HorizontalAlign.Center)

          // 链接列表
          Column({ space: 0 }) {
            this.AboutRow('开源许可', () => {
              this.showLicense();
            })
          }
          .width('100%')
          .padding({ left: SP.L, right: SP.L })
          .backgroundColor(DT.getSurfaceColor(this.isDark))
          .borderRadius(SP.RADIUS_L)

          // 版权信息
          Text('© 2024-2025 BeforeUgone. MIT License.')
            .fontSize(TYP.SIZE_SMALL)
            .fontColor(DT.getTextTertiary(this.isDark))
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: SP.XL })
        }
        .width('100%')
        .padding(SP.L)
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
