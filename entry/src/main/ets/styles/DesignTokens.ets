/**
 * Harmony Claw Design Tokens
 * Comprehensive design system for consistent UI/UX
 */

// ============================================
// Color Palette
// ============================================

export class Colors {
  // Brand Colors
  static readonly brandPrimary: ResourceColor = '#007DFF';
  static readonly brandSecondary: ResourceColor = '#00C7BE';
  static readonly brandAccent: ResourceColor = '#FF6B35';
  
  // Brand Gradients
  static readonly brandGradientStart: ResourceColor = '#007DFF';
  static readonly brandGradientEnd: ResourceColor = '#00C7BE';
  
  // Semantic Colors
  static readonly success: ResourceColor = '#34C759';
  static readonly warning: ResourceColor = '#FF9500';
  static readonly error: ResourceColor = '#FF3B30';
  static readonly info: ResourceColor = '#5AC8FA';
  
  // Neutral Colors
  static readonly neutral100: ResourceColor = '#FFFFFF';
  static readonly neutral200: ResourceColor = '#F5F5F5';
  static readonly neutral300: ResourceColor = '#E5E5E5';
  static readonly neutral400: ResourceColor = '#D0D0D0';
  static readonly neutral500: ResourceColor = '#999999';
  static readonly neutral600: ResourceColor = '#666666';
  static readonly neutral700: ResourceColor = '#333333';
  static readonly neutral800: ResourceColor = '#1A1A1A';
  static readonly neutral900: ResourceColor = '#000000';
  
  // Text Colors
  static readonly textPrimary: ResourceColor = Colors.neutral800;
  static readonly textSecondary: ResourceColor = Colors.neutral600;
  static readonly textTertiary: ResourceColor = Colors.neutral500;
  static readonly textInverse: ResourceColor = Colors.neutral100;
  static readonly textDisabled: ResourceColor = Colors.neutral400;
  
  // Background Colors
  static readonly backgroundPrimary: ResourceColor = Colors.neutral200;
  static readonly backgroundSecondary: ResourceColor = Colors.neutral100;
  static readonly backgroundTertiary: ResourceColor = '#F0F0F0';
  
  // Surface Colors
  static readonly surfaceCard: ResourceColor = Colors.neutral100;
  static readonly surfaceElevated: ResourceColor = '#FAFAFA';
  
  // Border Colors
  static readonly borderLight: ResourceColor = Colors.neutral300;
  static readonly borderMedium: ResourceColor = Colors.neutral400;
  static readonly borderDark: ResourceColor = Colors.neutral500;
  
  // Status Colors
  static readonly statusOnline: ResourceColor = Colors.success;
  static readonly statusOffline: ResourceColor = Colors.neutral500;
  static readonly statusError: ResourceColor = Colors.error;
  static readonly statusWarning: ResourceColor = Colors.warning;
  static readonly statusProcessing: ResourceColor = Colors.info;
  
  // Overlay Colors
  static readonly overlayLight: ResourceColor = 'rgba(0, 0, 0, 0.5)';
  static readonly overlayDark: ResourceColor = 'rgba(0, 0, 0, 0.8)';
  static readonly overlayModal: ResourceColor = 'rgba(0, 0, 0, 0.6)';
}

// ============================================
// Typography
// ============================================

export class Typography {
  // Font Families
  static readonly fontPrimary: string = 'HarmonyOS Sans';
  static readonly fontMono: string = 'HarmonyOS Sans Mono';
  
  // Font Sizes
  static readonly sizeDisplay: number = 36;
  static readonly sizeH1: number = 28;
  static readonly sizeH2: number = 24;
  static readonly sizeH3: number = 20;
  static readonly sizeH4: number = 18;
  static readonly sizeBody: number = 16;
  static readonly sizeSmall: number = 14;
  static readonly sizeCaption: number = 12;
  static readonly sizeOverline: number = 10;
  
  // Font Weights
  static readonly weightLight: FontWeight = FontWeight.Lighter;
  static readonly weightRegular: FontWeight = FontWeight.Regular;
  static readonly weightMedium: FontWeight = FontWeight.Medium;
  static readonly weightBold: FontWeight = FontWeight.Bold;
  
  // Line Heights
  static readonly lineHeightTight: number = 1.2;
  static readonly lineHeightNormal: number = 1.5;
  static readonly lineHeightRelaxed: number = 1.75;
  
  // Letter Spacing
  static readonly letterSpacingTight: number = -0.5;
  static readonly letterSpacingNormal: number = 0;
  static readonly letterSpacingWide: number = 0.5;
}

// ============================================
// Shadows
// ============================================

export class Shadows {
  static readonly shadowXs: ShadowOptions = {
    radius: 2,
    color: 'rgba(0, 0, 0, 0.05)',
    offsetX: 0,
    offsetY: 1
  };
  
  static readonly shadowSm: ShadowOptions = {
    radius: 4,
    color: 'rgba(0, 0, 0, 0.08)',
    offsetX: 0,
    offsetY: 2
  };
  
  static readonly shadowMd: ShadowOptions = {
    radius: 8,
    color: 'rgba(0, 0, 0, 0.1)',
    offsetX: 0,
    offsetY: 4
  };
  
  static readonly shadowLg: ShadowOptions = {
    radius: 16,
    color: 'rgba(0, 0, 0, 0.12)',
    offsetX: 0,
    offsetY: 8
  };
  
  static readonly shadowXl: ShadowOptions = {
    radius: 24,
    color: 'rgba(0, 0, 0, 0.15)',
    offsetX: 0,
    offsetY: 12
  };
  
  static readonly shadowInner: ShadowOptions = {
    radius: 4,
    color: 'rgba(0, 0, 0, 0.06)',
    offsetX: 0,
    offsetY: 2
  };
}

// ============================================
// Border Radius
// ============================================

export class BorderRadius {
  static readonly none: number = 0;
  static readonly xs: number = 2;
  static readonly sm: number = 4;
  static readonly md: number = 8;
  static readonly lg: number = 12;
  static readonly xl: number = 16;
  static readonly xxl: number = 24;
  static readonly full: number = 9999;
  static readonly circle: string = '50%';
}

// ============================================
// Z-Index Scale
// ============================================

export class ZIndex {
  static readonly base: number = 0;
  static readonly dropdown: number = 100;
  static readonly sticky: number = 200;
  static readonly fixed: number = 300;
  static readonly modalBackdrop: number = 400;
  static readonly modal: number = 500;
  static readonly popover: number = 600;
  static readonly tooltip: number = 700;
  static readonly toast: number = 800;
}

// ============================================
// Breakpoints
// ============================================

export class Breakpoints {
  static readonly sm: number = 320;
  static readonly md: number = 600;
  static readonly lg: number = 840;
  static readonly xl: number = 1200;
}

// ============================================
// Opacity
// ============================================

export class Opacity {
  static readonly transparent: number = 0;
  static readonly subtle: number = 0.1;
  static readonly light: number = 0.25;
  static readonly medium: number = 0.5;
  static readonly strong: number = 0.75;
  static readonly opaque: number = 1;
  static readonly disabled: number = 0.4;
  static readonly hover: number = 0.8;
  static readonly pressed: number = 0.6;
}
