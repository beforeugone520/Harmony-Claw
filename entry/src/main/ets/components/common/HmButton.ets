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

@Component
export struct HmButton {
  // ========== 参数 ==========
  @Prop btnText: string = ''
  @Prop btnType: ButtonType = ButtonType.PRIMARY
  @Prop btnSize: ButtonSize = ButtonSize.MEDIUM
  @Prop btnWidth: Length = '100%'
  @Prop btnDisabled: boolean = false
  @Prop btnLoading: boolean = false

  // 事件
  onBtnClick?: () => void

  // 内部状态
  @State isPressed: boolean = false

  // ========== 尺寸计算 ==========
  private getHeight(): number {
    switch (this.btnSize) {
      case ButtonSize.SMALL: return SP.BUTTON_HEIGHT_SMALL
      case ButtonSize.LARGE: return 48
      default: return SP.BUTTON_HEIGHT
    }
  }

  private getFontSize(): number {
    switch (this.btnSize) {
      case ButtonSize.SMALL: return TYP.SIZE_CAPTION
      default: return TYP.SIZE_BODY
    }
  }

  // ========== 颜色计算 ==========
  private getBgColor(): ResourceColor {
    if (this.btnDisabled) {
      switch (this.btnType) {
        case ButtonType.PRIMARY: return DT.BRAND_LIGHT
        default: return DT.LIGHT_BG_SECONDARY
      }
    }
    switch (this.btnType) {
      case ButtonType.PRIMARY: return DT.BRAND_PRIMARY
      case ButtonType.SECONDARY: return DT.LIGHT_BG_PRIMARY
      case ButtonType.TERTIARY: return 'transparent'
      case ButtonType.GHOST: return DT.LIGHT_BG_SECONDARY
    }
    return DT.BRAND_PRIMARY
  }

  private getTextColor(): ResourceColor {
    if (this.btnDisabled) {
      return this.btnType === ButtonType.PRIMARY ? DT.BRAND_TERTIARY : DT.LIGHT_TEXT_DISABLED
    }
    switch (this.btnType) {
      case ButtonType.PRIMARY: return '#FFFFFF'
      case ButtonType.SECONDARY: return DT.BRAND_PRIMARY
      case ButtonType.TERTIARY: return DT.BRAND_PRIMARY
      case ButtonType.GHOST: return DT.LIGHT_TEXT_PRIMARY
    }
    return DT.LIGHT_TEXT_PRIMARY
  }

  private getBorderColor(): ResourceColor {
    if (this.btnDisabled) return DT.LIGHT_BORDER
    switch (this.btnType) {
      case ButtonType.SECONDARY: return DT.BRAND_PRIMARY
      default: return 'transparent'
    }
  }

  build() {
    Row() {
      // 加载指示器
      if (this.btnLoading) {
        LoadingProgress()
          .width(16)
          .height(16)
          .color(this.btnType === ButtonType.PRIMARY ? Color.White : DT.BRAND_PRIMARY)
          .margin({ right: SP.S })
      }

      // 文字
      Text(this.btnText)
        .fontSize(this.getFontSize())
        .fontWeight(TYP.WEIGHT_MEDIUM)
        .fontColor(this.getTextColor())
    }
    .width(this.btnWidth)
    .height(this.getHeight())
    .backgroundColor(this.getBgColor())
    .borderWidth(this.btnType === ButtonType.SECONDARY ? 1 : 0)
    .borderColor(this.getBorderColor())
    .borderRadius(SP.RADIUS_M) // 统一12px圆角
    .justifyContent(FlexAlign.Center)
    .scale({ x: this.isPressed ? 0.97 : 1.0, y: this.isPressed ? 0.97 : 1.0 })
    .opacity(this.isPressed ? 0.95 : 1.0)
    .animation({ duration: ANI.DURATION_FAST, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        if (!this.btnDisabled && !this.btnLoading) {
          this.isPressed = true
        }
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false
      }
    })
    .onClick(() => {
      if (!this.btnDisabled && !this.btnLoading && this.onBtnClick) {
        this.onBtnClick()
      }
    })
  }
}
