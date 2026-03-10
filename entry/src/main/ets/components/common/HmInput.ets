/**
 * HmInput.ets
 * HarmonyOS 6 风格输入框组件
 */
import { DesignTokens as DT, Spacing as SP, Typography as TYP } from '../../constants'

// 输入框类型
export enum InputType {
  TEXT,      // 普通文本
  PASSWORD,  // 密码
  NUMBER,    // 数字
  EMAIL,     // 邮箱
  URL,       // URL
  SEARCH     // 搜索
}

@Component
export struct HmInput {
  // ========== 参数 ==========
  @Prop placeholder: string = ''
  @Prop label: string = ''
  @Prop type: InputType = InputType.TEXT
  @Prop width: Length = '100%'
  @Prop maxLength: number = 100
  @Prop showClear: boolean = true
  @Prop disabled: boolean = false
  @Prop errorMessage: string = ''

  // 双向绑定
  @State inputText: string = ''
  @Link @Watch('onTextChange') value: string

  // 内部状态
  @State isFocused: boolean = false
  @State showPassword: boolean = false

  // 事件
  onChange?: (value: string) => void
  onSubmit?: (value: string) => void
  onFocus?: () => void
  onBlur?: () => void

  // ========== 回调 ==========
  private onTextChange() {
    this.inputText = this.value
  }

  private getInputType(): InputType {
    if (this.type === InputType.PASSWORD) {
      return this.showPassword ? InputType.TEXT : InputType.PASSWORD
    }
    return this.type
  }

  private getKeyboardType(): KeyboardType {
    switch (this.type) {
      case InputType.NUMBER: return KeyboardType.Number
      case InputType.EMAIL: return KeyboardType.Email
      case InputType.URL: return KeyboardType.Url
      default: return KeyboardType.Normal
    }
  }

  // ========== 颜色计算 ==========
  private getBorderColor(): ResourceColor {
    if (this.errorMessage) return DT.ERROR
    if (this.isFocused) return DT.BRAND_PRIMARY
    return DT.LIGHT_BORDER
  }

  private getBgColor(): ResourceColor {
    if (this.disabled) return DT.LIGHT_BG_SECONDARY
    return DT.LIGHT_BG_PRIMARY
  }

  build() {
    Column() {
      // 标签
      if (this.label) {
        Text(this.label)
          .fontSize(TYP.SIZE_CAPTION)
          .fontColor(DT.LIGHT_TEXT_SECONDARY)
          .margin({ bottom: SP.XS })
          .alignSelf(ItemAlign.Start)
      }

      // 输入框容器
      Row() {
        // 输入框
        TextInput({ placeholder: this.placeholder, text: $$this.inputText })
          .placeholderColor(DT.LIGHT_TEXT_TERTIARY)
          .fontSize(TYP.SIZE_BODY)
          .fontColor(DT.LIGHT_TEXT_PRIMARY)
          .height(SP.INPUT_HEIGHT)
          .backgroundColor(Color.Transparent)
          .padding(0)
          .layoutWeight(1)
          .type(this.getInputType() === InputType.PASSWORD ? InputType.Password : InputType.Normal)
          .showPasswordIcon(false)
          .maxLength(this.maxLength)
          .enabled(!this.disabled)
          .keyboardType(this.getKeyboardType())
          .onChange((value: string) => {
            this.value = value
            if (this.onChange) {
              this.onChange(value)
            }
          })
          .onFocus(() => {
            this.isFocused = true
            if (this.onFocus) {
              this.onFocus()
            }
          })
          .onBlur(() => {
            this.isFocused = false
            if (this.onBlur) {
              this.onBlur()
            }
          })
          .onSubmit((enterKey: EnterKeyType) => {
            if (this.onSubmit) {
              this.onSubmit(this.inputText)
            }
          })

        // 清除按钮
        if (this.showClear && this.inputText && !this.disabled) {
          Button() {
            Image($r('app.media.ic_close'))
              .width(16)
              .height(16)
              .fillColor(DT.LIGHT_TEXT_TERTIARY)
          }
          .width(24)
          .height(24)
          .backgroundColor(Color.Transparent)
          .padding(4)
          .margin({ left: SP.S })
          .onClick(() => {
            this.inputText = ''
            this.value = ''
            if (this.onChange) {
              this.onChange('')
            }
          })
        }

        // 密码可见切换
        if (this.type === InputType.PASSWORD && !this.disabled) {
          Button() {
            Image(this.showPassword ? $r('app.media.ic_eye_open') : $r('app.media.ic_eye_close'))
              .width(20)
              .height(20)
              .fillColor(DT.LIGHT_TEXT_TERTIARY)
          }
          .width(32)
          .height(32)
          .backgroundColor(Color.Transparent)
          .padding(6)
          .margin({ left: SP.S })
          .onClick(() => {
            this.showPassword = !this.showPassword
          })
        }
      }
      .width('100%')
      .height(SP.INPUT_HEIGHT)
      .backgroundColor(this.getBgColor())
      .borderWidth(1)
      .borderColor(this.getBorderColor())
      .borderRadius(SP.RADIUS_M)
      .padding({ left: SP.M, right: SP.M })

      // 错误提示
      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize(TYP.SIZE_SMALL)
          .fontColor(DT.ERROR)
          .margin({ top: SP.XS, left: SP.S })
          .alignSelf(ItemAlign.Start)
      }
    }
    .width(this.width)
  }
}

// ========== 搜索输入框 ==========
@Component
export struct HmSearchInput {
  @State searchText: string = ''
  @Link value: string
  @Prop placeholder: string = '搜索'
  @Prop width: Length = '100%'

  onSubmit?: (value: string) => void
  onChange?: (value: string) => void

  build() {
    Row() {
      // 搜索图标
      Image($r('app.media.ic_search'))
        .width(20)
        .height(20)
        .fillColor(DT.LIGHT_TEXT_TERTIARY)
        .margin({ right: SP.S })

      // 输入框
      TextInput({ placeholder: this.placeholder, text: $$this.searchText })
        .placeholderColor(DT.LIGHT_TEXT_TERTIARY)
        .fontSize(TYP.SIZE_BODY)
        .fontColor(DT.LIGHT_TEXT_PRIMARY)
        .height(40)
        .backgroundColor(Color.Transparent)
        .padding(0)
        .layoutWeight(1)
        .onChange((value: string) => {
          this.value = value
          if (this.onChange) {
            this.onChange(value)
          }
        })
        .onSubmit((enterKey: EnterKeyType) => {
          if (this.onSubmit) {
            this.onSubmit(this.searchText)
          }
        })

      // 清除按钮
      if (this.searchText) {
        Button() {
          Image($r('app.media.ic_close'))
            .width(16)
            .height(16)
            .fillColor(DT.LIGHT_TEXT_TERTIARY)
        }
        .width(24)
        .height(24)
        .backgroundColor(Color.Transparent)
        .padding(4)
        .onClick(() => {
          this.searchText = ''
          this.value = ''
          if (this.onChange) {
            this.onChange('')
          }
        })
      }
    }
    .width(this.width)
    .height(40)
    .backgroundColor(DT.LIGHT_BG_SECONDARY)
    .borderRadius(SP.RADIUS_FULL)
    .padding({ left: SP.M, right: SP.M })
  }
}
