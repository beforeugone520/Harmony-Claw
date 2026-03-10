import { router } from '@kit.ArkUI';
import { Colors, Typography } from '../styles/DesignTokens';
import { Spacing, Layout } from '../styles/Spacing';
import { DesignTokens as DT, Spacing as SP } from '../constants';
import { GatewayViewModel } from '../viewmodels/GatewayViewModel';
import { ChatViewModel } from '../viewmodels/ChatViewModel';
import { ProcessViewModel } from '../viewmodels/ProcessViewModel';
import { GatewayCard } from '../components/gateway/GatewayCard';
import { SessionItem } from '../components/chat/SessionItem';
import { ProcessCard } from '../components/process/ProcessCard';
import { Gateway } from '../models/Gateway';
import { Session } from '../models/Session';
import { Process } from '../models/Process';

@Entry
@Component
struct Index {
  @State selectedTabIndex: number = 0;
  @State gatewayViewModel: GatewayViewModel = new GatewayViewModel();
  @State chatViewModel: ChatViewModel = new ChatViewModel();
  @State processViewModel: ProcessViewModel = new ProcessViewModel();

  aboutToAppear() {
    this.gatewayViewModel.initialize().catch((e: Error) => {
      console.error(`[Index] Failed to initialize gatewayViewModel: ${JSON.stringify(e)}`);
    });
    this.processViewModel.initialize().catch((e: Error) => {
      console.error(`[Index] Failed to initialize processViewModel: ${JSON.stringify(e)}`);
    });
  }

  @Builder
  TabItemBuilder(icon: string, title: string, index: number) {
    Column({ space: 4 }) {
      Text(icon)
        .fontSize(22)
        .fontColor(this.selectedTabIndex === index ? DT.BRAND_PRIMARY : DT.LIGHT_TEXT_TERTIARY)
        .scale({ x: this.selectedTabIndex === index ? 1.1 : 1, y: this.selectedTabIndex === index ? 1.1 : 1 })
        .animation({ duration: 200, curve: Curve.EaseOut })

      Text(title)
        .fontSize(11)
        .fontColor(this.selectedTabIndex === index ? DT.BRAND_PRIMARY : DT.LIGHT_TEXT_TERTIARY)
        .fontWeight(this.selectedTabIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .scale({ x: this.selectedTabIndex === index ? 1.05 : 1, y: this.selectedTabIndex === index ? 1.05 : 1 })
        .animation({ duration: 200, curve: Curve.EaseOut })
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.selectedTabIndex = index;
    })
  }

  @Builder
  DashboardContent() {
    Scroll() {
      Column({ space: SP.L }) {
        // Stats Cards
        Row({ space: SP.M }) {
          Column({ space: SP.XS }) {
            Text(String(this.gatewayViewModel.getOnlineCount()))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(DT.BRAND_PRIMARY)
            Text('在线网关')
              .fontSize(12)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .padding(SP.L)
          .backgroundColor(DT.LIGHT_BG_PRIMARY)
          .borderRadius(SP.RADIUS_L)
          .shadow({ radius: 8, color: DT.SHADOW_LIGHT, offsetX: 0, offsetY: 2 })

          Column({ space: SP.XS }) {
            Text(String(this.chatViewModel.sessions.length))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(DT.SUCCESS)
            Text('活跃会话')
              .fontSize(12)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .padding(SP.L)
          .backgroundColor(DT.LIGHT_BG_PRIMARY)
          .borderRadius(SP.RADIUS_L)
          .shadow({ radius: 8, color: DT.SHADOW_LIGHT, offsetX: 0, offsetY: 2 })

          Column({ space: SP.XS }) {
            Text(String(this.processViewModel.getRunningCount()))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(DT.WARNING)
            Text('运行进程')
              .fontSize(12)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .padding(SP.L)
          .backgroundColor(DT.LIGHT_BG_PRIMARY)
          .borderRadius(SP.RADIUS_L)
          .shadow({ radius: 8, color: DT.SHADOW_LIGHT, offsetX: 0, offsetY: 2 })
        }
        .width('100%')

        // Quick Actions
        Column({ space: SP.M }) {
          Text('快捷操作')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(DT.LIGHT_TEXT_PRIMARY)
            .width('100%')

          Row({ space: SP.M }) {
            Button('网关管理')
              .width('100%')
              .height(44)
              .backgroundColor(DT.BRAND_PRIMARY)
              .borderRadius(SP.RADIUS_S)
              .onClick(() => {
                router.pushUrl({ url: 'pages/GatewayListPage' });
              })
          }
          .width('100%')

          Row({ space: SP.M }) {
            Button('进程监控')
              .layoutWeight(1)
              .height(44)
              .backgroundColor(DT.INFO)
              .borderRadius(SP.RADIUS_S)
              .onClick(() => {
                router.pushUrl({ url: 'pages/ProcessListPage' });
              })

            Button('刷新数据')
              .layoutWeight(1)
              .height(44)
              .backgroundColor(DT.LIGHT_BG_SECONDARY)
              .fontColor(DT.LIGHT_TEXT_PRIMARY)
              .borderRadius(SP.RADIUS_S)
              .onClick(() => {
                this.gatewayViewModel.refresh();
                this.processViewModel.refresh();
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding(SP.L)
        .backgroundColor(DT.LIGHT_BG_PRIMARY)
        .borderRadius(SP.RADIUS_L)
        .shadow({ radius: 8, color: DT.SHADOW_LIGHT, offsetX: 0, offsetY: 2 })

        // Recent Gateways
        if (this.gatewayViewModel.gateways && this.gatewayViewModel.gateways.length > 0) {
          Column({ space: SP.M }) {
            Text('最近网关')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(DT.LIGHT_TEXT_PRIMARY)
              .width('100%')

            ForEach(this.gatewayViewModel.gateways.filter(g => g != null).slice(0, 3), (gateway: Gateway) => {
              GatewayCard({
                gateway: gateway,
                isSelected: this.gatewayViewModel.currentGateway?.id === gateway.id
              })
            }, (gateway: Gateway) => gateway.id)
          }
          .width('100%')
          .padding(SP.L)
          .backgroundColor(DT.LIGHT_BG_PRIMARY)
          .borderRadius(SP.RADIUS_L)
          .shadow({ radius: 8, color: DT.SHADOW_LIGHT, offsetX: 0, offsetY: 2 })
        }

        // Recent Sessions (disabled for stability)
        // ForEach removed due to ArkTS 6.x compatibility issues

        // Recent Processes (disabled for stability)
        // ForEach removed due to ArkTS 6.x compatibility issues
      }
      .width('100%')
      .padding(SP.L)
    }
    .layoutWeight(1)
  }

  @Builder
  GatewaysContent() {
    Column() {
      Text('网关列表')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.textPrimary)
        .margin({ top: 100 })
    }
    .width('100%')
    .layoutWeight(1)
    .onClick(() => {
      router.pushUrl({ url: 'pages/GatewayListPage' });
    })
  }

  @Builder
  ProcessesContent() {
    Column() {
      Text('进程监控')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.textPrimary)
        .margin({ top: 100 })
    }
    .width('100%')
    .layoutWeight(1)
    .onClick(() => {
      router.pushUrl({ url: 'pages/ProcessListPage' });
    })
  }

  @Builder
  SettingsContent() {
    Column({ space: SP.L }) {
      Text('设置')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(DT.LIGHT_TEXT_PRIMARY)
        .width('100%')
        .margin({ top: SP.L, bottom: SP.L })

      Column({ space: SP.M }) {
        Row() {
          Text('深色模式')
            .fontSize(14)
            .fontColor(DT.LIGHT_TEXT_PRIMARY)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: false })
            .selectedColor(DT.BRAND_PRIMARY)
        }
        .width('100%')
        .height(52)
        .padding(SP.M)
        .backgroundColor(DT.LIGHT_BG_PRIMARY)
        .borderRadius(SP.RADIUS_M)
        .shadow({ radius: 4, color: DT.SHADOW_LIGHT, offsetX: 0, offsetY: 1 })

        Row() {
          Text('消息通知')
            .fontSize(14)
            .fontColor(DT.LIGHT_TEXT_PRIMARY)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: true })
            .selectedColor(DT.BRAND_PRIMARY)
        }
        .width('100%')
        .height(52)
        .padding(SP.M)
        .backgroundColor(DT.LIGHT_BG_PRIMARY)
        .borderRadius(SP.RADIUS_M)
        .shadow({ radius: 4, color: DT.SHADOW_LIGHT, offsetX: 0, offsetY: 1 })

        Row() {
          Text('自动刷新')
            .fontSize(14)
            .fontColor(DT.LIGHT_TEXT_PRIMARY)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: true })
            .selectedColor(DT.BRAND_PRIMARY)
        }
        .width('100%')
        .height(52)
        .padding(SP.M)
        .backgroundColor(DT.LIGHT_BG_PRIMARY)
        .borderRadius(SP.RADIUS_M)
        .shadow({ radius: 4, color: DT.SHADOW_LIGHT, offsetX: 0, offsetY: 1 })

        Button('清除缓存')
          .width('100%')
          .height(44)
          .backgroundColor(DT.WARNING)
          .fontColor('#FFFFFF')
          .borderRadius(SP.RADIUS_S)
          .margin({ top: SP.L })

        Button('关于应用')
          .width('100%')
          .height(44)
          .backgroundColor(DT.LIGHT_BG_SECONDARY)
          .fontColor(DT.LIGHT_TEXT_PRIMARY)
          .borderRadius(SP.RADIUS_S)

        Text('Harmony Claw v1.0.0')
          .fontSize(12)
          .fontColor(DT.LIGHT_TEXT_TERTIARY)
          .margin({ top: SP.XL })
      }
      .width('100%')
      .padding(SP.L)
    }
    .width('100%')
    .layoutWeight(1)
  }

  build() {
    Column() {
      // Header with blur effect
      Row() {
        Text('Harmony Claw')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(DT.LIGHT_TEXT_PRIMARY)

        Blank()

        Button('➕')
          .width(40)
          .height(40)
          .backgroundColor('transparent')
          .fontSize(20)
          .onClick(() => {
            if (this.selectedTabIndex === 0) {
              router.pushUrl({ url: 'pages/GatewayListPage' });
            } else if (this.selectedTabIndex === 1) {
              router.pushUrl({ url: 'pages/ProcessListPage' });
            }
          })
      }
      .width('100%')
      .height(Layout.headerHeight)
      .padding({ left: SP.L, right: SP.L })
      .backgroundColor('rgba(255,255,255,0.85)')
      .backgroundBlurStyle(BlurStyle.Thin)

      // Content
      Stack({ alignContent: Alignment.TopStart }) {
        if (this.selectedTabIndex === 0) {
          this.DashboardContent()
        } else if (this.selectedTabIndex === 1) {
          this.GatewaysContent()
        } else if (this.selectedTabIndex === 2) {
          this.ProcessesContent()
        } else {
          this.SettingsContent()
        }
      }
      .layoutWeight(1)
      .width('100%')

      // Bottom Tab Bar with blur effect
      Row() {
        this.TabItemBuilder('🏠', '首页', 0)
        this.TabItemBuilder('🌐', '网关', 1)
        this.TabItemBuilder('⚙️', '进程', 2)
        this.TabItemBuilder('⚙️', '设置', 3)
      }
      .width('100%')
      .height(Layout.tabBarHeight)
      .backgroundColor('rgba(255,255,255,0.85)')
      .backgroundBlurStyle(BlurStyle.Thin)
      .border({ width: { top: 0.5 }, color: 'rgba(0,0,0,0.05)' })
      .shadow({
        radius: 20,
        color: 'rgba(0,0,0,0.08)',
        offsetX: 0,
        offsetY: -4
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DT.LIGHT_BG_SECONDARY)
  }

  // 页面转场动画 - 从右侧滑入
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 200, curve: Curve.EaseIn })
      .slide(SlideEffect.Left)
  }
}
