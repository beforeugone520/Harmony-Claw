import { DesignTokens as DT, Spacing as SP, Typography as TYP, Animation as ANI } from '../constants'

/**
 * EmptyState - 统一空状态组件
 * 标准化插图风格：简约线条风格，品牌色点缀
 */
@Component
export struct EmptyState {
  @Prop title: string = 'No Data'
  @Prop message: string = 'There is nothing to display here.'
  @Prop icon: string = '📭' // 默认图标
  @Prop actionText: string = ''
  @Prop iconSize: 'small' | 'medium' | 'large' = 'large'
  @Prop isDark: boolean = false
  onAction?: () => void

  private getBgColor(): string {
    return this.isDark ? DT.DARK_BG_TERTIARY : DT.LIGHT_BG_PRIMARY
  }

  private getBorderColor(): string {
    return this.isDark ? DT.DARK_BORDER : DT.LIGHT_BORDER
  }

  private getIconSize(): number {
    switch (this.iconSize) {
      case 'small': return 40
      case 'medium': return 56
      case 'large':
      default: return 80
    }
  }

  private getContainerSize(): number {
    switch (this.iconSize) {
      case 'small': return 64
      case 'medium': return 80
      case 'large':
      default: return 120
    }
  }

  build() {
    Column({ space: SP.XL }) {
      // 图标容器 - 简约线条风格
      Column() {
        Text(this.icon)
          .fontSize(this.getIconSize())
          .opacity(0.8)
      }
      .width(this.getContainerSize())
      .height(this.getContainerSize())
      .backgroundColor(this.getBgColor())
      .borderRadius(SP.RADIUS_XL)
      .border({ width: 2, color: this.getBorderColor() })
      .justifyContent(FlexAlign.Center)
      .shadow(DT.SHADOW_RESTING)

      // 文字内容
      Column({ space: SP.S }) {
        Text(this.title)
          .fontSize(TYP.SIZE_H3)
          .fontWeight(TYP.WEIGHT_MEDIUM)
          .fontColor(this.isDark ? DT.DARK_TEXT_PRIMARY : DT.LIGHT_TEXT_PRIMARY)
          .textAlign(TextAlign.Center)

        Text(this.message)
          .fontSize(TYP.SIZE_CAPTION)
          .fontColor(this.isDark ? DT.DARK_TEXT_SECONDARY : DT.LIGHT_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .maxLines(3)
          .lineHeight(20)
      }
      .width('100%')
      .padding({ left: SP.XXL, right: SP.XXL })

      // 操作按钮
      if (this.actionText && this.onAction) {
        this.ActionButtonBuilder()
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  ActionButtonBuilder() {
    Row() {
      Text(this.actionText)
        .fontSize(TYP.SIZE_BODY)
        .fontWeight(TYP.WEIGHT_MEDIUM)
        .fontColor(DT.BRAND_PRIMARY)
    }
    .height(40)
    .padding({ left: SP.L, right: SP.L })
    .backgroundColor(DT.BRAND_LIGHT)
    .borderRadius(SP.RADIUS_M)
    .margin({ top: SP.M })
    .onClick(() => {
      if (this.onAction) {
        this.onAction()
      }
    })
  }
}

/**
 * EmptyStatePresets - 预设空状态场景
 */
export class EmptyStatePresets {
  static noData(onAction?: () => void): EmptyStateParams {
    return {
      icon: '📭',
      title: 'No Data',
      message: 'There is nothing to display here yet.',
      actionText: 'Refresh',
      onAction
    }
  }

  static noSearchResults(onAction?: () => void): EmptyStateParams {
    return {
      icon: '🔍',
      title: 'No Results',
      message: 'We could not find anything matching your search.',
      actionText: 'Clear Search',
      onAction
    }
  }

  static noNetwork(onAction?: () => void): EmptyStateParams {
    return {
      icon: '📡',
      title: 'No Connection',
      message: 'Please check your network settings and try again.',
      actionText: 'Retry',
      onAction
    }
  }

  static noPermissions(onAction?: () => void): EmptyStateParams {
    return {
      icon: '🔒',
      title: 'Access Denied',
      message: 'You do not have permission to view this content.',
      actionText: 'Request Access',
      onAction
    }
  }

  static emptyList(onAction?: () => void): EmptyStateParams {
    return {
      icon: '📝',
      title: 'Empty List',
      message: 'Get started by adding your first item.',
      actionText: 'Add New',
      onAction
    }
  }
}

/**
 * EmptyState参数接口
 */
export interface EmptyStateParams {
  icon: string
  title: string
  message: string
  actionText?: string
  onAction?: () => void
}
