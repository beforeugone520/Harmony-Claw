/**
 * Animation.ets
 * HarmonyOS 6 动效规范 - 自然流畅的动画曲线
 */

export class Animation {
  // ========== 时长 ==========
  // 即时反馈
  static readonly DURATION_INSTANT = 100
  // 快速过渡（悬停、点击）
  static readonly DURATION_FAST = 150
  // 标准过渡（状态变化）
  static readonly DURATION_NORMAL = 250
  // 中等过渡（页面元素）
  static readonly DURATION_MEDIUM = 300
  // 慢速过渡（页面转场）
  static readonly DURATION_SLOW = 400
  // 强调动画
  static readonly DURATION_EMPHASIS = 500

  // ========== 缓动曲线 ==========
  // 线性
  static readonly EASE_LINEAR = Curve.Linear
  // 减速（退出）
  static readonly EASE_OUT = Curve.EaseOut
  // 加速（进入）
  static readonly EASE_IN = Curve.EaseIn
  // 加减速（对称）
  static readonly EASE_IN_OUT = Curve.EaseInOut

  // 弹性效果 - 轻微
  static readonly SPRING_LIGHT = Curve.Spring({
    mass: 1,
    stiffness: 400,
    damping: 25
  })

  // 弹性效果 - 标准
  static readonly SPRING_NORMAL = Curve.Spring({
    mass: 1,
    stiffness: 300,
    damping: 20
  })

  // 弹性效果 - 明显
  static readonly SPRING_BOUNCY = Curve.Spring({
    mass: 1,
    stiffness: 200,
    damping: 15
  })

  // 插值弹簧 - 用于手势
  static readonly INTERPOLATING = Curve.InterpolatingSpring(0, 1, 300, 20)

  // ========== 转场动画 ==========
  // 页面进入
  static pageEnter(duration: number = 300): PageTransitionOptions {
    return {
      duration: duration,
      curve: Curve.EaseOut
    }
  }

  // 页面退出
  static pageExit(duration: number = 250): PageTransitionOptions {
    return {
      duration: duration,
      curve: Curve.EaseIn
    }
  }

  // ========== 组件动画 ==========
  // 列表项插入
  static listInsert(): TransitionEffect {
    return TransitionEffect.asymmetric(
      TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: 20 })),
      TransitionEffect.OPACITY
    )
  }

  // 卡片展开
  static cardExpand(): TransitionEffect {
    return TransitionEffect.scale({ x: 0.95, y: 0.95 })
      .combine(TransitionEffect.opacity(0.8))
  }

  // 弹出层
  static popup(): TransitionEffect {
    return TransitionEffect.scale({ x: 0.9, y: 0.9 })
      .combine(TransitionEffect.opacity(0))
  }

  // ========== 通用动画配置 ==========
  // 淡入
  static fadeIn(duration: number = 250):AnimateParam {
    return {
      duration: duration,
      curve: Curve.EaseOut
    }
  }

  // 滑入（从底部）
  static slideUp(duration: number = 300): AnimateParam {
    return {
      duration: duration,
      curve: Curve.EaseOut
    }
  }

  // 缩放
  static scale(duration: number = 250): AnimateParam {
    return {
      duration: duration,
      curve: Animation.SPRING_NORMAL
    }
  }

  // 按压反馈
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
  curve: Curve | ICurve
}

interface AnimateParam {
  duration: number
  curve: Curve | ICurve
}
