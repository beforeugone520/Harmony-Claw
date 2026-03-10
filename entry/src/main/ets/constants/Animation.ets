/**
 * Animation.ets
 * HarmonyOS 6 动效规范
 */

export class Animation {
  // ========== 时长 ==========
  static readonly DURATION_INSTANT = 100
  static readonly DURATION_FAST = 150
  static readonly DURATION_NORMAL = 250
  static readonly DURATION_MEDIUM = 300
  static readonly DURATION_SLOW = 400
  static readonly DURATION_EMPHASIS = 500

  // ========== 缓动曲线 ==========
  static readonly EASE_LINEAR = Curve.Linear
  static readonly EASE_OUT = Curve.EaseOut
  static readonly EASE_IN = Curve.EaseIn
  static readonly EASE_IN_OUT = Curve.EaseInOut

  // ========== 页面转场动画 ==========
  static pageEnter(duration: number = 300): PageTransitionOptions {
    return {
      duration: duration,
      curve: Curve.EaseOut
    }
  }

  static pageExit(duration: number = 250): PageTransitionOptions {
    return {
      duration: duration,
      curve: Curve.EaseIn
    }
  }

  // ========== 通用动画配置 ==========
  static fadeIn(duration: number = 250): AnimateParam {
    return {
      duration: duration,
      curve: Curve.EaseOut
    }
  }

  static slideUp(duration: number = 300): AnimateParam {
    return {
      duration: duration,
      curve: Curve.EaseOut
    }
  }

  static scale(duration: number = 250): AnimateParam {
    return {
      duration: duration,
      curve: Curve.EaseOut
    }
  }

  static pressFeedback(): AnimateParam {
    return {
      duration: Animation.DURATION_FAST,
      curve: Curve.EaseOut
    }
  }
}

// 导出别名方便使用
export const ANI = Animation

// 类型定义
interface PageTransitionOptions {
  duration: number
  curve: Curve
}

interface AnimateParam {
  duration: number
  curve: Curve
}
