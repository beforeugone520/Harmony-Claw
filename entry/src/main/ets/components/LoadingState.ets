import { DesignTokens as DT, Spacing as SP, Animation as ANI } from '../constants'

/**
 * 骨架屏闪光效果组件
 */
@Component
struct ShimmerEffect {
  @State shimmerPosition: number = -100
  @Prop isDark: boolean = false

  aboutToAppear() {
    // 启动闪光动画
    this.startShimmer()
  }

  private startShimmer() {
    const animate = () => {
      this.shimmerPosition = 100
      setTimeout(() => {
        this.shimmerPosition = -100
        animate()
      }, 1500)
    }
    animate()
  }

  private getBgColor(): string {
    return this.isDark ? '#2C2C2E' : '#E5E5EA'
  }

  private getShimmerColor(): string {
    return this.isDark
      ? 'linear-gradient(90deg, rgba(60,60,65,0) 0%, rgba(80,80,85,0.5) 50%, rgba(60,60,65,0) 100%)'
      : 'linear-gradient(90deg, rgba(255,255,255,0) 0%, rgba(255,255,255,0.5) 50%, rgba(255,255,255,0) 100%)'
  }

  build() {
    Stack() {
      // 基础灰色背景
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor(this.getBgColor())

      // 闪光效果层
      Row()
        .width('40%')
        .height('100%')
        .backgroundColor(this.getShimmerColor())
        .position({ x: `${this.shimmerPosition}%`, y: 0 })
        .animation({
          duration: 1500,
          curve: Curve.Linear,
          iterations: -1
        })
    }
    .clip(true)
  }
}

/**
 * 骨架屏列表项组件
 */
@Component
struct SkeletonListItem {
  @Prop isDark: boolean = false

  build() {
    Row({ space: SP.M }) {
      // 图标占位
      ShimmerEffect({ isDark: this.isDark })
        .width(40)
        .height(40)
        .borderRadius(SP.RADIUS_S)

      Column({ space: SP.S }) {
        // 标题占位
        ShimmerEffect({ isDark: this.isDark })
          .width('60%')
          .height(16)
          .borderRadius(SP.RADIUS_XS)

        // 副标题占位
        ShimmerEffect({ isDark: this.isDark })
          .width('40%')
          .height(12)
          .borderRadius(SP.RADIUS_XS)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(SP.LIST_ITEM_HEIGHT)
    .padding({ left: SP.L, right: SP.L })
    .backgroundColor(this.isDark ? DT.DARK_SURFACE : DT.LIGHT_SURFACE)
  }
}

/**
 * 骨架屏卡片组件
 */
@Component
struct SkeletonCard {
  @Prop isDark: boolean = false

  build() {
    Column({ space: SP.M }) {
      // 标题区域
      Row({ space: SP.S }) {
        ShimmerEffect({ isDark: this.isDark })
          .width(48)
          .height(48)
          .borderRadius(SP.RADIUS_M)

        Column({ space: SP.XS }) {
          ShimmerEffect({ isDark: this.isDark })
            .width(120)
            .height(18)
            .borderRadius(SP.RADIUS_XS)

          ShimmerEffect({ isDark: this.isDark })
            .width(80)
            .height(14)
            .borderRadius(SP.RADIUS_XS)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      // 内容区域
      ShimmerEffect({ isDark: this.isDark })
        .width('100%')
        .height(60)
        .borderRadius(SP.RADIUS_S)
    }
    .width('100%')
    .padding(SP.L)
    .backgroundColor(this.isDark ? DT.DARK_SURFACE : DT.LIGHT_SURFACE)
    .borderRadius(SP.RADIUS_L)
    .shadow(this.isDark ? undefined : DT.SHADOW_RESTING)
  }
}

/**
 * 传统加载状态组件
 */
@Component
struct TraditionalLoading {
  @Prop message: string = 'Loading...'
  @Prop isDark: boolean = false

  build() {
    Column({ space: SP.L }) {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(DT.BRAND_PRIMARY)

      Text(this.message)
        .fontSize(16)
        .fontColor(this.isDark ? DT.DARK_TEXT_SECONDARY : DT.LIGHT_TEXT_SECONDARY)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

/**
 * LoadingState - 统一加载状态组件
 * 支持多种加载模式：传统旋转、骨架屏列表、骨架屏卡片
 */
@Component
export struct LoadingState {
  @Prop message: string = 'Loading...'
  @Prop mode: 'traditional' | 'skeleton-list' | 'skeleton-card' | 'skeleton-mixed' = 'traditional'
  @Prop itemCount: number = 5
  @Prop isDark: boolean = false

  build() {
    if (this.mode === 'traditional') {
      TraditionalLoading({ message: this.message, isDark: this.isDark })
    } else if (this.mode === 'skeleton-list') {
      this.SkeletonListBuilder()
    } else if (this.mode === 'skeleton-card') {
      this.SkeletonCardBuilder()
    } else {
      this.SkeletonMixedBuilder()
    }
  }

  @Builder
  SkeletonListBuilder() {
    Column({ space: 0 }) {
      ForEach(Array(this.itemCount).fill(0), (_: number, index: number) => {
        SkeletonListItem({ isDark: this.isDark })

        if (index < this.itemCount - 1) {
          Divider()
            .height(0.5)
            .color(this.isDark ? DT.DARK_BORDER : DT.LIGHT_BORDER)
            .margin({ left: SP.L })
        }
      })
    }
    .width('100%')
    .backgroundColor(this.isDark ? DT.DARK_SURFACE : DT.LIGHT_SURFACE)
    .borderRadius(SP.RADIUS_L)
  }

  @Builder
  SkeletonCardBuilder() {
    Column({ space: SP.M }) {
      ForEach(Array(this.itemCount).fill(0), () => {
        SkeletonCard({ isDark: this.isDark })
      })
    }
    .width('100%')
    .padding({ left: SP.L, right: SP.L })
  }

  @Builder
  SkeletonMixedBuilder() {
    Scroll() {
      Column({ space: SP.M }) {
        // 统计卡片骨架
        Row({ space: SP.M }) {
          ForEach(Array(3).fill(0), () => {
            Column({ space: SP.S }) {
              ShimmerEffect({ isDark: this.isDark })
                .width(40)
                .height(40)
                .borderRadius(SP.RADIUS_M)
              ShimmerEffect({ isDark: this.isDark })
                .width(50)
                .height(20)
                .borderRadius(SP.RADIUS_XS)
              ShimmerEffect({ isDark: this.isDark })
                .width(60)
                .height(12)
                .borderRadius(SP.RADIUS_XS)
            }
            .layoutWeight(1)
            .padding(SP.M)
            .backgroundColor(this.isDark ? DT.DARK_SURFACE : DT.LIGHT_SURFACE)
            .borderRadius(SP.RADIUS_L)
          })
        }
        .width('100%')

        // 列表骨架
        SkeletonListItem({ isDark: this.isDark })
        SkeletonListItem({ isDark: this.isDark })
        SkeletonListItem({ isDark: this.isDark })
      }
      .width('100%')
      .padding(SP.L)
    }
    .width('100%')
    .height('100%')
  }
}
