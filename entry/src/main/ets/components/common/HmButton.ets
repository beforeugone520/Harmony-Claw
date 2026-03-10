/**
 * HmButton.ets
 * HarmonyOS 6 风格按钮组件
 */
import { DesignTokens as DT, Spacing as SP, Animation as ANI, Typography as TYP } from '../../constants'

// 按钮类型
export enum ButtonType {
  PRIMARY,    // 主按钮 - 实心品牌色
  SECONDARY,  // 次按钮 - 描边样式
  TERTIARY,   // 三级按钮 - 文字样式
  GHOST       // 幽灵按钮 - 浅色背景
}

// 按钮尺寸
export enum ButtonSize {
  SMALL,   // 小尺寸
  MEDIUM,  // 中尺寸（默认）
  LARGE    // 大尺寸
}

// 按钮状态
interface ButtonState {
  isPressed: boolean
  isEnabled: boolean
  isLoading: boolean
}

@Component
export struct HmButton {
  // ========== 参数 ==========
  @Prop text: string = ''
  @Prop type: ButtonType = ButtonType.PRIMARY
  @Prop size: ButtonSize = ButtonSize.MEDIUM
  @Prop width: Length = '100%'
  @Prop icon?: Resource
  @Prop disabled: boolean = false
  @Prop loading: boolean = false

  // 事件
  onClick?: () => void

  // 内部状态
  @State isPressed: boolean = false

  // ========== 尺寸计算 ==========
  private getHeight(): number {
    switch (this.size) {
      case ButtonSize.SMALL: return SP.BUTTON_HEIGHT_SMALL
      case ButtonSize.LARGE: return 48
      default: return SP.BUTTON_HEIGHT
    }
  }

  private getFontSize(): number {
    switch (this.size) {
      case ButtonSize.SMALL: return TYP.SIZE_CAPTION
      default: return TYP.SIZE_BODY
    }
  }

  // ========== 颜色计算 ==========
  private getBgColor(): ResourceColor {
    if (!this.disabled) {
      switch (this.type) {
        case ButtonType.PRIMARY: return DT.BRAND_PRIMARY
        case ButtonType.SECONDARY: return DT.LIGHT_BG_PRIMARY
        case ButtonType.TERTIARY: return 'transparent'
        case ButtonType.GHOST: return DT.LIGHT_BG_SECONDARY
      }
    }
    switch (this.type) {
      case ButtonType.PRIMARY: return DT.BRAND_LIGHT
      default: return DT.LIGHT_BG_SECONDARY
    }
  }

  private getTextColor(): ResourceColor {
    if (this.disabled) {
      return this.type === ButtonType.PRIMARY ? DT.BRAND_TERTIARY : DT.LIGHT_TEXT_DISABLED
    }
    switch (this.type) {
      case ButtonType.PRIMARY: return '#FFFFFF'
      case ButtonType.SECONDARY: return DT.BRAND_PRIMARY
      case ButtonType.TERTIARY: return DT.BRAND_PRIMARY
      case ButtonType.GHOST: return DT.LIGHT_TEXT_PRIMARY
    }
  }

  private getBorderColor(): ResourceColor {
    if (this.disabled) return DT.LIGHT_BORDER
    switch (this.type) {
      case ButtonType.SECONDARY: return DT.BRAND_PRIMARY
      default: return 'transparent'
    }
  }

  // ========== 按压效果 ==========
  private getPressScale(): number {
    return this.isPressed ? 0.98 : 1.0
  }

  private getPressOpacity(): number {
    return this.isPressed ? 0.9 : 1.0
  }

  build() {
    Row() {
      // 加载指示器
      if (this.loading) {
        LoadingProgress()
          .width(16)
          .height(16)
          .color(this.type === ButtonType.PRIMARY ? Color.White : DT.BRAND_PRIMARY)
          .margin({ right: SP.S })
      }

      // 图标
      if (this.icon && !this.loading) {
        Image(this.icon)
          .width(16)
          .height(16)
          .fillColor(this.getTextColor())
          .margin({ right: SP.S })
      }

      // 文字
      Text(this.text)
        .fontSize(this.getFontSize())
        .fontWeight(TYP.WEIGHT_MEDIUM)
        .fontColor(this.getTextColor())
    }
    .width(this.width)
    .height(this.getHeight())
    .backgroundColor(this.getBgColor())
    .borderWidth(this.type === ButtonType.SECONDARY ? 1 : 0)
    .borderColor(this.getBorderColor())
    .borderRadius(SP.RADIUS_S)
    .justifyContent(FlexAlign.Center)
    .scale({ x: this.getPressScale(), y: this.getPressScale() })
    .opacity(this.getPressOpacity())
    .animation(ANI.pressFeedback())
    .gesture(
      GestureGroup(GestureMode.Sequence,
        LongPressGesture({ duration: 1 })
          .onAction(() => {
            if (!this.disabled && !this.loading) {
              this.isPressed = true
            }
          })
          .onActionEnd(() => {
            this.isPressed = false
          }),
        TapGesture()
          .onAction(() => {
            if (!this.disabled && !this.loading && this.onClick) {
              this.onClick()
            }
          })
      )
    )
  }
}

// ========== 预设按钮 ==========
@Component
export struct HmPrimaryButton {
  @Prop text: string = ''
  @Prop width: Length = '100%'
  @Prop disabled: boolean = false
  @Prop loading: boolean = false
  onClick?: () => void

  build() {
    HmButton({
      text: this.text,
      type: ButtonType.PRIMARY,
      width: this.width,
      disabled: this.disabled,
      loading: this.loading,
      onClick: this.onClick
    })
  }
}

@Component
export struct HmSecondaryButton {
  @Prop text: string = ''
  @Prop width: Length = '100%'
  @Prop disabled: boolean = false
  onClick?: () => void

  build() {
    HmButton({
      text: this.text,
      type: ButtonType.SECONDARY,
      width: this.width,
      disabled: this.disabled,
      onClick: this.onClick
    })
  }
}
