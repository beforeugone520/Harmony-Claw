/**
 * HmDialog.ets
 * HarmonyOS 6 风格对话框组件
 */
import { DesignTokens as DT, Spacing as SP, Animation as ANI, Typography as TYP } from '../../constants'

// 对话框类型
export enum DialogType {
  ALERT,      // 提示对话框
  CONFIRM,    // 确认对话框
  INPUT,      // 输入对话框
  ACTIONSHEET // 操作菜单
}

// 对话框按钮配置
export interface DialogButton {
  text: string
  type?: 'primary' | 'secondary' | 'danger'
  onClick?: () => void
}

@Component
export struct HmDialog {
  // ========== 参数 ==========
  @Prop visible: boolean = false
  @Prop title: string = ''
  @Prop message: string = ''
  @Prop type: DialogType = DialogType.ALERT
  @Prop showClose: boolean = true
  @Prop cancelable: boolean = true

  // 按钮配置
  @Prop primaryButton: DialogButton = { text: '确定', type: 'primary' }
  @Prop secondaryButton?: DialogButton

  // 事件
  onClose?: () => void
  onConfirm?: () => void
  onCancel?: () => void

  // 内部状态
  @State isAnimating: boolean = false
  @State displayVisible: boolean = false

  // ========== 动画控制 ==========
  aboutToAppear() {
    if (this.visible) {
      this.show()
    }
  }

  aboutToUpdate() {
    if (this.visible && !this.displayVisible) {
      this.show()
    } else if (!this.visible && this.displayVisible) {
      this.hide()
    }
  }

  private show() {
    this.displayVisible = true
    this.isAnimating = true
    setTimeout(() => {
      this.isAnimating = false
    }, ANI.DURATION_NORMAL)
  }

  private hide() {
    this.isAnimating = true
    setTimeout(() => {
      this.displayVisible = false
      this.isAnimating = false
      if (this.onClose) {
        this.onClose()
      }
    }, ANI.DURATION_NORMAL)
  }

  private handleCancel() {
    if (this.onCancel) {
      this.onCancel()
    }
    if (this.cancelable) {
      this.visible = false
      this.hide()
    }
  }

  private handleConfirm() {
    if (this.onConfirm) {
      this.onConfirm()
    }
    if (this.primaryButton.onClick) {
      this.primaryButton.onClick()
    }
  }

  // ========== 颜色计算 ==========
  private getButtonColor(type?: string): ResourceColor {
    switch (type) {
      case 'primary': return DT.BRAND_PRIMARY
      case 'danger': return DT.ERROR
      default: return DT.LIGHT_TEXT_SECONDARY
    }
  }

  build() {
    Stack() {
      if (this.displayVisible) {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(DT.OVERLAY_LIGHT)
          .opacity(this.visible ? 1 : 0)
          .animation({
            duration: ANI.DURATION_NORMAL,
            curve: Curve.EaseOut
          })
          .onClick(() => {
            if (this.cancelable) {
              this.handleCancel()
            }
          })

        // 对话框内容
        Column() {
          // 标题栏
          Row() {
            Text(this.title)
              .fontSize(TYP.SIZE_H3)
              .fontWeight(TYP.WEIGHT_BOLD)
              .fontColor(DT.LIGHT_TEXT_PRIMARY)
              .layoutWeight(1)

            if (this.showClose) {
              Button() {
                Image($r('app.media.ic_close'))
                  .width(20)
                  .height(20)
                  .fillColor(DT.LIGHT_TEXT_TERTIARY)
              }
              .width(32)
              .height(32)
              .backgroundColor(Color.Transparent)
              .onClick(() => this.handleCancel())
            }
          }
          .width('100%')
          .padding({
            top: SP.L,
            bottom: SP.M,
            left: SP.L,
            right: SP.L
          })

          // 消息内容
          if (this.message) {
            Text(this.message)
              .fontSize(TYP.SIZE_BODY)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
              .padding({
                left: SP.L,
                right: SP.L,
                bottom: SP.L
              })
              .width('100%')
          }

          // 自定义内容区域
          this.CustomContent()

          // 按钮区域
          Row() {
            if (this.secondaryButton) {
              Button(this.secondaryButton.text)
                .fontSize(TYP.SIZE_BODY)
                .fontColor(this.getButtonColor(this.secondaryButton.type))
                .backgroundColor(Color.Transparent)
                .height(40)
                .padding({ left: SP.L, right: SP.L })
                .onClick(() => {
                  if (this.secondaryButton?.onClick) {
                    this.secondaryButton.onClick()
                  }
                  this.handleCancel()
                })
            }

            Button(this.primaryButton.text)
              .fontSize(TYP.SIZE_BODY)
              .fontColor(this.getButtonColor(this.primaryButton.type))
              .backgroundColor(Color.Transparent)
              .height(40)
              .padding({ left: SP.L, right: SP.L })
              .onClick(() => this.handleConfirm())
          }
          .width('100%')
          .height(64)
          .padding({ left: SP.M, right: SP.M })
          .justifyContent(FlexAlign.End)
        }
        .width('85%')
        .backgroundColor(DT.LIGHT_BG_PRIMARY)
        .borderRadius(SP.RADIUS_L)
        .shadow({
          radius: 24,
          color: DT.SHADOW_HEAVY,
          offsetX: 0,
          offsetY: 8
        })
        .scale({
          x: this.visible ? 1 : 0.9,
          y: this.visible ? 1 : 0.9
        })
        .opacity(this.visible ? 1 : 0)
        .animation({
          duration: ANI.DURATION_NORMAL,
          curve: ANI.SPRING_NORMAL
        })
      }
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .visibility(this.displayVisible ? Visibility.Visible : Visibility.Hidden)
  }

  // ========== 自定义内容插槽 ==========
  @Builder
  CustomContent() {
    // 子组件可覆盖
  }
}

// ========== 确认对话框快捷组件 ==========
@Component
export struct HmConfirmDialog {
  @Prop visible: boolean = false
  @Prop title: string = '确认'
  @Prop message: string = ''
  @Prop confirmText: string = '确定'
  @Prop cancelText: string = '取消'
  @Prop danger: boolean = false

  onConfirm?: () => void
  onCancel?: () => void

  build() {
    HmDialog({
      visible: this.visible,
      title: this.title,
      message: this.message,
      type: DialogType.CONFIRM,
      primaryButton: {
        text: this.confirmText,
        type: this.danger ? 'danger' : 'primary',
        onClick: this.onConfirm
      },
      secondaryButton: {
        text: this.cancelText,
        onClick: this.onCancel
      },
      onCancel: this.onCancel
    })
  }
}

// ========== 操作菜单组件 ==========
@Component
export struct HmActionSheet {
  @Prop visible: boolean = false
  @Prop title: string = ''
  @Prop actions: ActionItem[] = []
  @Prop showCancel: boolean = true
  @Prop cancelText: string = '取消'

  onSelect?: (index: number, action: ActionItem) => void
  onCancel?: () => void

  build() {
    Stack() {
      if (this.visible) {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(DT.OVERLAY_LIGHT)
          .onClick(() => {
            if (this.onCancel) {
              this.onCancel()
            }
          })

        // 操作菜单
        Column() {
          // 标题
          if (this.title) {
            Text(this.title)
              .fontSize(TYP.SIZE_CAPTION)
              .fontColor(DT.LIGHT_TEXT_TERTIARY)
              .padding(SP.M)
              .width('100%')
              .textAlign(TextAlign.Center)
          }

          // 操作项
          ForEach(this.actions, (action: ActionItem, index: number) => {
            Column() {
              Text(action.text)
                .fontSize(TYP.SIZE_BODY)
                .fontColor(action.danger ? DT.ERROR : DT.LIGHT_TEXT_PRIMARY)
                .padding(SP.M)
            }
            .width('100%')
            .backgroundColor(DT.LIGHT_BG_PRIMARY)
            .onClick(() => {
              if (this.onSelect) {
                this.onSelect(index, action)
              }
            })

            if (index < this.actions.length - 1) {
              Divider()
                .strokeWidth(0.5)
                .color(DT.LIGHT_BORDER)
            }
          })

          // 取消按钮
          if (this.showCancel) {
            Divider()
              .strokeWidth(8)
              .color(DT.LIGHT_BG_SECONDARY)

            Text(this.cancelText)
              .fontSize(TYP.SIZE_BODY)
              .fontWeight(TYP.WEIGHT_MEDIUM)
              .fontColor(DT.LIGHT_TEXT_PRIMARY)
              .padding(SP.M)
              .width('100%')
              .textAlign(TextAlign.Center)
              .backgroundColor(DT.LIGHT_BG_PRIMARY)
              .onClick(() => {
                if (this.onCancel) {
                  this.onCancel()
                }
              })
          }
        }
        .width('100%')
        .backgroundColor(DT.LIGHT_BG_PRIMARY)
        .borderRadius({ topLeft: SP.RADIUS_L, topRight: SP.RADIUS_L })
        .position({ x: 0, y: '100%' })
        .translate({ y: this.visible ? '-100%' : '0%' })
        .animation({
          duration: ANI.DURATION_NORMAL,
          curve: ANI.SPRING_NORMAL
        })
      }
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }
}

// 操作项接口
export interface ActionItem {
  text: string
  danger?: boolean
  icon?: Resource
}
