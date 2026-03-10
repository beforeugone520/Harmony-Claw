import { router } from '@kit.ArkUI';
import { Colors, Typography } from '../styles/DesignTokens';
import { Spacing, Layout } from '../styles/Spacing';

@Entry
@Component
struct SettingsPage {
  @State private darkMode: boolean = false;
  @State private notifications: boolean = true;
  @State private autoRefresh: boolean = true;
  @State private apiUrl: string = 'https://api.openclaw.io';
  @State private refreshInterval: number = 30;

  @Builder
  AppInfoSection() {
    Column({ space: Spacing.md }) {
      Row({ space: Spacing.md }) {
        Column()
          .width(64)
          .height(64)
          .backgroundColor(Colors.brandPrimary)
          .borderRadius(16)

        Column({ space: Spacing.xs }) {
          Text('Harmony Claw')
            .fontSize(Typography.sizeH3)
            .fontWeight(Typography.weightBold)
            .fontColor(Colors.textPrimary)

          Text('Version 1.0.0')
            .fontSize(Typography.sizeSmall)
            .fontColor(Colors.textSecondary)

          Text('Build 20240309')
            .fontSize(Typography.sizeCaption)
            .fontColor(Colors.textTertiary)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
  }

  @Builder
  AppearanceSection() {
    Row() {
      Column({ space: Spacing.xs }) {
        Text('Dark Mode')
          .fontSize(Typography.sizeBody)
          .fontColor(Colors.textPrimary)

        Text('Use dark theme throughout the app')
          .fontSize(Typography.sizeCaption)
          .fontColor(Colors.textTertiary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
        .selectedColor(Colors.brandPrimary)
        .onChange((value: boolean) => this.darkMode = value)
    }
    .width('100%')
    .height(64)
  }

  @Builder
  NotificationsSection() {
    Row() {
      Column({ space: Spacing.xs }) {
        Text('Push Notifications')
          .fontSize(Typography.sizeBody)
          .fontColor(Colors.textPrimary)

        Text('Receive alerts about gateway status changes')
          .fontSize(Typography.sizeCaption)
          .fontColor(Colors.textTertiary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: this.notifications })
        .selectedColor(Colors.brandPrimary)
        .onChange((value: boolean) => this.notifications = value)
    }
    .width('100%')
    .height(64)
  }

  @Builder
  DataSection() {
    Column({ space: Spacing.md }) {
      Row() {
        Column({ space: Spacing.xs }) {
          Text('Auto Refresh')
            .fontSize(Typography.sizeBody)
            .fontColor(Colors.textPrimary)

          Text('Automatically refresh data')
            .fontSize(Typography.sizeCaption)
            .fontColor(Colors.textTertiary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: this.autoRefresh })
          .selectedColor(Colors.brandPrimary)
          .onChange((value: boolean) => this.autoRefresh = value)
      }
      .width('100%')
      .height(64)

      Divider()
        .color(Colors.borderLight)
        .margin({ top: Spacing.md, bottom: Spacing.md })

      Column({ space: Spacing.sm }) {
        Text('API Base URL')
          .fontSize(Typography.sizeBody)
          .fontColor(Colors.textPrimary)
          .width('100%')

        TextInput({ placeholder: 'Enter API URL', text: this.apiUrl })
          .width('100%')
          .height(44)
          .placeholderColor(Colors.textTertiary)
          .fontSize(Typography.sizeBody)
          .backgroundColor(Colors.backgroundTertiary)
          .borderRadius(8)
          .onChange((value: string) => this.apiUrl = value)
      }
      .width('100%')
      .margin({ top: Spacing.sm, bottom: Spacing.sm })
    }
  }

  @Builder
  ActionsSection() {
    Column({ space: Spacing.md }) {
      Button('Clear Cache')
        .width('100%')
        .height(Layout.buttonHeightMedium)
        .backgroundColor(Colors.warning)
        .fontColor(Colors.textInverse)
        .fontSize(Typography.sizeBody)
        .fontWeight(Typography.weightMedium)
        .borderRadius(8)
        .onClick(() => {
          // Clear cache action
        })

      Button('Reset to Defaults')
        .width('100%')
        .height(Layout.buttonHeightMedium)
        .backgroundColor(Colors.textTertiary)
        .fontColor(Colors.textInverse)
        .fontSize(Typography.sizeBody)
        .fontWeight(Typography.weightMedium)
        .borderRadius(8)
        .onClick(() => {
          this.darkMode = false;
          this.notifications = true;
          this.autoRefresh = true;
          this.apiUrl = 'https://api.openclaw.io';
        })

      Button('Sign Out')
        .width('100%')
        .height(Layout.buttonHeightMedium)
        .backgroundColor(Colors.error)
        .fontColor(Colors.textInverse)
        .fontSize(Typography.sizeBody)
        .fontWeight(Typography.weightMedium)
        .borderRadius(8)
        .onClick(() => {
          // Sign out action
        })
    }
  }

  @Builder
  AboutSection() {
    Column({ space: Spacing.md }) {
      Row() {
        Text('Privacy Policy')
          .fontSize(Typography.sizeBody)
          .fontColor(Colors.textPrimary)

        Blank()

        Image($r('app.media.startIcon'))
          .width(16)
          .height(16)
          .fillColor(Colors.textTertiary)
      }
      .width('100%')
      .height(48)

      Divider()
        .color(Colors.borderLight)

      Row() {
        Text('Terms of Service')
          .fontSize(Typography.sizeBody)
          .fontColor(Colors.textPrimary)

        Blank()

        Image($r('app.media.startIcon'))
          .width(16)
          .height(16)
          .fillColor(Colors.textTertiary)
      }
      .width('100%')
      .height(48)

      Divider()
        .color(Colors.borderLight)

      Row() {
        Text('Open Source Licenses')
          .fontSize(Typography.sizeBody)
          .fontColor(Colors.textPrimary)

        Blank()

        Image($r('app.media.startIcon'))
          .width(16)
          .height(16)
          .fillColor(Colors.textTertiary)
      }
      .width('100%')
      .height(48)
    }
  }

  build() {
    Column({ space: 0 }) {
      // Header
      Row() {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.startIcon'))
            .width(20)
            .height(20)
            .fillColor(Colors.textPrimary)
        }
        .width(36)
        .height(36)
        .backgroundColor(Colors.backgroundTertiary)
        .onClick(() => {
          router.back();
        })

        Text('Settings')
          .fontSize(Typography.sizeH3)
          .fontWeight(Typography.weightBold)
          .fontColor(Colors.textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()
          .width(36)
      }
      .width('100%')
      .height(Layout.headerHeight)
      .padding({ left: Spacing.lg, right: Spacing.lg })
      .backgroundColor(Colors.surfaceCard)

      Scroll() {
        Column({ space: Spacing.lg }) {
          // App Info
          Column({ space: Spacing.md }) {
            Text('Application')
              .fontSize(Typography.sizeH4)
              .fontWeight(Typography.weightMedium)
              .fontColor(Colors.textPrimary)
              .width('100%')
              .textAlign(TextAlign.Start)

            this.AppInfoSection()
          }
          .width('100%')
          .padding(Spacing.lg)
          .backgroundColor(Colors.surfaceCard)
          .borderRadius(12)

          // Appearance
          Column({ space: Spacing.md }) {
            Text('Appearance')
              .fontSize(Typography.sizeH4)
              .fontWeight(Typography.weightMedium)
              .fontColor(Colors.textPrimary)
              .width('100%')
              .textAlign(TextAlign.Start)

            this.AppearanceSection()
          }
          .width('100%')
          .padding(Spacing.lg)
          .backgroundColor(Colors.surfaceCard)
          .borderRadius(12)

          // Notifications
          Column({ space: Spacing.md }) {
            Text('Notifications')
              .fontSize(Typography.sizeH4)
              .fontWeight(Typography.weightMedium)
              .fontColor(Colors.textPrimary)
              .width('100%')
              .textAlign(TextAlign.Start)

            this.NotificationsSection()
          }
          .width('100%')
          .padding(Spacing.lg)
          .backgroundColor(Colors.surfaceCard)
          .borderRadius(12)

          // Data
          Column({ space: Spacing.md }) {
            Text('Data')
              .fontSize(Typography.sizeH4)
              .fontWeight(Typography.weightMedium)
              .fontColor(Colors.textPrimary)
              .width('100%')
              .textAlign(TextAlign.Start)

            this.DataSection()
          }
          .width('100%')
          .padding(Spacing.lg)
          .backgroundColor(Colors.surfaceCard)
          .borderRadius(12)

          // Actions
          Column({ space: Spacing.md }) {
            Text('Actions')
              .fontSize(Typography.sizeH4)
              .fontWeight(Typography.weightMedium)
              .fontColor(Colors.textPrimary)
              .width('100%')
              .textAlign(TextAlign.Start)

            this.ActionsSection()
          }
          .width('100%')
          .padding(Spacing.lg)
          .backgroundColor(Colors.surfaceCard)
          .borderRadius(12)

          // About
          Column({ space: Spacing.md }) {
            Text('About')
              .fontSize(Typography.sizeH4)
              .fontWeight(Typography.weightMedium)
              .fontColor(Colors.textPrimary)
              .width('100%')
              .textAlign(TextAlign.Start)

            this.AboutSection()
          }
          .width('100%')
          .padding(Spacing.lg)
          .backgroundColor(Colors.surfaceCard)
          .borderRadius(12)

          // Copyright
          Text('© 2024 OpenClaw. All rights reserved.')
            .fontSize(Typography.sizeCaption)
            .fontColor(Colors.textTertiary)
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: Spacing.xl, bottom: Spacing.xl })
        }
        .width('100%')
        .padding(Spacing.lg)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.backgroundPrimary)
  }
