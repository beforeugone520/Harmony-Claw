/**
 * HmDialog.ets
 * HarmonyOS 6 风格对话框组件
 */
import { DesignTokens as DT, Spacing as SP, Typography as TYP } from '../../constants'

@Component
export struct HmDialog {
  @Prop dialogVisible: boolean = false
  @Prop dialogTitle: string = ''
  @Prop dialogMessage: string = ''
  @Prop primaryBtnText: string = '确定'
  @Prop secondaryBtnText: string = '取消'
  @Prop showSecondaryBtn: boolean = true

  onPrimaryClick?: () => void
  onSecondaryClick?: () => void

  build() {
    Stack() {
      if (this.dialogVisible) {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(DT.OVERLAY_LIGHT)
          .onClick(() => {
            if (this.onSecondaryClick) {
              this.onSecondaryClick()
            }
          })

        // 对话框内容
        Column({ space: SP.M }) {
          // 标题
          Text(this.dialogTitle)
            .fontSize(TYP.SIZE_H3)
            .fontWeight(TYP.WEIGHT_BOLD)
            .fontColor(DT.LIGHT_TEXT_PRIMARY)
            .width('100%')

          // 消息内容
          if (this.dialogMessage) {
            Text(this.dialogMessage)
              .fontSize(TYP.SIZE_BODY)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
              .width('100%')
          }

          // 按钮区域
          Row({ space: SP.M }) {
            if (this.showSecondaryBtn) {
              Button(this.secondaryBtnText)
                .fontSize(TYP.SIZE_BODY)
                .fontColor(DT.LIGHT_TEXT_SECONDARY)
                .backgroundColor(Color.Transparent)
                .height(40)
                .onClick(() => {
                  if (this.onSecondaryClick) {
                    this.onSecondaryClick()
                  }
                })
            }

            Button(this.primaryBtnText)
              .fontSize(TYP.SIZE_BODY)
              .fontColor(DT.BRAND_PRIMARY)
              .backgroundColor(Color.Transparent)
              .height(40)
              .onClick(() => {
                if (this.onPrimaryClick) {
                  this.onPrimaryClick()
                }
              })
          }
          .width('100%')
          .height(56)
          .justifyContent(FlexAlign.End)
        }
        .width('80%')
        .padding(SP.L)
        .backgroundColor(DT.LIGHT_BG_PRIMARY)
        .borderRadius(SP.RADIUS_L)
        .shadow({
          radius: 24,
          color: DT.SHADOW_HEAVY,
          offsetX: 0,
          offsetY: 8
        })
      }
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }
}

@Component
export struct HmConfirmDialog {
  @Prop confirmVisible: boolean = false
  @Prop confirmTitle: string = '确认'
  @Prop confirmMessage: string = ''
  @Prop confirmBtnText: string = '确定'
  @Prop cancelBtnText: string = '取消'
  @Prop isDanger: boolean = false

  onConfirm?: () => void
  onCancel?: () => void

  build() {
    HmDialog({
      dialogVisible: this.confirmVisible,
      dialogTitle: this.confirmTitle,
      dialogMessage: this.confirmMessage,
      primaryBtnText: this.confirmBtnText,
      secondaryBtnText: this.cancelBtnText,
      showSecondaryBtn: true,
      onPrimaryClick: this.onConfirm,
      onSecondaryClick: this.onCancel
    })
  }
}
