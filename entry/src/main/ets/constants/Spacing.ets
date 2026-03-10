/**
 * Spacing.ets
 * HarmonyOS 6 间距系统 - 8px 基准网格
 */

export class Spacing {
  // ========== 基础间距 ==========
  static readonly ZERO = 0
  static readonly XS = 4    // 超小间距
  static readonly S = 8     // 小间距
  static readonly M = 12    // 中间距
  static readonly L = 16    // 大间距
  static readonly XL = 20   // 超大间距
  static readonly XXL = 24  // 2倍大间距
  static readonly XXXL = 32 // 3倍大间距
  static readonly XXXXL = 48// 4倍大间距

  // ========== 页面边距 ==========
  static readonly PAGE_HORIZONTAL = 16     // 页面水平边距
  static readonly PAGE_VERTICAL = 12       // 页面垂直边距
  static readonly PAGE_SAFE_BOTTOM = 32    // 底部安全区域（含导航栏）

  // ========== 组件间距 ==========
  static readonly CARD_PADDING = 16        // 卡片内边距
  static readonly CARD_GAP = 12            // 卡片间距
  static readonly LIST_ITEM_HEIGHT = 56    // 列表项高度
  static readonly LIST_ITEM_GAP = 0        // 列表项间距
  static readonly BUTTON_HEIGHT = 40       // 标准按钮高度
  static readonly BUTTON_HEIGHT_SMALL = 32 // 小按钮高度
  static readonly INPUT_HEIGHT = 44        // 输入框高度
  static readonly TAB_HEIGHT = 56          // Tab栏高度
  static readonly NAV_BAR_HEIGHT = 56      // 导航栏高度

  // ========== 圆角 ==========
  static readonly RADIUS_NONE = 0
  static readonly RADIUS_XS = 4     // 小标签
  static readonly RADIUS_S = 8      // 按钮、小卡片
  static readonly RADIUS_M = 12     // 输入框、中等卡片
  static readonly RADIUS_L = 16     // 大卡片
  static readonly RADIUS_XL = 20    // 底部面板
  static readonly RADIUS_XXL = 24   // 全屏模态
  static readonly RADIUS_FULL = 999 // 全圆角（胶囊）

  // ========== 分割线 ==========
  static readonly DIVIDER_HEIGHT = 0.5
  static readonly DIVIDER_HEIGHT_THICK = 1
}

// 导出别名方便使用
export const SP = Spacing
