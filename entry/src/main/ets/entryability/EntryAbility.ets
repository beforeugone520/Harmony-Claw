import { AbilityConstant, UIAbility, Want, Configuration, ConfigurationConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { themeManager } from '../manager/ThemeManager';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onCreate');
    // 初始化主题管理器
    themeManager.initialize().catch((e: Error) => {
      hilog.error(0x0000, TAG, 'Failed to initialize theme manager: %{public}s', JSON.stringify(e));
    });
  }

  onDestroy(): void {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onBackground');
  }

  /**
   * 系统配置更新回调
   * 当系统主题切换时触发
   */
  onConfigurationUpdate(config: Configuration): void {
    const isDark = config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    hilog.info(0x0000, TAG, 'Configuration updated, isDark: %{public}s', String(isDark));

    // 通知UI层主题已变化
    AppStorage.setOrCreate('isSystemDarkMode', isDark);
    AppStorage.setOrCreate('configUpdateTime', Date.now());
  }
}
