/**
 * HmInput.ets
 * HarmonyOS 6 风格输入框组件
 */
import { DesignTokens as DT, Spacing as SP, Typography as TYP } from '../../constants'

@Component
export struct HmInput {
  // ========== 参数 ==========
  @Prop inputPlaceholder: string = ''
  @Prop inputLabel: string = ''
  @Prop inputWidth: Length = '100%'
  @Prop inputMaxLength: number = 100
  @Prop inputDisabled: boolean = false
  @Prop inputError: string = ''

  // 使用 @Link 实现双向绑定
  @Link inputValue: string

  // 事件
  onInputChange?: (value: string) => void

  private getBorderColor(): ResourceColor {
    if (this.inputError) return DT.ERROR
    return DT.LIGHT_BORDER
  }

  private getBgColor(): ResourceColor {
    if (this.inputDisabled) return DT.LIGHT_BG_SECONDARY
    return DT.LIGHT_BG_PRIMARY
  }

  build() {
    Column() {
      // 标签
      if (this.inputLabel) {
        Text(this.inputLabel)
          .fontSize(TYP.SIZE_CAPTION)
          .fontColor(DT.LIGHT_TEXT_SECONDARY)
          .margin({ bottom: SP.XS })
          .alignSelf(ItemAlign.Start)
      }

      // 输入框容器
      Row() {
        // 输入框 - 使用 $$ 双向绑定
        TextInput({ placeholder: this.inputPlaceholder, text: $$this.inputValue })
          .placeholderColor(DT.LIGHT_TEXT_TERTIARY)
          .fontSize(TYP.SIZE_BODY)
          .fontColor(DT.LIGHT_TEXT_PRIMARY)
          .height(44)
          .backgroundColor(Color.Transparent)
          .padding(0)
          .layoutWeight(1)
          .maxLength(this.inputMaxLength)
          .enabled(!this.inputDisabled)
          .onChange((value: string) => {
            if (this.onInputChange) {
              this.onInputChange(value)
            }
          })
      }
      .width('100%')
      .height(44)
      .backgroundColor(this.getBgColor())
      .borderWidth(1)
      .borderColor(this.getBorderColor())
      .borderRadius(SP.RADIUS_M)
      .padding({ left: SP.M, right: SP.M })

      // 错误提示
      if (this.inputError) {
        Text(this.inputError)
          .fontSize(TYP.SIZE_SMALL)
          .fontColor(DT.ERROR)
          .margin({ top: SP.XS, left: SP.S })
          .alignSelf(ItemAlign.Start)
      }
    }
    .width(this.inputWidth)
  }
}

// ========== 搜索输入框 ==========
@Component
export struct HmSearchInput {
  @State searchValue: string = ''
  @Prop searchPlaceholder: string = '搜索'
  @Prop searchWidth: Length = '100%'

  onSearchChange?: (value: string) => void
  onSearchSubmit?: (value: string) => void

  build() {
    Row() {
      Text('🔍')
        .fontSize(16)
        .margin({ right: SP.S })

      TextInput({ placeholder: this.searchPlaceholder, text: $$this.searchValue })
        .placeholderColor(DT.LIGHT_TEXT_TERTIARY)
        .fontSize(TYP.SIZE_BODY)
        .fontColor(DT.LIGHT_TEXT_PRIMARY)
        .height(40)
        .backgroundColor(Color.Transparent)
        .padding(0)
        .layoutWeight(1)
        .onChange((value: string) => {
          if (this.onSearchChange) {
            this.onSearchChange(value)
          }
        })
        .onSubmit((enterKey) => {
          if (this.onSearchSubmit) {
            this.onSearchSubmit(this.searchValue)
          }
        })
    }
    .width(this.searchWidth)
    .height(40)
    .backgroundColor(DT.LIGHT_BG_SECONDARY)
    .borderRadius(20)
    .padding({ left: SP.M, right: SP.M })
  }
}
