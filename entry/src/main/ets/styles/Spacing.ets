/**
 * Harmony Claw Spacing System
 * Consistent spacing scale for layouts and components
 */

export class Spacing {
  // Base unit (4px)
  static readonly unit: number = 4;
  
  // Scale values
  static readonly zero: number = 0;
  static readonly xs: number = Spacing.unit;           // 4px
  static readonly sm: number = Spacing.unit * 2;       // 8px
  static readonly md: number = Spacing.unit * 3;       // 12px
  static readonly lg: number = Spacing.unit * 4;       // 16px
  static readonly xl: number = Spacing.unit * 6;       // 24px
  static readonly xxl: number = Spacing.unit * 8;      // 32px
  static readonly xxxl: number = Spacing.unit * 12;    // 48px
  static readonly xxxxl: number = Spacing.unit * 16;   // 64px
  static readonly xxxxxl: number = Spacing.unit * 24;  // 96px
  
  // Numeric values for calculations
  static readonly v4: number = 4;
  static readonly v8: number = 8;
  static readonly v12: number = 12;
  static readonly v16: number = 16;
  static readonly v20: number = 20;
  static readonly v24: number = 24;
  static readonly v28: number = 28;
  static readonly v32: number = 32;
  static readonly v40: number = 40;
  static readonly v48: number = 48;
  static readonly v56: number = 56;
  static readonly v64: number = 64;
  static readonly v72: number = 72;
  static readonly v80: number = 80;
  static readonly v96: number = 96;
  static readonly v120: number = 120;
}

// ============================================
// Layout Constants
// ============================================

export class Layout {
  // Screen safe areas
  static readonly safeAreaTop: number = 44;
  static readonly safeAreaBottom: number = 34;
  static readonly safeAreaHorizontal: number = Spacing.lg;
  
  // Content max widths
  static readonly contentMaxWidth: number = 1200;
  static readonly contentMaxWidthNarrow: number = 680;
  static readonly contentMaxWidthWide: number = 1440;
  
  // Grid system
  static readonly gridColumns: number = 12;
  static readonly gridGutter: number = Spacing.lg;
  static readonly gridMargin: number = Spacing.xl;
  
  // Component heights
  static readonly buttonHeightSmall: number = 32;
  static readonly buttonHeightMedium: number = 40;
  static readonly buttonHeightLarge: number = 48;
  
  static readonly inputHeightSmall: number = 36;
  static readonly inputHeightMedium: number = 44;
  static readonly inputHeightLarge: number = 52;
  
  static readonly listItemHeightSmall: number = 44;
  static readonly listItemHeightMedium: number = 56;
  static readonly listItemHeightLarge: number = 72;
  
  static readonly headerHeight: number = 56;
  static readonly tabBarHeight: number = 56;
  static readonly bottomBarHeight: number = 64;
  
  // Card dimensions
  static readonly cardPadding: number = Spacing.lg;
  static readonly cardBorderRadius: number = 12;
  static readonly cardMinHeight: number = 100;
  
  // Modal dimensions
  static readonly modalMaxWidth: number = 560;
  static readonly modalPadding: number = Spacing.xl;
  static readonly modalBorderRadius: number = 16;
  
  // Avatar sizes
  static readonly avatarSizeXs: number = 24;
  static readonly avatarSizeSm: number = 32;
  static readonly avatarSizeMd: number = 40;
  static readonly avatarSizeLg: number = 56;
  static readonly avatarSizeXl: number = 80;
  static readonly avatarSizeXxl: number = 120;
  
  // Icon sizes
  static readonly iconSizeXs: number = 12;
  static readonly iconSizeSm: number = 16;
  static readonly iconSizeMd: number = 20;
  static readonly iconSizeLg: number = 24;
  static readonly iconSizeXl: number = 32;
  static readonly iconSizeXxl: number = 48;
}

// ============================================
// EdgeInsets Helpers
// ============================================

export class Insets {
  static all(value: number): Padding {
    return { top: value, right: value, bottom: value, left: value };
  }
  
  static symmetric(horizontal: number, vertical: number): Padding {
    return { top: vertical, right: horizontal, bottom: vertical, left: horizontal };
  }
  
  static only(top: number = 0, right: number = 0, bottom: number = 0, left: number = 0): Padding {
    return { top, right, bottom, left };
  }
  
  // Common presets
  static readonly zero: Padding = Insets.all(0);
  static readonly xs: Padding = Insets.all(Spacing.xs);
  static readonly sm: Padding = Insets.all(Spacing.sm);
  static readonly md: Padding = Insets.all(Spacing.md);
  static readonly lg: Padding = Insets.all(Spacing.lg);
  static readonly xl: Padding = Insets.all(Spacing.xl);
  
  static readonly horizontalSm: Padding = Insets.symmetric(Spacing.sm, 0);
  static readonly horizontalMd: Padding = Insets.symmetric(Spacing.md, 0);
  static readonly horizontalLg: Padding = Insets.symmetric(Spacing.lg, 0);
  static readonly horizontalXl: Padding = Insets.symmetric(Spacing.xl, 0);
  
  static readonly verticalSm: Padding = Insets.symmetric(0, Spacing.sm);
  static readonly verticalMd: Padding = Insets.symmetric(0, Spacing.md);
  static readonly verticalLg: Padding = Insets.symmetric(0, Spacing.lg);
  static readonly verticalXl: Padding = Insets.symmetric(0, Spacing.xl);
  
  static readonly screen: Padding = Insets.only(
    Layout.safeAreaTop,
    Layout.safeAreaHorizontal,
    Layout.safeAreaBottom,
    Layout.safeAreaHorizontal
  );
}

// ============================================
// Gap Helpers
// ============================================

export class Gap {
  static readonly xs: Length = Spacing.xs;
  static readonly sm: Length = Spacing.sm;
  static readonly md: Length = Spacing.md;
  static readonly lg: Length = Spacing.lg;
  static readonly xl: Length = Spacing.xl;
  static readonly xxl: Length = Spacing.xxl;
}
