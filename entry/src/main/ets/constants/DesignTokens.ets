/**
 * DesignTokens.ets
 * iOS-style Design System for Harmony Claw
 */

export class DesignTokens {
  // ========== iOS Brand Colors ==========
  static readonly BRAND_PRIMARY = '#007AFF'      // iOS Blue
  static readonly BRAND_SECONDARY = '#5856D6'    // iOS Indigo/Purple
  static readonly BRAND_ACCENT = '#FF9500'       // iOS Orange
  static readonly BRAND_TERTIARY = '#5AC8FA'     // iOS Teal
  static readonly BRAND_LIGHT = '#E8F4FD'        // Light blue background

  // ========== iOS System Colors ==========
  static readonly IOS_BLUE = '#007AFF'
  static readonly IOS_INDIGO = '#5856D6'
  static readonly IOS_PURPLE = '#AF52DE'
  static readonly IOS_PINK = '#FF2D55'
  static readonly IOS_RED = '#FF3B30'
  static readonly IOS_ORANGE = '#FF9500'
  static readonly IOS_YELLOW = '#FFCC00'
  static readonly IOS_GREEN = '#34C759'
  static readonly IOS_TEAL = '#5AC8FA'
  static readonly IOS_CYAN = '#32ADE6'

  // ========== Functional Colors ==========
  static readonly SUCCESS = '#34C759'            // iOS Green
  static readonly SUCCESS_BG = '#E8F8F0'         // Success background
  static readonly WARNING = '#FF9500'            // iOS Orange
  static readonly WARNING_BG = '#FFF5E6'         // Warning background
  static readonly ERROR = '#FF3B30'              // iOS Red
  static readonly ERROR_BG = '#FFEBEB'           // Error background
  static readonly INFO = '#5856D6'               // iOS Indigo
  static readonly INFO_BG = '#F0F0FF'            // Info background

  // ========== Light Mode Colors ==========
  // Backgrounds
  static readonly LIGHT_BG_PRIMARY = '#F2F2F7'   // iOS System Gray 6
  static readonly LIGHT_BG_SECONDARY = '#FFFFFF' // White
  static readonly LIGHT_BG_TERTIARY = '#E5E5EA'  // iOS System Gray 5

  // Surfaces
  static readonly LIGHT_SURFACE = '#FFFFFF'
  static readonly LIGHT_SURFACE_VARIANT = '#F2F2F7'

  // Text
  static readonly LIGHT_TEXT_PRIMARY = '#000000'
  static readonly LIGHT_TEXT_SECONDARY = '#8E8E93'   // iOS System Gray
  static readonly LIGHT_TEXT_TERTIARY = '#C7C7CC'    // iOS System Gray 4
  static readonly LIGHT_TEXT_DISABLED = '#C7C7CC'

  // Borders
  static readonly LIGHT_BORDER = '#E5E5EA'
  static readonly LIGHT_BORDER_LIGHT = '#F2F2F7'
  static readonly LIGHT_DIVIDER = '#E5E5EA'

  // ========== Dark Mode Colors (iOS Style) ==========
  // Backgrounds
  static readonly DARK_BG_PRIMARY = '#000000'      // Pure Black
  static readonly DARK_BG_SECONDARY = '#1C1C1E'    // iOS System Gray 2
  static readonly DARK_BG_TERTIARY = '#2C2C2E'     // iOS System Gray 3

  // Surfaces
  static readonly DARK_SURFACE = '#1C1C1E'
  static readonly DARK_SURFACE_VARIANT = '#2C2C2E'

  // Text
  static readonly DARK_TEXT_PRIMARY = '#FFFFFF'
  static readonly DARK_TEXT_SECONDARY = '#8E8E93'  // iOS System Gray
  static readonly DARK_TEXT_TERTIARY = '#636366'   // iOS System Gray 5
  static readonly DARK_TEXT_DISABLED = '#48484A'

  // Borders
  static readonly DARK_BORDER = '#2C2C2E'
  static readonly DARK_BORDER_LIGHT = '#1C1C1E'
  static readonly DARK_DIVIDER = '#3A3A3C'

  // ========== Message Bubbles ==========
  static readonly USER_BUBBLE = '#007AFF'
  static readonly USER_BUBBLE_TEXT = '#FFFFFF'
  static readonly AI_BUBBLE_LIGHT = '#E5E5EA'
  static readonly AI_BUBBLE_TEXT_LIGHT = '#000000'
  static readonly AI_BUBBLE_DARK = '#1C1C1E'
  static readonly AI_BUBBLE_TEXT_DARK = '#FFFFFF'

  // ========== Status Colors ==========
  static readonly STATUS_ONLINE = '#34C759'
  static readonly STATUS_OFFLINE = '#8E8E93'
  static readonly STATUS_BUSY = '#FF9500'
  static readonly STATUS_ERROR = '#FF3B30'

  // ========== Shadows (Light Mode Only) ==========
  static readonly SHADOW_LIGHT = 'rgba(0, 0, 0, 0.05)'
  static readonly SHADOW_MEDIUM = 'rgba(0, 0, 0, 0.08)'
  static readonly SHADOW_HEAVY = 'rgba(0, 0, 0, 0.12)'

  // ========== Overlays ==========
  static readonly OVERLAY_LIGHT = 'rgba(0, 0, 0, 0.40)'
  static readonly OVERLAY_DARK = 'rgba(0, 0, 0, 0.60)'

  // ========== Helper Methods ==========
  static getThemeColor(isDark: boolean, lightColor: string, darkColor: string): string {
    return isDark ? darkColor : lightColor
  }

  static getBackgroundColor(isDark: boolean): string {
    return isDark ? DesignTokens.DARK_BG_PRIMARY : DesignTokens.LIGHT_BG_PRIMARY
  }

  static getSurfaceColor(isDark: boolean): string {
    return isDark ? DesignTokens.DARK_SURFACE : DesignTokens.LIGHT_SURFACE
  }

  static getTextPrimary(isDark: boolean): string {
    return isDark ? DesignTokens.DARK_TEXT_PRIMARY : DesignTokens.LIGHT_TEXT_PRIMARY
  }

  static getTextSecondary(isDark: boolean): string {
    return isDark ? DesignTokens.DARK_TEXT_SECONDARY : DesignTokens.LIGHT_TEXT_SECONDARY
  }
}

// Export alias for convenience
export const DT = DesignTokens
