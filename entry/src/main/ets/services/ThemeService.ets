/**
 * ThemeService.ets
 * 主题管理服务 - 支持深色模式
 */

import { DesignTokens as DT } from '../constants'

/**
 * 主题模式枚举
 */
export enum ThemeMode {
  LIGHT = 'light',
  DARK = 'dark',
  SYSTEM = 'system'
}

/**
 * 主题服务类
 * 管理应用的主题状态，支持深色/浅色模式切换
 */
export class ThemeService {
  // 存储键名
  private static readonly STORAGE_KEY = 'app_theme_mode'

  // 当前主题模式
  static currentMode: ThemeMode = ThemeMode.LIGHT

  // 是否跟随系统
  static followSystem: boolean = true

  /**
   * 初始化主题服务
   */
  static initialize(): void {
    // 从存储中读取主题设置
    const savedMode = AppStorage.get<string>(ThemeService.STORAGE_KEY)
    if (savedMode) {
      ThemeService.currentMode = savedMode as ThemeMode
      ThemeService.followSystem = savedMode === ThemeMode.SYSTEM
    }

    // 初始化 AppStorage 中的主题状态
    const currentIsDark = ThemeService.isDarkMode()
    AppStorage.setOrCreate('isDarkMode', currentIsDark)
    AppStorage.setOrCreate('themeChanged', Date.now())
  }

  /**
   * 更新系统主题状态
   */
  static updateSystemTheme(isDark: boolean): void {
    AppStorage.set('isDarkMode', isDark)
    // 如果是跟随系统模式，触发主题变化
    if (ThemeService.followSystem) {
      AppStorage.set('themeChanged', Date.now())
    }
  }

  /**
   * 检查当前是否为深色模式
   */
  static isDarkMode(): boolean {
    if (ThemeService.followSystem) {
      // 返回系统主题状态（这里简化处理，实际应调用系统API）
      return AppStorage.get<boolean>('isDarkMode') ?? false
    }
    return ThemeService.currentMode === ThemeMode.DARK
  }

  /**
   * 设置主题模式
   */
  static setThemeMode(mode: ThemeMode): void {
    ThemeService.currentMode = mode
    ThemeService.followSystem = mode === ThemeMode.SYSTEM
    AppStorage.set(ThemeService.STORAGE_KEY, mode)

    // 触发主题变化事件
    AppStorage.set('themeChanged', Date.now())
  }

  /**
   * 切换深色/浅色模式
   */
  static toggleDarkMode(): void {
    const newMode = ThemeService.isDarkMode() ? ThemeMode.LIGHT : ThemeMode.DARK
    ThemeService.setThemeMode(newMode)
  }

  /**
   * 获取当前背景色（主）
   */
  static getBgPrimary(): ResourceColor {
    return ThemeService.isDarkMode() ? DT.DARK_BG_PRIMARY : DT.LIGHT_BG_PRIMARY
  }

  /**
   * 获取当前背景色（次）
   */
  static getBgSecondary(): ResourceColor {
    return ThemeService.isDarkMode() ? DT.DARK_BG_SECONDARY : DT.LIGHT_BG_SECONDARY
  }

  /**
   * 获取当前背景色（第三级）
   */
  static getBgTertiary(): ResourceColor {
    return ThemeService.isDarkMode() ? DT.DARK_BG_TERTIARY : DT.LIGHT_BG_TERTIARY
  }

  /**
   * 获取当前文字颜色（主）
   */
  static getTextPrimary(): ResourceColor {
    return ThemeService.isDarkMode() ? DT.DARK_TEXT_PRIMARY : DT.LIGHT_TEXT_PRIMARY
  }

  /**
   * 获取当前文字颜色（次）
   */
  static getTextSecondary(): ResourceColor {
    return ThemeService.isDarkMode() ? DT.DARK_TEXT_SECONDARY : DT.LIGHT_TEXT_SECONDARY
  }

  /**
   * 获取当前文字颜色（第三级）
   */
  static getTextTertiary(): ResourceColor {
    return ThemeService.isDarkMode() ? DT.DARK_TEXT_TERTIARY : DT.LIGHT_TEXT_TERTIARY
  }

  /**
   * 获取当前表面色
   */
  static getSurface(): ResourceColor {
    return ThemeService.isDarkMode() ? DT.DARK_SURFACE : DT.LIGHT_SURFACE
  }

  /**
   * 获取当前表面色变体
   */
  static getSurfaceVariant(): ResourceColor {
    return ThemeService.isDarkMode() ? DT.DARK_SURFACE_VARIANT : DT.LIGHT_SURFACE_VARIANT
  }

  /**
   * 获取当前边框色
   */
  static getBorder(): ResourceColor {
    return ThemeService.isDarkMode() ? DT.DARK_BORDER : DT.LIGHT_BORDER
  }

  /**
   * 获取当前分割线颜色
   */
  static getDivider(): ResourceColor {
    return ThemeService.isDarkMode() ? DT.DARK_DIVIDER : DT.LIGHT_DIVIDER
  }

  /**
   * 获取AI消息气泡背景色
   */
  static getAiBubbleBg(): ResourceColor {
    return ThemeService.isDarkMode() ? DT.AI_BUBBLE_DARK : DT.AI_BUBBLE_LIGHT
  }

  /**
   * 获取AI消息气泡文字颜色
   */
  static getAiBubbleText(): ResourceColor {
    return ThemeService.isDarkMode() ? DT.AI_BUBBLE_TEXT_DARK : DT.AI_BUBBLE_TEXT_LIGHT
  }
}

/**
 * 便捷函数：检查是否为深色模式
 */
export function isDarkMode(): boolean {
  return ThemeService.isDarkMode()
}

/**
 * 便捷函数：获取主题颜色
 */
export function getThemeColor(lightColor: string, darkColor: string): string {
  return ThemeService.isDarkMode() ? darkColor : lightColor
}
