import { router } from '@kit.ArkUI';
import { Colors, Typography } from '../styles/DesignTokens';
import { Spacing, Layout } from '../styles/Spacing';
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
  TabItemBuilder(title: string, index: number) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(12)
        .fontColor(this.selectedTabIndex === index ? Colors.brandPrimary : Colors.textTertiary)
        .fontWeight(this.selectedTabIndex === index ? FontWeight.Medium : FontWeight.Regular)
        // 选中状态缩放动画
        .scale({ x: this.selectedTabIndex === index ? 1.05 : 1, y: this.selectedTabIndex === index ? 1.05 : 1 })
        .animation({
          duration: 200,
          curve: Curve.EaseOut
        })
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    // 点击反馈动画
    .stateStyles({
      pressed: {
        .backgroundColor('rgba(0,0,0,0.05)')
      }
    })
    .onClick(() => {
      this.selectedTabIndex = index;
    })
  }

  @Builder
  DashboardContent() {
    Scroll() {
      Column({ space: Spacing.lg }) {
        // Stats Cards
        Row({ space: Spacing.md }) {
          Column({ space: Spacing.xs }) {
            Text(String(this.gatewayViewModel.getOnlineCount()))
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.brandPrimary)
            Text('在线网关')
              .fontSize(Typography.sizeSmall)
              .fontColor(Colors.textSecondary)
          }
          .layoutWeight(1)
          .padding(Spacing.lg)
          .backgroundColor(Colors.surfaceCard)
          .borderRadius(12)
          // 点击动画
          .stateStyles({
            pressed: {
              .scale({ x: 0.95, y: 0.95 })
            }
          })
          .animation({
            duration: 100,
            curve: Curve.EaseOut
          })

          Column({ space: Spacing.xs }) {
            Text(String(this.chatViewModel.sessions.length))
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.success)
            Text('活跃会话')
              .fontSize(Typography.sizeSmall)
              .fontColor(Colors.textSecondary)
          }
          .layoutWeight(1)
          .padding(Spacing.lg)
          .backgroundColor(Colors.surfaceCard)
          .borderRadius(12)
          // 点击动画
          .stateStyles({
            pressed: {
              .scale({ x: 0.95, y: 0.95 })
            }
          })
          .animation({
            duration: 100,
            curve: Curve.EaseOut
          })

          Column({ space: Spacing.xs }) {
            Text(String(this.processViewModel.getRunningCount()))
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.warning)
            Text('运行进程')
              .fontSize(Typography.sizeSmall)
              .fontColor(Colors.textSecondary)
          }
          .layoutWeight(1)
          .padding(Spacing.lg)
          .backgroundColor(Colors.surfaceCard)
          .borderRadius(12)
          // 点击动画
          .stateStyles({
            pressed: {
              .scale({ x: 0.95, y: 0.95 })
            }
          })
          .animation({
            duration: 100,
            curve: Curve.EaseOut
          })
        }
        .width('100%')

        // Quick Actions
        Column({ space: Spacing.md }) {
          Text('快捷操作')
            .fontSize(Typography.sizeH4)
            .fontWeight(Typography.weightMedium)
            .fontColor(Colors.textPrimary)
            .width('100%')

          Row({ space: Spacing.md }) {
            Button('网关管理')
              .width('100%')
              .height(48)
              .backgroundColor(Colors.brandPrimary)
              .onClick(() => {
                router.pushUrl({ url: 'pages/GatewayListPage' });
              })
          }
          .width('100%')

          Row({ space: Spacing.md }) {
            Button('进程监控')
              .layoutWeight(1)
              .height(48)
              .backgroundColor(Colors.info)
              .onClick(() => {
                router.pushUrl({ url: 'pages/ProcessListPage' });
              })

            Button('刷新数据')
              .layoutWeight(1)
              .height(48)
              .backgroundColor(Colors.backgroundTertiary)
              .fontColor(Colors.textPrimary)
              .onClick(() => {
                this.gatewayViewModel.refresh();
                this.processViewModel.refresh();
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding(Spacing.lg)
        .backgroundColor(Colors.surfaceCard)
        .borderRadius(12)

        // Recent Gateways
        if (this.gatewayViewModel.gateways && this.gatewayViewModel.gateways.length > 0) {
          Column({ space: Spacing.md }) {
            Text('最近网关')
              .fontSize(Typography.sizeH4)
              .fontWeight(Typography.weightMedium)
              .fontColor(Colors.textPrimary)
              .width('100%')

            ForEach(this.gatewayViewModel.gateways.filter(g => g != null).slice(0, 3), (gateway: Gateway) => {
              GatewayCard({
                gateway: gateway,
                isSelected: this.gatewayViewModel.currentGateway?.id === gateway.id
              })
            }, (gateway: Gateway) => gateway.id)
          }
          .width('100%')
        }

        // Recent Sessions (disabled for stability)
        // ForEach removed due to ArkTS 6.x compatibility issues

        // Recent Processes (disabled for stability)
        // ForEach removed due to ArkTS 6.x compatibility issues
      }
      .width('100%')
      .padding(Spacing.lg)
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
    Column({ space: Spacing.lg }) {
      Text('设置')
        .fontSize(Typography.sizeH3)
        .fontWeight(Typography.weightBold)
        .fontColor(Colors.textPrimary)
        .width('100%')
        .margin({ top: Spacing.lg, bottom: Spacing.lg })

      Column({ space: Spacing.md }) {
        Row() {
          Text('深色模式')
            .fontSize(Typography.sizeBody)
            .fontColor(Colors.textPrimary)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: false })
            .selectedColor(Colors.brandPrimary)
        }
        .width('100%')
        .height(56)
        .padding(Spacing.md)
        .backgroundColor(Colors.surfaceCard)
        .borderRadius(12)

        Row() {
          Text('消息通知')
            .fontSize(Typography.sizeBody)
            .fontColor(Colors.textPrimary)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: true })
            .selectedColor(Colors.brandPrimary)
        }
        .width('100%')
        .height(56)
        .padding(Spacing.md)
        .backgroundColor(Colors.surfaceCard)
        .borderRadius(12)

        Row() {
          Text('自动刷新')
            .fontSize(Typography.sizeBody)
            .fontColor(Colors.textPrimary)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: true })
            .selectedColor(Colors.brandPrimary)
        }
        .width('100%')
        .height(56)
        .padding(Spacing.md)
        .backgroundColor(Colors.surfaceCard)
        .borderRadius(12)

        Button('清除缓存')
          .width('100%')
          .height(48)
          .backgroundColor(Colors.warning)
          .fontColor(Colors.textInverse)
          .margin({ top: Spacing.lg })

        Button('关于应用')
          .width('100%')
          .height(48)
          .backgroundColor(Colors.backgroundTertiary)
          .fontColor(Colors.textPrimary)

        Text('Harmony Claw v1.0.0')
          .fontSize(Typography.sizeCaption)
          .fontColor(Colors.textTertiary)
          .margin({ top: Spacing.xl })
      }
      .width('100%')
      .padding(Spacing.lg)
    }
    .width('100%')
    .layoutWeight(1)
  }

  build() {
    Column() {
      // Header
      Row() {
        Text('Harmony Claw')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.textPrimary)

        Blank()

        Button('+')
          .width(40)
          .height(40)
          .backgroundColor('transparent')
          .fontColor(Colors.brandPrimary)
          .fontSize(24)
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
      .padding({ left: Spacing.lg, right: Spacing.lg })
      .backgroundColor(Colors.backgroundSecondary)

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

      // Bottom Tab Bar
      Row() {
        this.TabItemBuilder('首页', 0)
        this.TabItemBuilder('网关', 1)
        this.TabItemBuilder('进程', 2)
        this.TabItemBuilder('设置', 3)
      }
      .width('100%')
      .height(Layout.tabBarHeight)
      .backgroundColor(Colors.backgroundSecondary)
      .border({ width: { top: 1 }, color: Colors.borderLight })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.backgroundPrimary)
  }

  // 页面转场动画 - 从右侧滑入
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 200, curve: Curve.EaseIn })
      .slide(SlideEffect.Left)
  }
}
