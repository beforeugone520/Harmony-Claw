/**
 * HmToast.ets
 * HarmonyOS 6 风格轻提示组件
 */
import { DesignTokens as DT, Spacing as SP, Typography as TYP } from '../../constants'

// Toast 类型
export enum ToastType {
  INFO,
  SUCCESS,
  WARNING,
  ERROR,
  LOADING
}

@Component
export struct HmToast {
  @Prop toastVisible: boolean = false
  @Prop toastMessage: string = ''
  @Prop toastType: ToastType = ToastType.INFO

  private getIcon(): string {
    switch (this.toastType) {
      case ToastType.SUCCESS: return '✓'
      case ToastType.WARNING: return '!'
      case ToastType.ERROR: return '✕'
      case ToastType.LOADING: return '⟳'
      default: return 'ℹ'
    }
  }

  private getIconColor(): ResourceColor {
    switch (this.toastType) {
      case ToastType.SUCCESS: return DT.SUCCESS
      case ToastType.WARNING: return DT.WARNING
      case ToastType.ERROR: return DT.ERROR
      default: return DT.INFO
    }
  }

  build() {
    Stack() {
      if (this.toastVisible) {
        Row({ space: SP.S }) {
          if (this.toastType === ToastType.LOADING) {
            LoadingProgress()
              .width(20)
              .height(20)
              .color(DT.LIGHT_TEXT_PRIMARY)
          } else {
            Text(this.getIcon())
              .fontSize(16)
              .fontColor(this.getIconColor())
          }

          Text(this.toastMessage)
            .fontSize(TYP.SIZE_BODY)
            .fontColor(DT.LIGHT_TEXT_PRIMARY)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .padding({ left: SP.M, right: SP.M, top: SP.S, bottom: SP.S })
        .backgroundColor(DT.LIGHT_BG_PRIMARY)
        .borderRadius(SP.RADIUS_M)
        .shadow({
          radius: 16,
          color: DT.SHADOW_MEDIUM,
          offsetX: 0,
          offsetY: 4
        })
      }
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .align(Alignment.Center)
  }
}

// Toast 管理器
export class ToastManager {
  private static instance: ToastManager

  static getInstance(): ToastManager {
    if (!ToastManager.instance) {
      ToastManager.instance = new ToastManager()
    }
    return ToastManager.instance
  }

  show(message: string, type: ToastType = ToastType.INFO, duration: number = 2000) {
    AppStorage.setOrCreate('toast_message', message)
    AppStorage.setOrCreate('toast_type', type)
    AppStorage.setOrCreate('toast_visible', true)

    if (type !== ToastType.LOADING) {
      setTimeout(() => {
        AppStorage.setOrCreate('toast_visible', false)
      }, duration)
    }
  }

  hide() {
    AppStorage.setOrCreate('toast_visible', false)
  }

  static info(message: string, duration?: number) {
    ToastManager.getInstance().show(message, ToastType.INFO, duration)
  }

  static success(message: string, duration?: number) {
    ToastManager.getInstance().show(message, ToastType.SUCCESS, duration)
  }

  static warning(message: string, duration?: number) {
    ToastManager.getInstance().show(message, ToastType.WARNING, duration)
  }

  static error(message: string, duration?: number) {
    ToastManager.getInstance().show(message, ToastType.ERROR, duration)
  }

  static loading(message: string = '加载中...') {
    ToastManager.getInstance().show(message, ToastType.LOADING, 0)
  }

  static hideLoading() {
    ToastManager.getInstance().hide()
  }
}

@Component
export struct GlobalToast {
  @StorageLink('toast_visible') visible: boolean = false
  @StorageLink('toast_message') message: string = ''
  @StorageLink('toast_type') type: ToastType = ToastType.INFO

  build() {
    HmToast({
      toastVisible: this.visible,
      toastMessage: this.message,
      toastType: this.type
    })
  }
}
