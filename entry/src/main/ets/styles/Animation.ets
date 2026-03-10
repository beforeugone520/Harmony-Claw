/**
 * Harmony Claw Animation System
 */

// Duration Constants
export class Duration {
  static readonly instant: number = 50;
  static readonly fast: number = 100;
  static readonly quick: number = 150;
  static readonly normal: number = 200;
  static readonly moderate: number = 300;
  static readonly standard: number = 400;
  static readonly slow: number = 500;
}

// Animation Curves
export class Curves {
  static readonly linear: Curve = Curve.Linear;
  static readonly ease: Curve = Curve.Ease;
  static readonly easeIn: Curve = Curve.EaseIn;
  static readonly easeOut: Curve = Curve.EaseOut;
  static readonly easeInOut: Curve = Curve.EaseInOut;
  static readonly fastOutSlowIn: Curve = Curve.FastOutSlowIn;
}

// Transitions
export class Transitions {
  static fade(duration: number = Duration.moderate): TransitionEffect {
    return TransitionEffect.OPACITY.animation({
      duration: duration,
      curve: Curve.EaseOut
    });
  }

  static slide(direction: string = 'right', duration: number = Duration.moderate): TransitionEffect {
    const offsetX = direction === 'right' ? 50 : direction === 'left' ? -50 : 0;
    const offsetY = direction === 'bottom' ? 50 : direction === 'top' ? -50 : 0;
    return TransitionEffect.translate({ x: offsetX, y: offsetY }).animation({
      duration: duration,
      curve: Curve.EaseOut
    });
  }
}

// Animation Configurations
export interface AnimationConfig {
  duration: number;
  curve?: Curve | string;
  delay?: number;
  iterations?: number;
  playMode?: PlayMode;
}

// Standard Animations
export class Animations {
  static readonly buttonPress: AnimationConfig = {
    duration: Duration.quick,
    curve: Curves.easeOut
  };

  static readonly pageTransition: AnimationConfig = {
    duration: Duration.moderate,
    curve: Curves.fastOutSlowIn
  };

  static readonly contentFade: AnimationConfig = {
    duration: Duration.normal,
    curve: Curves.easeOut
  };
}
