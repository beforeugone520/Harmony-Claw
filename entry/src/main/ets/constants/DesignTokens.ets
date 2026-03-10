/**
 * DesignTokens.ets
 * HarmonyOS 6 设计令牌 - 基于最新设计规范
 */

export class DesignTokens {
  // ========== 品牌色 ==========
  // 鸿蒙6强调色 - 蓝色系
  static readonly BRAND_PRIMARY = '#0A59F7'
  static readonly BRAND_SECONDARY = '#317AF7'
  static readonly BRAND_TERTIARY = '#5B9AF7'
  static readonly BRAND_LIGHT = '#E8F0FE'
  static readonly BRAND_BG = '#F5F9FF'

  // ========== 功能色 ==========
  // 成功 - 绿色
  static readonly SUCCESS = '#1BAF68'
  static readonly SUCCESS_BG = '#E8F8F0'
  static readonly SUCCESS_LIGHT = '#D1F2E3'

  // 警告 - 橙色
  static readonly WARNING = '#FF9500'
  static readonly WARNING_BG = '#FFF5E6'
  static readonly WARNING_LIGHT = '#FFE5BF'

  // 错误 - 红色
  static readonly ERROR = '#FA2C2C'
  static readonly ERROR_BG = '#FFEBEB'
  static readonly ERROR_LIGHT = '#FFD6D6'

  // 信息 - 灰色
  static readonly INFO = '#8A9199'
  static readonly INFO_BG = '#F2F3F5'

  // ========== 中性色 - 浅色模式 ==========
  // 背景色
  static readonly LIGHT_BG_PRIMARY = '#FFFFFF'
  static readonly LIGHT_BG_SECONDARY = '#F2F3F5'
  static readonly LIGHT_BG_TERTIARY = '#E5E6EB'

  // 表面色
  static readonly LIGHT_SURFACE = '#FFFFFF'
  static readonly LIGHT_SURFACE_VARIANT = '#F7F8FA'

  // 边框/分割线
  static readonly LIGHT_BORDER = '#E5E6EB'
  static readonly LIGHT_BORDER_LIGHT = '#F2F3F5'
  static readonly LIGHT_DIVIDER = '#E5E6EB'

  // 文字色
  static readonly LIGHT_TEXT_PRIMARY = '#1D2129'
  static readonly LIGHT_TEXT_SECONDARY = '#4E5969'
  static readonly LIGHT_TEXT_TERTIARY = '#86909C'
  static readonly LIGHT_TEXT_DISABLED = '#C9CDD4'

  // ========== 中性色 - 深色模式 ==========
  // 背景色
  static readonly DARK_BG_PRIMARY = '#17171A'
  static readonly DARK_BG_SECONDARY = '#232324'
  static readonly DARK_BG_TERTIARY = '#2E2E30'

  // 表面色
  static readonly DARK_SURFACE = '#2E2E30'
  static readonly DARK_SURFACE_VARIANT = '#373739'

  // 边框/分割线
  static readonly DARK_BORDER = '#484849'
  static readonly DARK_BORDER_LIGHT = '#373739'
  static readonly DARK_DIVIDER = '#484849'

  // 文字色
  static readonly DARK_TEXT_PRIMARY = '#F2F3F5'
  static readonly DARK_TEXT_SECONDARY = '#C9CDD4'
  static readonly DARK_TEXT_TERTIARY = '#86909C'
  static readonly DARK_TEXT_DISABLED = '#5C626A'

  // ========== 消息气泡 ==========
  // 用户消息
  static readonly USER_BUBBLE = '#0A59F7'
  static readonly USER_BUBBLE_TEXT = '#FFFFFF'

  // AI消息 - 浅色模式
  static readonly AI_BUBBLE_LIGHT = '#F2F3F5'
  static readonly AI_BUBBLE_TEXT_LIGHT = '#1D2129'

  // AI消息 - 深色模式
  static readonly AI_BUBBLE_DARK = '#2E2E30'
  static readonly AI_BUBBLE_TEXT_DARK = '#F2F3F5'

  // ========== 状态指示 ==========
  static readonly STATUS_ONLINE = '#1BAF68'
  static readonly STATUS_OFFLINE = '#C9CDD4'
  static readonly STATUS_BUSY = '#FF9500'
  static readonly STATUS_ERROR = '#FA2C2C'

  // ========== 阴影色 ==========
  static readonly SHADOW_LIGHT = 'rgba(0, 0, 0, 0.08)'
  static readonly SHADOW_MEDIUM = 'rgba(0, 0, 0, 0.12)'
  static readonly SHADOW_HEAVY = 'rgba(0, 0, 0, 0.16)'

  // ========== 蒙层 ==========
  static readonly OVERLAY_LIGHT = 'rgba(0, 0, 0, 0.40)'
  static readonly OVERLAY_DARK = 'rgba(0, 0, 0, 0.60)'

  // ========== 根据当前主题获取颜色 ==========
  static getThemeColor(isDark: boolean, lightColor: string, darkColor: string): string {
    return isDark ? darkColor : lightColor
  }
}

// 导出别名方便使用
export const DT = DesignTokens
