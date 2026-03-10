/**
 * Typography.ets
 * HarmonyOS 6 字体规范 - 鸿蒙黑体体系
 */

export class Typography {
  // ========== 字体族 ==========
  static readonly FONT_FAMILY_NORMAL = 'HarmonyOS Sans'
  static readonly FONT_FAMILY_MEDIUM = 'HarmonyOS Sans Medium'
  static readonly FONT_FAMILY_BOLD = 'HarmonyOS Sans Bold'

  // ========== 字号层级 ==========
  // 大标题 - 导航栏标题
  static readonly SIZE_H1 = 24
  // 标题 - 页面标题
  static readonly SIZE_H2 = 20
  // 小标题 - 卡片标题
  static readonly SIZE_H3 = 17
  // 正文 - 主要文字
  static readonly SIZE_BODY = 16
  // 辅助文字 - 次要信息
  static readonly SIZE_CAPTION = 14
  // 小字 - 标签、时间
  static readonly SIZE_SMALL = 12
  // 超小字 - 角标
  static readonly SIZE_XSMALL = 10

  // ========== 字重 ==========
  static readonly WEIGHT_NORMAL = FontWeight.Normal  // 400
  static readonly WEIGHT_MEDIUM = FontWeight.Medium  // 500
  static readonly WEIGHT_BOLD = FontWeight.Bold      // 700

  // ========== 行高 ==========
  static readonly LINE_HEIGHT_TIGHT = 1.2   // 紧凑（标题）
  static readonly LINE_HEIGHT_NORMAL = 1.5  // 标准（正文）
  static readonly LINE_HEIGHT_LOOSE = 1.8   // 宽松（多行文本）

  // ========== 预定义样式 ==========
  // 导航标题
  static navTitle(): TextStyle {
    return {
      fontSize: Typography.SIZE_H1,
      fontWeight: Typography.WEIGHT_BOLD,
      fontFamily: Typography.FONT_FAMILY_BOLD
    }
  }

  // 页面标题
  static pageTitle(): TextStyle {
    return {
      fontSize: Typography.SIZE_H2,
      fontWeight: Typography.WEIGHT_BOLD,
      fontFamily: Typography.FONT_FAMILY_BOLD
    }
  }

  // 卡片标题
  static cardTitle(): TextStyle {
    return {
      fontSize: Typography.SIZE_H3,
      fontWeight: Typography.WEIGHT_MEDIUM,
      fontFamily: Typography.FONT_FAMILY_MEDIUM
    }
  }

  // 正文
  static body(): TextStyle {
    return {
      fontSize: Typography.SIZE_BODY,
      fontWeight: Typography.WEIGHT_NORMAL,
      fontFamily: Typography.FONT_FAMILY_NORMAL
    }
  }

  // 辅助文字
  static caption(): TextStyle {
    return {
      fontSize: Typography.SIZE_CAPTION,
      fontWeight: Typography.WEIGHT_NORMAL,
      fontFamily: Typography.FONT_FAMILY_NORMAL
    }
  }

  // 小字
  static small(): TextStyle {
    return {
      fontSize: Typography.SIZE_SMALL,
      fontWeight: Typography.WEIGHT_NORMAL,
      fontFamily: Typography.FONT_FAMILY_NORMAL
    }
  }

  // 按钮文字
  static button(): TextStyle {
    return {
      fontSize: Typography.SIZE_BODY,
      fontWeight: Typography.WEIGHT_MEDIUM,
      fontFamily: Typography.FONT_FAMILY_MEDIUM
    }
  }

  // 小按钮文字
  static buttonSmall(): TextStyle {
    return {
      fontSize: Typography.SIZE_CAPTION,
      fontWeight: Typography.WEIGHT_MEDIUM,
      fontFamily: Typography.FONT_FAMILY_MEDIUM
    }
  }
}

// 导出别名方便使用
export const TYP = Typography

// 文本样式接口
interface TextStyle {
  fontSize: number
  fontWeight: FontWeight
  fontFamily: string
}
