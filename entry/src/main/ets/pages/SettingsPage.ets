import { router } from '@kit.ArkUI';
import { Spacing as SP } from '../constants';
import { ThemeManager, ThemeMode } from '../manager/ThemeManager';

@Entry
@Component
struct SettingsPage {
  @State private darkMode: boolean = false;
  @State private notifications: boolean = true;
  @State private autoRefresh: boolean = true;
  @State private apiUrl: string = 'https://api.openclaw.io';
  @State private refreshInterval: number = 30;

  aboutToAppear() {
    // 初始化深色模式开关状态
    const themeManager = ThemeManager.getInstance();
    this.darkMode = themeManager.getCurrentMode() === ThemeMode.DARK;
  }

  private async onDarkModeChange(value: boolean): Promise<void> {
    this.darkMode = value;
    const themeManager = ThemeManager.getInstance();
    await themeManager.setThemeMode(value ? ThemeMode.DARK : ThemeMode.LIGHT);
  }

  @Builder
  AppInfoSection() {
    Column({ space: SP.M }) {
      Row({ space: SP.M }) {
        Column()
          .width(64)
          .height(64)
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(16)

        Column({ space: SP.XS }) {
          Text('Harmony Claw')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text('Version 1.0.0')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))

          Text('Build 20240309')
            .fontSize(10)
            .fontColor($r('app.color.text_tertiary'))
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
  }

  @Builder
  AppearanceSection() {
    Row() {
      Column({ space: SP.XS }) {
        Text('Dark Mode')
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))

        Text('Use dark theme throughout the app')
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
        .selectedColor($r('app.color.brand_primary'))
        .onChange((value: boolean) => this.onDarkModeChange(value))
    }
    .width('100%')
    .height(64)
  }

  @Builder
  NotificationsSection() {
    Row() {
      Column({ space: SP.XS }) {
        Text('Push Notifications')
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))

        Text('Receive alerts about gateway status changes')
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: this.notifications })
        .selectedColor($r('app.color.brand_primary'))
        .onChange((value: boolean) => this.notifications = value)
    }
    .width('100%')
    .height(64)
  }

  @Builder
  DataSection() {
    Column({ space: SP.M }) {
      Row() {
        Column({ space: SP.XS }) {
          Text('Auto Refresh')
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))

          Text('Automatically refresh data')
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: this.autoRefresh })
          .selectedColor($r('app.color.brand_primary'))
          .onChange((value: boolean) => this.autoRefresh = value)
      }
      .width('100%')
      .height(64)

      Divider()
        .color($r('app.color.border_light'))
        .margin({ top: SP.M, bottom: SP.M })

      Column({ space: SP.S }) {
        Text('API Base URL')
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))
          .width('100%')

        TextInput({ placeholder: 'Enter API URL', text: this.apiUrl })
          .width('100%')
          .height(44)
          .placeholderColor($r('app.color.text_tertiary'))
          .fontSize(14)
          .backgroundColor($r('app.color.background_tertiary'))
          .borderRadius(8)
          .onChange((value: string) => this.apiUrl = value)
      }
      .width('100%')
      .margin({ top: SP.S, bottom: SP.S })
    }
  }

  @Builder
  ActionsSection() {
    Column({ space: SP.M }) {
      Button('Clear Cache')
        .width('100%')
        .height(44)
        .backgroundColor($r('app.color.warning'))
        .fontColor($r('app.color.text_inverse'))
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .borderRadius(8)
        .onClick(() => {
          // Clear cache action
        })

      Button('Reset to Defaults')
        .width('100%')
        .height(44)
        .backgroundColor($r('app.color.text_tertiary'))
        .fontColor($r('app.color.text_inverse'))
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .borderRadius(8)
        .onClick(() => {
          this.darkMode = false;
          this.notifications = true;
          this.autoRefresh = true;
          this.apiUrl = 'https://api.openclaw.io';
          ThemeManager.getInstance().setThemeMode(ThemeMode.LIGHT);
        })

      Button('Sign Out')
        .width('100%')
        .height(44)
        .backgroundColor($r('app.color.error'))
        .fontColor($r('app.color.text_inverse'))
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .borderRadius(8)
        .onClick(() => {
          // Sign out action
        })
    }
  }

  @Builder
  AboutSection() {
    Column({ space: SP.M }) {
      Row() {
        Text('Privacy Policy')
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))

        Blank()

        Image($r('app.media.startIcon'))
          .width(16)
          .height(16)
          .fillColor($r('app.color.text_tertiary'))
      }
      .width('100%')
      .height(48)

      Divider()
        .color($r('app.color.border_light'))

      Row() {
        Text('Terms of Service')
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))

        Blank()

        Image($r('app.media.startIcon'))
          .width(16)
          .height(16)
          .fillColor($r('app.color.text_tertiary'))
      }
      .width('100%')
      .height(48)

      Divider()
        .color($r('app.color.border_light'))

      Row() {
        Text('Open Source Licenses')
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))

        Blank()

        Image($r('app.media.startIcon'))
          .width(16)
          .height(16)
          .fillColor($r('app.color.text_tertiary'))
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
            .fillColor($r('app.color.text_primary'))
        }
        .width(36)
        .height(36)
        .backgroundColor($r('app.color.background_tertiary'))
        .onClick(() => {
          router.back();
        })

        Text('Settings')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()
          .width(36)
      }
      .width('100%')
      .height(56)
      .padding({ left: SP.L, right: SP.L })
      .backgroundColor($r('app.color.surface_card'))

      Scroll() {
        Column({ space: SP.L }) {
          // App Info
          Column({ space: SP.M }) {
            Text('Application')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .textAlign(TextAlign.Start)

            this.AppInfoSection()
          }
          .width('100%')
          .padding(SP.L)
          .backgroundColor($r('app.color.surface_card'))
          .borderRadius(12)

          // Appearance
          Column({ space: SP.M }) {
            Text('Appearance')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .textAlign(TextAlign.Start)

            this.AppearanceSection()
          }
          .width('100%')
          .padding(SP.L)
          .backgroundColor($r('app.color.surface_card'))
          .borderRadius(12)

          // Notifications
          Column({ space: SP.M }) {
            Text('Notifications')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .textAlign(TextAlign.Start)

            this.NotificationsSection()
          }
          .width('100%')
          .padding(SP.L)
          .backgroundColor($r('app.color.surface_card'))
          .borderRadius(12)

          // Data
          Column({ space: SP.M }) {
            Text('Data')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .textAlign(TextAlign.Start)

            this.DataSection()
          }
          .width('100%')
          .padding(SP.L)
          .backgroundColor($r('app.color.surface_card'))
          .borderRadius(12)

          // Actions
          Column({ space: SP.M }) {
            Text('Actions')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .textAlign(TextAlign.Start)

            this.ActionsSection()
          }
          .width('100%')
          .padding(SP.L)
          .backgroundColor($r('app.color.surface_card'))
          .borderRadius(12)

          // About
          Column({ space: SP.M }) {
            Text('About')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .textAlign(TextAlign.Start)

            this.AboutSection()
          }
          .width('100%')
          .padding(SP.L)
          .backgroundColor($r('app.color.surface_card'))
          .borderRadius(12)

          // Copyright
          Text('© 2024 OpenClaw. All rights reserved.')
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: SP.XL, bottom: SP.XL })
        }
        .width('100%')
        .padding(SP.L)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_primary'))
  }
}
