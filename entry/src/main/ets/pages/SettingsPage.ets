import { router } from '@kit.ArkUI';
import { DesignTokens as DT, Spacing as SP, Typography as TYP, Animation as ANI } from '../constants';
import { ThemeManager, ThemeMode } from '../manager/ThemeManager';

@Entry
@Component
struct SettingsPage {
  @State private isDark: boolean = false;
  @State private notifications: boolean = true;
  @State private autoRefresh: boolean = true;
  @State private apiUrl: string = 'https://api.openclaw.io';
  @State private refreshInterval: number = 30;

  // Safe area for immersive mode
  @State topSafeArea: number = 37

  aboutToAppear() {
    // 初始化深色模式状态
    const themeManager = ThemeManager.getInstance();
    this.isDark = themeManager.getCurrentMode() === ThemeMode.DARK;
  }

  private async onDarkModeChange(value: boolean): Promise<void> {
    this.isDark = value;
    const themeManager = ThemeManager.getInstance();
    await themeManager.setThemeMode(value ? ThemeMode.DARK : ThemeMode.LIGHT);
  }

  @Builder
  SectionTitle(title: string) {
    Text(title)
      .fontSize(TYP.SIZE_H3)
      .fontWeight(TYP.WEIGHT_MEDIUM)
      .fontColor(DT.getTextPrimary(this.isDark))
      .width('100%')
      .textAlign(TextAlign.Start)
  }

  @Builder
  AppearanceSection() {
    Column({ space: SP.M }) {
      this.SectionTitle('外观')
      Column({ space: SP.M }) {
        Row() {
          Column({ space: SP.XS }) {
            Text('深色模式')
              .fontSize(TYP.SIZE_BODY)
              .fontColor(DT.getTextPrimary(this.isDark))

            Text('使用深色主题')
              .fontSize(TYP.SIZE_SMALL)
              .fontColor(DT.getTextSecondary(this.isDark))
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Toggle({ type: ToggleType.Switch, isOn: this.isDark })
            .selectedColor(DT.BRAND_PRIMARY)
            .onChange((value: boolean) => this.onDarkModeChange(value))
        }
        .width('100%')
        .height(64)
      }
      .width('100%')
      .padding(SP.L)
      .backgroundColor(DT.getSurfaceColor(this.isDark))
      .borderRadius(SP.RADIUS_L)
    }
    .width('100%')
  }

  @Builder
  NotificationsSection() {
    Column({ space: SP.M }) {
      this.SectionTitle('通知')
      Column({ space: SP.M }) {
        Row() {
          Column({ space: SP.XS }) {
            Text('推送通知')
              .fontSize(TYP.SIZE_BODY)
              .fontColor(DT.getTextPrimary(this.isDark))

            Text('接收网关状态变更提醒')
              .fontSize(TYP.SIZE_SMALL)
              .fontColor(DT.getTextSecondary(this.isDark))
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Toggle({ type: ToggleType.Switch, isOn: this.notifications })
            .selectedColor(DT.BRAND_PRIMARY)
            .onChange((value: boolean) => this.notifications = value)
        }
        .width('100%')
        .height(64)
      }
      .width('100%')
      .padding(SP.L)
      .backgroundColor(DT.getSurfaceColor(this.isDark))
      .borderRadius(SP.RADIUS_L)
    }
    .width('100%')
  }

  @Builder
  DataSection() {
    Column({ space: SP.M }) {
      this.SectionTitle('数据')
      Column({ space: SP.M }) {
        Row() {
          Column({ space: SP.XS }) {
            Text('自动刷新')
              .fontSize(TYP.SIZE_BODY)
              .fontColor(DT.getTextPrimary(this.isDark))

            Text('自动刷新数据')
              .fontSize(TYP.SIZE_SMALL)
              .fontColor(DT.getTextSecondary(this.isDark))
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Toggle({ type: ToggleType.Switch, isOn: this.autoRefresh })
            .selectedColor(DT.BRAND_PRIMARY)
            .onChange((value: boolean) => this.autoRefresh = value)
        }
        .width('100%')
        .height(64)

        Divider()
          .color(DT.getBorderColor(this.isDark))
          .margin({ top: SP.M, bottom: SP.M })

        Column({ space: SP.S }) {
          Text('API 地址')
            .fontSize(TYP.SIZE_BODY)
            .fontColor(DT.getTextPrimary(this.isDark))
            .width('100%')

          TextInput({ placeholder: '输入 API 地址', text: this.apiUrl })
            .width('100%')
            .height(44)
            .placeholderColor(DT.getTextSecondary(this.isDark))
            .fontSize(TYP.SIZE_BODY)
            .backgroundColor(DT.LIGHT_BG_PRIMARY)
            .fontColor(DT.getTextPrimary(this.isDark))
            .borderRadius(SP.RADIUS_M)
            .onChange((value: string) => this.apiUrl = value)
        }
        .width('100%')
        .margin({ top: SP.S, bottom: SP.S })
      }
      .width('100%')
      .padding(SP.L)
      .backgroundColor(DT.getSurfaceColor(this.isDark))
      .borderRadius(SP.RADIUS_L)
    }
    .width('100%')
  }

  @Builder
  ActionsSection() {
    Column({ space: SP.M }) {
      this.SectionTitle('操作')
      Column({ space: SP.M }) {
        Button('清除缓存')
          .width('100%')
          .height(44)
          .backgroundColor(DT.WARNING)
          .fontColor('#FFFFFF')
          .fontSize(TYP.SIZE_BODY)
          .fontWeight(TYP.WEIGHT_MEDIUM)
          .borderRadius(SP.RADIUS_M)
          .onClick(() => {
            // Clear cache action
          })

        Button('恢复默认设置')
          .width('100%')
          .height(44)
          .backgroundColor(DT.getTextSecondary(this.isDark))
          .fontColor('#FFFFFF')
          .fontSize(TYP.SIZE_BODY)
          .fontWeight(TYP.WEIGHT_MEDIUM)
          .borderRadius(SP.RADIUS_M)
          .onClick(() => {
            this.isDark = false;
            this.notifications = true;
            this.autoRefresh = true;
            this.apiUrl = 'https://api.openclaw.io';
            ThemeManager.getInstance().setThemeMode(ThemeMode.LIGHT);
          })

        Button('退出登录')
          .width('100%')
          .height(44)
          .backgroundColor(DT.ERROR)
          .fontColor('#FFFFFF')
          .fontSize(TYP.SIZE_BODY)
          .fontWeight(TYP.WEIGHT_MEDIUM)
          .borderRadius(SP.RADIUS_M)
          .onClick(() => {
            // Sign out action
          })
      }
      .width('100%')
      .padding(SP.L)
      .backgroundColor(DT.getSurfaceColor(this.isDark))
      .borderRadius(SP.RADIUS_L)
    }
    .width('100%')
  }

  @Builder
  AboutSection() {
    Column({ space: SP.M }) {
      this.SectionTitle('关于')
      Column({ space: SP.M }) {
        // 关于应用入口行
        Row() {
          Column({ space: SP.XS }) {
            Text('关于应用')
              .fontSize(TYP.SIZE_BODY)
              .fontColor(DT.getTextPrimary(this.isDark))

            Text('Harmony Claw v1.0.0')
              .fontSize(TYP.SIZE_SMALL)
              .fontColor(DT.getTextSecondary(this.isDark))
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text('›')
            .fontSize(20)
            .fontColor(DT.getTextSecondary(this.isDark))
        }
        .width('100%')
        .height(64)
        .scale({ x: 1, y: 1 })
        .animation(ANI.pressFeedbackFine())
        .onClick(() => {
          router.pushUrl({ url: 'pages/AboutPage' }).catch((err: Error) => {
            console.error(`[SettingsPage] Failed to navigate: ${JSON.stringify(err)}`);
          });
        })
      }
      .width('100%')
      .padding(SP.L)
      .backgroundColor(DT.getSurfaceColor(this.isDark))
      .borderRadius(SP.RADIUS_L)
    }
    .width('100%')
  }

  build() {
    Column({ space: 0 }) {
      // 顶部安全区域占位
      Column()
        .width('100%')
        .height(this.topSafeArea)
        .backgroundColor(DT.getBackgroundColor(this.isDark))

      // Header - 统一风格
      Row() {
        Button() {
          Text('‹')
            .fontSize(28)
            .fontWeight(TYP.WEIGHT_MEDIUM)
            .fontColor(DT.getTextPrimary(this.isDark))
        }
        .width(44)
        .height(44)
        .backgroundColor('transparent')
        .scale({ x: 1, y: 1 })
        .animation(ANI.pressFeedbackFine())
        .onClick(() => {
          router.back();
        })

        Text('设置')
          .fontSize(TYP.SIZE_H2)
          .fontWeight(TYP.WEIGHT_MEDIUM)
          .fontColor(DT.getTextPrimary(this.isDark))

        Blank()
          .width(44)
      }
      .width('100%')
      .height(56)
      .padding({ left: SP.S, right: SP.M })
      .backgroundColor(DT.getBackgroundColor(this.isDark))

      Scroll() {
        Column({ space: SP.L }) {
          // 外观设置
          this.AppearanceSection()

          // 通知设置
          this.NotificationsSection()

          // 数据设置
          this.DataSection()

          // 操作
          this.ActionsSection()

          // 关于
          this.AboutSection()
        }
        .width('100%')
        .padding(SP.L)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DT.getBackgroundColor(this.isDark))
  }

  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 200, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
  }
}
