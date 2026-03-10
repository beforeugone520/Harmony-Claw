/**
 * HmToast.ets
 * HarmonyOS 6 风格轻提示组件
 */
import { DesignTokens as DT, Spacing as SP, Animation as ANI, Typography as TYP } from '../../constants'

// Toast 类型
export enum ToastType {
  INFO,
  SUCCESS,
  WARNING,
  ERROR,
  LOADING
}

// Toast 位置
export enum ToastPosition {
  TOP,
  CENTER,
  BOTTOM
}

// Toast 配置接口
export interface ToastOptions {
  message: string
  type?: ToastType
  position?: ToastPosition
  duration?: number
  icon?: Resource
}

@Component
export struct HmToast {
  // ========== 参数 ==========
  @Prop visible: boolean = false
  @Prop message: string = ''
  @Prop type: ToastType = ToastType.INFO
  @Prop position: ToastPosition = ToastPosition.CENTER
  @Prop showIcon: boolean = true

  // 内部状态
  @State isAnimating: boolean = false
  @State displayVisible: boolean = false

  // ========== 图标和颜色 ==========
  private getIcon(): Resource {
    switch (this.type) {
      case ToastType.SUCCESS: return $r('app.media.ic_success')
      case ToastType.WARNING: return $r('app.media.ic_warning')
      case ToastType.ERROR: return $r('app.media.ic_error')
      case ToastType.LOADING: return $r('app.media.ic_loading')
      default: return $r('app.media.ic_info')
    }
  }

  private getBgColor(): ResourceColor {
    switch (this.type) {
      case ToastType.SUCCESS: return DT.SUCCESS_BG
      case ToastType.WARNING: return DT.WARNING_BG
      case ToastType.ERROR: return DT.ERROR_BG
      default: return DT.INFO_BG
    }
  }

  private getIconColor(): ResourceColor {
    switch (this.type) {
      case ToastType.SUCCESS: return DT.SUCCESS
      case ToastType.WARNING: return DT.WARNING
      case ToastType.ERROR: return DT.ERROR
      default: return DT.INFO
    }
  }

  private getPositionY(): string {
    switch (this.position) {
      case ToastPosition.TOP: return '15%'
      case ToastPosition.BOTTOM: return '85%'
      default: return '50%'
    }
  }

  build() {
    Stack() {
      if (this.displayVisible) {
        Row() {
          // 图标
          if (this.showIcon) {
            if (this.type === ToastType.LOADING) {
              LoadingProgress()
                .width(20)
                .height(20)
                .color(DT.LIGHT_TEXT_PRIMARY)
                .margin({ right: SP.S })
            } else {
              Image(this.getIcon())
                .width(20)
                .height(20)
                .fillColor(this.getIconColor())
                .margin({ right: SP.S })
            }
          }

          // 文字
          Text(this.message)
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
        .opacity(this.visible ? 1 : 0)
        .scale({
          x: this.visible ? 1 : 0.8,
          y: this.visible ? 1 : 0.8
        })
        .translate({ y: this.visible ? 0 : 20 })
        .animation({
          duration: ANI.DURATION_FAST,
          curve: ANI.SPRING_LIGHT
        })
      }
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .align(Alignment.Center)
    .visibility(this.displayVisible ? Visibility.Visible : Visibility.Hidden)
    .offset({ y: this.getPositionY() })
    .pointerEvents(PointerEvents.None)
  }
}

// ========== Toast 管理器 ==========
export class ToastManager {
  private static instance: ToastManager
  private currentToast: HmToast | null = null

  static getInstance(): ToastManager {
    if (!ToastManager.instance) {
      ToastManager.instance = new ToastManager()
    }
    return ToastManager.instance
  }

  // 显示 Toast
  show(options: ToastOptions) {
    // 这里可以通过 AppStorage 或事件总线来触发全局 Toast
    AppStorage.setOrCreate('toast_message', options.message)
    AppStorage.setOrCreate('toast_type', options.type ?? ToastType.INFO)
    AppStorage.setOrCreate('toast_position', options.position ?? ToastPosition.CENTER)
    AppStorage.setOrCreate('toast_visible', true)

    // 自动隐藏
    const duration = options.duration ?? 2000
    if (options.type !== ToastType.LOADING) {
      setTimeout(() => {
        this.hide()
      }, duration)
    }
  }

  // 隐藏 Toast
  hide() {
    AppStorage.setOrCreate('toast_visible', false)
  }

  // 快捷方法
  static info(message: string, duration?: number) {
    ToastManager.getInstance().show({ message, type: ToastType.INFO, duration })
  }

  static success(message: string, duration?: number) {
    ToastManager.getInstance().show({ message, type: ToastType.SUCCESS, duration })
  }

  static warning(message: string, duration?: number) {
    ToastManager.getInstance().show({ message, type: ToastType.WARNING, duration })
  }

  static error(message: string, duration?: number) {
    ToastManager.getInstance().show({ message, type: ToastType.ERROR, duration })
  }

  static loading(message: string = '加载中...') {
    ToastManager.getInstance().show({ message, type: ToastType.LOADING, duration: 0 })
  }

  static hideLoading() {
    ToastManager.getInstance().hide()
  }
}

// ========== 全局 Toast 组件 ==========
@Component
export struct GlobalToast {
  @StorageLink('toast_visible') visible: boolean = false
  @StorageLink('toast_message') message: string = ''
  @StorageLink('toast_type') type: ToastType = ToastType.INFO
  @StorageLink('toast_position') position: ToastPosition = ToastPosition.CENTER

  build() {
    HmToast({
      visible: this.visible,
      message: this.message,
      type: this.type,
      position: this.position
    })
  }
}
