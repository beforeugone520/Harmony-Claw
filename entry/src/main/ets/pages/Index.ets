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

  // 动态模糊状态
  @State headerOpacity: number = 0
  @State headerBlurStyle: BlurStyle = BlurStyle.NONE

  aboutToAppear() {
    this.gatewayViewModel.initialize().catch((e: Error) => {
      console.error(`[Index] Failed to initialize gatewayViewModel: ${JSON.stringify(e)}`);
    });
    this.processViewModel.initialize().catch((e: Error) => {
      console.error(`[Index] Failed to initialize processViewModel: ${JSON.stringify(e)}`);
    });
  }

  // Scroller for dashboard
  private dashboardScroller: Scroller = new Scroller()

  @Builder
  DashboardContent() {
    Scroll(this.dashboardScroller) {
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

        // 底部安全间距
        Column().height(20)
      }
      .width('100%')
      .padding(SP.L)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
    .onWillScroll((xOffset: number, yOffset: number) => {
      // 根据滚动偏移计算标题栏效果
      const currentY = this.dashboardScroller.currentOffset().yOffset
      const threshold = 50
      const maxScroll = 150

      if (currentY <= threshold) {
        this.headerOpacity = 0
        this.headerBlurStyle = BlurStyle.NONE
      } else if (currentY >= maxScroll) {
        this.headerOpacity = 1
        this.headerBlurStyle = BlurStyle.Thin
      } else {
        const progress = (currentY - threshold) / (maxScroll - threshold)
        this.headerOpacity = progress
        this.headerBlurStyle = progress > 0.5 ? BlurStyle.Thin : BlurStyle.NONE
      }
    })
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

  // 获取动态标题栏背景色
  private getHeaderBgColor(): ResourceColor {
    const alpha = Math.floor(this.headerOpacity * 0.85 * 255)
    return `rgba(255,255,255,${alpha / 255})`
  }

  // Tab 切换动画配置
  private tabAnimationDuration: number = 350
  private tabAnimationCurve: Curve = Curve.Spring({
    mass: 1,
    stiffness: 180,
    damping: 16
  })

  // Tab Bar 样式
  @Builder
  TabBarBuilder(icon: string, title: string, index: number) {
    Column({ space: 4 }) {
      Text(icon)
        .fontSize(22)
        .fontColor(this.selectedTabIndex === index ? DT.BRAND_PRIMARY : DT.LIGHT_TEXT_TERTIARY)
        .scale({ x: this.selectedTabIndex === index ? 1.15 : 1, y: this.selectedTabIndex === index ? 1.15 : 1 })
        .animation({
          duration: 250,
          curve: this.tabAnimationCurve
        })

      Text(title)
        .fontSize(11)
        .fontColor(this.selectedTabIndex === index ? DT.BRAND_PRIMARY : DT.LIGHT_TEXT_TERTIARY)
        .fontWeight(this.selectedTabIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .scale({ x: this.selectedTabIndex === index ? 1.05 : 1, y: this.selectedTabIndex === index ? 1.05 : 1 })
        .animation({
          duration: 250,
          curve: this.tabAnimationCurve
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // Tabs 主内容区域
      Tabs({ barPosition: BarPosition.End, index: $$this.selectedTabIndex }) {
        TabContent() {
          this.DashboardContent()
        }
        .tabBar(this.TabBarBuilder('🏠', '首页', 0))

        TabContent() {
          this.GatewaysContent()
        }
        .tabBar(this.TabBarBuilder('🌐', '网关', 1))

        TabContent() {
          this.ProcessesContent()
        }
        .tabBar(this.TabBarBuilder('⚙️', '进程', 2))

        TabContent() {
          this.SettingsContent()
        }
        .tabBar(this.TabBarBuilder('⚙️', '设置', 3))
      }
      .width('100%')
      .height('100%')
      .vertical(false)
      .scrollable(true)
      .animationDuration(this.tabAnimationDuration)
      .animationCurve(this.tabAnimationCurve)
      .barWidth('100%')
      .barHeight(Layout.tabBarHeight)
      .barBackgroundColor('rgba(255,255,255,0.85)')
      .barBackgroundBlurStyle(BlurStyle.Thin)
      .padding({ top: Layout.headerHeight, bottom: Layout.tabBarHeight })
      .backgroundColor(DT.LIGHT_BG_SECONDARY)
      .onChange((index: number) => {
        this.selectedTabIndex = index
      })

      // Header with dynamic blur effect
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
      .backgroundColor(this.getHeaderBgColor())
      .backgroundBlurStyle(this.headerBlurStyle)
      .zIndex(100)
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
