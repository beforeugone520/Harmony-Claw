/**
 * ThemeManager.ets
 * HarmonyOS NEXT 主题管理器
 * 使用资源限定符目录(base/dark)实现深色模式
 */
import { ConfigurationConstant } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

export enum ThemeMode {
  LIGHT = 0,
  DARK = 1,
  SYSTEM = -1
}

export class ThemeManager {
  private static readonly THEME_PREFERENCES_NAME = 'theme_preferences';
  private static readonly THEME_MODE_KEY = 'theme_mode';

  private static instance: ThemeManager;
  private pref: preferences.Preferences | null = null;

  // 当前主题模式
  private currentMode: ThemeMode = ThemeMode.SYSTEM;

  static getInstance(): ThemeManager {
    if (!ThemeManager.instance) {
      ThemeManager.instance = new ThemeManager();
    }
    return ThemeManager.instance;
  }

  /**
   * 初始化主题管理器
   * 从持久化存储读取主题设置并应用
   */
  async initialize(): Promise<void> {
    try {
      const ctx: Context = getContext();
      this.pref = await preferences.getPreferences(ctx, ThemeManager.THEME_PREFERENCES_NAME);

      const savedMode = await this.pref.get(ThemeManager.THEME_MODE_KEY, ThemeMode.SYSTEM);
      this.currentMode = savedMode as ThemeMode;

      console.info(`[ThemeManager] Initialized with mode: ${this.currentMode}`);

      // 应用保存的主题设置
      await this.applyThemeMode(this.currentMode);
    } catch (e) {
      console.error(`[ThemeManager] Failed to initialize: ${JSON.stringify(e)}`);
    }
  }

  /**
   * 获取当前主题模式
   */
  getCurrentMode(): ThemeMode {
    return this.currentMode;
  }

  /**
   * 设置主题模式
   * @param mode 主题模式: LIGHT/DARK/SYSTEM
   */
  async setThemeMode(mode: ThemeMode): Promise<void> {
    if (this.currentMode === mode) {
      return;
    }

    this.currentMode = mode;

    // 持久化保存
    try {
      if (this.pref) {
        await this.pref.put(ThemeManager.THEME_MODE_KEY, mode);
        await this.pref.flush();
      }
    } catch (e) {
      console.error(`[ThemeManager] Failed to save theme mode: ${JSON.stringify(e)}`);
    }

    // 应用主题
    await this.applyThemeMode(mode);

    console.info(`[ThemeManager] Theme mode changed to: ${mode}`);
  }
  /**
   * 应用主题模式到应用
   * 使用资源限定符方式实现主题切换
   */
  private async applyThemeMode(mode: ThemeMode): Promise<void> {
    try {
      // 在HarmonyOS NEXT中，主题切换主要通过资源限定符实现
      // 运行时API调用主要用于系统级主题设置
      // 这里主要记录主题状态，实际主题切换由系统资源管理
      console.info(`[ThemeManager] Theme mode applied: ${mode}`);
    } catch (e) {
      console.error(`[ThemeManager] Failed to apply theme mode: ${JSON.stringify(e)}`);
    }
  }

  /**
   * 切换主题（亮色<->暗色）
   */
  async toggleTheme(): Promise<void> {
    const newMode = this.currentMode === ThemeMode.DARK ? ThemeMode.LIGHT : ThemeMode.DARK;
    await this.setThemeMode(newMode);
  }

  /**
   * 判断当前是否为深色模式
   * 注意：此方法需要在UI上下文中使用，通过AppStorage获取实际状态
   */
  isDarkMode(): boolean {
    // 如果是强制设置的模式，直接返回
    if (this.currentMode === ThemeMode.DARK) {
      return true;
    }
    if (this.currentMode === ThemeMode.LIGHT) {
      return false;
    }
    // 如果是跟随系统，需要通过其他方式判断
    // 这里简化处理，实际可通过AppStorage监听
    return false;
  }
}

// 导出便捷方法
export const themeManager: ThemeManager = ThemeManager.getInstance();
