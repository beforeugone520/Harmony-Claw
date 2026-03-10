/**
 * HmCard.ets
 * HarmonyOS 6 风格卡片组件
 */
import { DesignTokens as DT, Spacing as SP, Animation as ANI, Typography as TYP } from '../../constants'

// 卡片变体
export enum CardVariant {
  ELEVATED,   // 带阴影
  OUTLINED,   // 带边框
  FILLED      // 填充背景
}

// 卡片圆角
export enum CardRadius {
  SMALL,   // 8vp
  MEDIUM,  // 12vp
  LARGE    // 16vp
}

@Component
export struct HmCard {
  // ========== 参数 ==========
  @Prop variant: CardVariant = CardVariant.ELEVATED
  @Prop radius: CardRadius = CardRadius.LARGE
  @Prop padding: Padding = {
    top: SP.CARD_PADDING,
    bottom: SP.CARD_PADDING,
    left: SP.CARD_PADDING,
    right: SP.CARD_PADDING
  }
  @Prop margin: Margin = { bottom: SP.CARD_GAP }
  @Prop width: Length = '100%'
  @Prop clickable: boolean = false
  @Prop disabled: boolean = false

  // 事件
  onClick?: () => void

  // 内部状态
  @State isPressed: boolean = false

  // ========== 样式计算 ==========
  private getBgColor(): ResourceColor {
    if (this.disabled) return DT.LIGHT_BG_SECONDARY
    switch (this.variant) {
      case CardVariant.ELEVATED: return DT.LIGHT_BG_PRIMARY
      case CardVariant.OUTLINED: return DT.LIGHT_BG_PRIMARY
      case CardVariant.FILLED: return DT.LIGHT_BG_SECONDARY
    }
  }

  private getBorderColor(): ResourceColor {
    if (this.disabled) return DT.LIGHT_BORDER_LIGHT
    switch (this.variant) {
      case CardVariant.OUTLINED: return DT.LIGHT_BORDER
      default: return 'transparent'
    }
  }

  private getBorderWidth(): number {
    return this.variant === CardVariant.OUTLINED ? 1 : 0
  }

  private getRadius(): number {
    switch (this.radius) {
      case CardRadius.SMALL: return SP.RADIUS_S
      case CardRadius.MEDIUM: return SP.RADIUS_M
      case CardRadius.LARGE: return SP.RADIUS_L
    }
  }

  private getShadow(): ShadowOptions | undefined {
    if (this.variant !== CardVariant.ELEVATED || this.disabled) return undefined
    return {
      radius: 8,
      color: DT.SHADOW_LIGHT,
      offsetX: 0,
      offsetY: 2
    }
  }

  private getPressScale(): number {
    if (!this.clickable) return 1.0
    return this.isPressed ? 0.99 : 1.0
  }

  build() {
    Column() {
      // 内容区域 - 使用 Builder 插槽
      this.CardContent()
    }
    .width(this.width)
    .backgroundColor(this.getBgColor())
    .borderWidth(this.getBorderWidth())
    .borderColor(this.getBorderColor())
    .borderRadius(this.getRadius())
    .shadow(this.getShadow())
    .padding(this.padding)
    .margin(this.margin)
    .scale({ x: this.getPressScale(), y: this.getPressScale() })
    .animation(ANI.pressFeedback())
    .gesture(
      this.clickable && !this.disabled
        ? TapGesture()
            .onAction(() => {
              if (this.onClick) {
                this.onClick()
              }
            })
        : GestureGroup(GestureMode.Sequence)
    )
    .onTouch((event: TouchEvent) => {
      if (this.clickable) {
        if (event.type === TouchType.Down) {
          this.isPressed = true
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.isPressed = false
        }
      }
    })
  }

  // ========== 内容插槽 ==========
  @Builder
  CardContent() {
    // 子组件将在这里渲染
  }
}

// ========== 列表卡片 ==========
@Component
export struct HmListCard {
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop description: string = ''
  @Prop icon?: Resource
  @Prop status?: string
  @Prop statusColor?: ResourceColor
  @Prop clickable: boolean = true
  @Prop showArrow: boolean = true

  onClick?: () => void

  build() {
    HmCard({
      variant: CardVariant.FILLED,
      radius: CardRadius.MEDIUM,
      padding: {
        top: SP.M,
        bottom: SP.M,
        left: SP.M,
        right: SP.S
      },
      clickable: this.clickable,
      onClick: this.onClick
    }) {
      Row() {
        // 图标
        if (this.icon) {
          Stack() {
            Image(this.icon)
              .width(40)
              .height(40)
              .borderRadius(SP.RADIUS_S)
              .objectFit(ImageFit.Cover)
          }
          .margin({ right: SP.M })
        }

        // 内容
        Column() {
          // 标题行
          Row() {
            Text(this.title)
              .fontSize(TYP.SIZE_BODY)
              .fontWeight(TYP.WEIGHT_MEDIUM)
              .fontColor(DT.LIGHT_TEXT_PRIMARY)
              .layoutWeight(1)

            if (this.status) {
              Text(this.status)
                .fontSize(TYP.SIZE_SMALL)
                .fontColor(this.statusColor || DT.LIGHT_TEXT_SECONDARY)
                .backgroundColor(DT.LIGHT_BG_SECONDARY)
                .padding({ left: SP.S, right: SP.S, top: 2, bottom: 2 })
                .borderRadius(SP.RADIUS_XS)
            }
          }
          .width('100%')

          // 副标题
          if (this.subtitle) {
            Text(this.subtitle)
              .fontSize(TYP.SIZE_CAPTION)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
              .margin({ top: 2 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }

          // 描述
          if (this.description) {
            Text(this.description)
              .fontSize(TYP.SIZE_SMALL)
              .fontColor(DT.LIGHT_TEXT_TERTIARY)
              .margin({ top: SP.XS })
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 箭头
        if (this.showArrow && this.clickable) {
          Image($r('app.media.ic_arrow_right'))
            .width(20)
            .height(20)
            .fillColor(DT.LIGHT_TEXT_TERTIARY)
            .margin({ left: SP.S })
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
  }
}

// ========== 信息卡片 ==========
@Component
export struct HmInfoCard {
  @Prop title: string = ''
  @Prop value: string = ''
  @Prop unit: string = ''
  @Prop icon?: Resource
  @Prop iconBgColor: ResourceColor = DT.BRAND_LIGHT
  @Prop iconColor: ResourceColor = DT.BRAND_PRIMARY

  build() {
    HmCard({
      variant: CardVariant.ELEVATED,
      radius: CardRadius.LARGE,
      padding: {
        top: SP.L,
        bottom: SP.L,
        left: SP.L,
        right: SP.L
      }
    }) {
      Column() {
        // 图标
        if (this.icon) {
          Stack() {
            Image(this.icon)
              .width(24)
              .height(24)
              .fillColor(this.iconColor)
          }
          .width(48)
          .height(48)
          .backgroundColor(this.iconBgColor)
          .borderRadius(SP.RADIUS_M)
          .margin({ bottom: SP.M })
        }

        // 标题
        Text(this.title)
          .fontSize(TYP.SIZE_CAPTION)
          .fontColor(DT.LIGHT_TEXT_SECONDARY)
          .margin({ bottom: SP.XS })

        // 数值
        Row() {
          Text(this.value)
            .fontSize(28)
            .fontWeight(TYP.WEIGHT_BOLD)
            .fontColor(DT.LIGHT_TEXT_PRIMARY)

          if (this.unit) {
            Text(this.unit)
              .fontSize(TYP.SIZE_CAPTION)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
              .margin({ left: SP.XS, bottom: 4 })
              .align(Alignment.Bottom)
          }
        }
        .alignItems(VerticalAlign.Bottom)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}
