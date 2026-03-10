
import { router } from '@kit.ArkUI';
import { Spacing as SP } from '../constants';
import { GatewayViewModel } from '../viewmodels/GatewayViewModel';
import { ChatViewModel } from '../viewmodels/ChatViewModel';
import { ProcessViewModel } from '../viewmodels/ProcessViewModel';
import { AgentViewModel } from '../viewmodels/AgentViewModel';
import { getOpenClawAPIService } from '../services/OpenClawAPIService';
import { GatewayCard } from '../components/gateway/GatewayCard';
import { ProcessCard } from '../components/process/ProcessCard';
import { AgentCard } from '../components/agent/AgentCard';
import { Gateway, GatewayStatus } from '../models/Gateway';
import { Process } from '../models/Process';
import { Agent } from '../models/Agent';
import { DesignTokens as DT } from '../constants/DesignTokens';

// Interfaces for Builder parameters
interface RingProgressParams {
  icon: Resource
  value: number
  total: number
  label: string
  color: string
  index: number
}

interface StatCardParams {
  icon: Resource
  value: number
  label: string
  color: string
  trend?: string
  index: number
}

interface QuickActionParams {
  title: string
  subtitle: string
  icon: Resource
  gradientColors: string[]
  index: number
  onClick: () => void
}

interface ListItemParams {
  icon: Resource
  iconBgColor: string
  iconColor: string
  title: string
  subtitle: string
  badge?: string
  onClick: () => void
}

interface EmptyStateParams {
  icon: Resource
  title: string
  subtitle: string
  actionText: string
  onAction: () => void
}

interface SettingItemParams {
  icon: Resource
  iconColor: string
  title: string
  showToggle: boolean
  toggleValue?: boolean
  onClick?: () => void
}

@Entry
@Component
struct Index {
  @State selectedTabIndex: number = 0;
  @State gatewayViewModel: GatewayViewModel = new GatewayViewModel();
  @State chatViewModel: ChatViewModel = new ChatViewModel();
  @State processViewModel: ProcessViewModel = new ProcessViewModel();
  @State agentViewModel: AgentViewModel = new AgentViewModel();

  // Dynamic header blur state
  @State headerOpacity: number = 0

  // Animation states for interactions
  @State pressedCardIndex: number = -1
  @State pressedActionIndex: number = -1

  // Tab animation config
  private tabAnimationDuration: number = 300
  private tabAnimationCurve: Curve = Curve.EaseInOut

  aboutToAppear() {
    this.initializeViewModels();
    this.updateThemeColors();
    this.setupThemeListener();
  }

  onPageShow() {
    this.syncGatewayState();
  }

  private async initializeViewModels(): Promise<void> {
    try {
      await this.gatewayViewModel.initialize();
      await this.processViewModel.initialize();

      if (this.gatewayViewModel.currentGateway) {
        await this.agentViewModel.setGateway(this.gatewayViewModel.currentGateway);
      } else {
        await this.agentViewModel.initialize();
      }
    } catch (e) {
      console.error(`[Index] Failed to initialize view models: ${JSON.stringify(e)}`);
    }
  }

  private async syncGatewayState(): Promise<void> {
    try {
      console.log('[Index] Syncing gateway state...');
      const apiService = getOpenClawAPIService();
      const currentGateway = apiService.getCurrentGateway();

      if (currentGateway) {
        console.log(`[Index] API service has gateway: ${currentGateway.name}`);
        if (this.agentViewModel.currentGateway?.id !== currentGateway.id) {
          console.log(`[Index] Syncing gateway to AgentViewModel: ${currentGateway.name}`);
          await this.agentViewModel.setGateway(currentGateway);
        } else {
          console.log('[Index] Gateway already synced, refreshing agents...');
          await this.agentViewModel.refresh();
        }
      } else {
        console.log('[Index] No gateway connected in API service');
        if (this.gatewayViewModel.currentGateway) {
          console.log(`[Index] Using gateway from GatewayViewModel: ${this.gatewayViewModel.currentGateway.name}`);
          await this.agentViewModel.setGateway(this.gatewayViewModel.currentGateway);
        }
      }

      await this.gatewayViewModel.refresh();

      if (this.gatewayViewModel.currentGateway?.status === GatewayStatus.ONLINE) {
        console.log('[Index] Refreshing processes from gateway...');
        await this.processViewModel.refresh();
      }
    } catch (e) {
      console.error(`[Index] Failed to sync gateway state: ${JSON.stringify(e)}`);
    }
  }

  // Dashboard scroller
  private dashboardScroller: Scroller = new Scroller()

  // ========== Helper Methods ==========

  private isDarkMode(): boolean {
    try {
      return AppStorage.get<boolean>('isSystemDarkMode') ?? false
    } catch {
      return false
    }
  }

  private getHeaderBgColor(): ResourceColor {
    if (this.isDarkMode()) {
      return '#000000'
    }
    const alpha = Math.floor(this.headerOpacity * 0.85 * 255)
    return `rgba(255,255,255,${alpha / 255})`
  }

  private getGreeting(): string {
    const hour = new Date().getHours()
    if (hour < 12) return '早上好'
    if (hour < 18) return '下午好'
    return '晚上好'
  }

  private getTodayDate(): string {
    const date = new Date()
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    return `${date.getMonth() + 1}月${date.getDate()}日 ${weekDays[date.getDay()]}`
  }

  // ========== Dashboard Components ==========

  @Builder
  WelcomeHeader() {
    Column({ space: SP.XS }) {
      Text(this.getTodayDate())
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
      Text(this.getGreeting())
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .animation({ duration: 200, curve: Curve.EaseOut })
  }

  @Builder
  RingProgressCard(params: RingProgressParams) {
    let progress = params.total > 0 ? params.value / params.total : 0
    let isPressed = this.pressedCardIndex === params.index

    Column({ space: SP.S }) {
      Stack({ alignContent: Alignment.Center }) {
        // Background ring
        Circle()
          .width(56)
          .height(56)
          .fill('transparent')
          .stroke(this.isDarkMode() ? '#2C2C2E' : '#E5E5EA')
          .strokeWidth(4)

        // Progress arc (simplified without clip)
        Circle()
          .width(56)
          .height(56)
          .fill('transparent')
          .stroke(params.color)
          .strokeWidth(4)
          .strokeLineCap(LineCapStyle.Round)

        // Center icon
        SymbolGlyph(params.icon)
          .fontSize(20)
          .fontColor([params.color])
      }
      .width(56)
      .height(56)

      Text(`${params.value}/${params.total}`)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      Text(params.label)
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))
    }
    .width(88)
    .padding(SP.M)
    .backgroundColor(this.isDarkMode() ? '#1C1C1E' : '#FFFFFF')
    .borderRadius(16)
    .shadow(this.isDarkMode() ? undefined : {
      radius: 8,
      color: 'rgba(0,0,0,0.06)',
      offsetX: 0,
      offsetY: 2
    })
    .scale({ x: isPressed ? 0.95 : 1, y: isPressed ? 0.95 : 1 })
    .animation({ duration: 100, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.pressedCardIndex = params.index
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressedCardIndex = -1
      }
    })
  }

  @Builder
  StatCardV2(params: StatCardParams) {
    let isPressed = this.pressedCardIndex === params.index

    Column({ space: SP.S }) {
      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(48)
          .height(48)
          .fill(params.color + '20') // 20% opacity

        SymbolGlyph(params.icon)
          .fontSize(22)
          .fontColor([params.color])
      }
      .width(48)
      .height(48)

      Row({ space: SP.XS }) {
        Text(String(params.value))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        if (params.trend) {
          Text(params.trend)
            .fontSize(11)
            .fontColor(params.trend.startsWith('+') ? DT.SUCCESS : DT.ERROR)
            .backgroundColor(params.trend.startsWith('+') ? DT.SUCCESS + '15' : DT.ERROR + '15')
            .padding({ left: 4, right: 4, top: 2, bottom: 2 })
            .borderRadius(4)
        }
      }

      Text(params.label)
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))
    }
    .width(88)
    .padding(SP.M)
    .backgroundColor(this.isDarkMode() ? '#1C1C1E' : '#FFFFFF')
    .borderRadius(16)
    .shadow(this.isDarkMode() ? undefined : {
      radius: 8,
      color: 'rgba(0,0,0,0.06)',
      offsetX: 0,
      offsetY: 2
    })
    .scale({ x: isPressed ? 0.95 : 1, y: isPressed ? 0.95 : 1 })
    .animation({ duration: 100, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.pressedCardIndex = params.index
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressedCardIndex = -1
      }
    })
  }

  @Builder
  StatsSection() {
    Column({ space: SP.M }) {
      Row() {
        Text('概览')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Blank()
      }
      .width('100%')
      .padding({ left: SP.XS, right: SP.XS })

      Scroll() {
        Row({ space: SP.M }) {
          // Gateway online rate - ring progress
          this.RingProgressCard({
            icon: $r('sys.symbol.icloud'),
            value: this.gatewayViewModel.getOnlineCount(),
            total: this.gatewayViewModel.getTotalCount() || 1,
            label: '网关在线',
            color: DT.IOS_BLUE,
            index: 0
          })

          // Running processes - stat card
          this.StatCardV2({
            icon: $r('sys.symbol.bolt.fill'),
            value: this.processViewModel.getRunningCount(),
            label: '运行进程',
            color: DT.IOS_ORANGE,
            trend: '+3',
            index: 1
          })

          // Agent online - ring progress
          this.RingProgressCard({
            icon: $r('sys.symbol.cpu.fill'),
            value: this.agentViewModel.getOnlineCount(),
            total: this.agentViewModel.agents.length || 1,
            label: 'Agent在线',
            color: DT.IOS_GREEN,
            index: 2
          })

          // Active sessions - stat card
          this.StatCardV2({
            icon: $r('sys.symbol.bubble.left.fill'),
            value: this.chatViewModel.sessions.length,
            label: '活跃会话',
            color: DT.IOS_INDIGO,
            index: 3
          })
        }
        .padding({ left: SP.L, right: SP.L })
      }
      .scrollBar(BarState.Off)
    }
    .width('100%')
  }

  @Builder
  QuickActionButton(params: QuickActionParams) {
    let isPressed = this.pressedActionIndex === params.index

    Column({ space: SP.XS }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('100%')
          .height('100%')
          .borderRadius(16)
          .backgroundColor(params.gradientColors[0])

        SymbolGlyph(params.icon)
          .fontSize(28)
          .fontColor(['#FFFFFF'])
          .fontWeight(FontWeight.Medium)
      }
      .width(56)
      .height(56)

      Text(params.title)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      Text(params.subtitle)
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .padding(SP.M)
    .backgroundColor(this.isDarkMode() ? '#1C1C1E' : '#FFFFFF')
    .borderRadius(16)
    .shadow(this.isDarkMode() ? undefined : {
      radius: 8,
      color: 'rgba(0,0,0,0.06)',
      offsetX: 0,
      offsetY: 2
    })
    .scale({ x: isPressed ? 0.95 : 1, y: isPressed ? 0.95 : 1 })
    .animation({ duration: 100, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.pressedActionIndex = params.index
      } else if (event.type === TouchType.Up) {
        this.pressedActionIndex = -1
        params.onClick()
      } else if (event.type === TouchType.Cancel) {
        this.pressedActionIndex = -1
      }
    })
  }

  @Builder
  QuickActionsGrid() {
    Column({ space: SP.M }) {
      Row() {
        Text('快捷操作')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Blank()
      }
      .width('100%')
      .padding({ left: SP.XS, right: SP.XS })

      Grid() {
        GridItem() {
          this.QuickActionButton({
            title: '网关管理',
            subtitle: '管理连接',
            icon: $r('sys.symbol.rectangle.connected.to.line.below'),
            gradientColors: [DT.IOS_BLUE, DT.IOS_INDIGO],
            index: 0,
            onClick: () => router.pushUrl({ url: 'pages/GatewayListPage' })
          })
        }

        GridItem() {
          this.QuickActionButton({
            title: '进程监控',
            subtitle: '查看状态',
            icon: $r('sys.symbol.bolt.fill'),
            gradientColors: [DT.IOS_ORANGE, '#FF9F0A'],
            index: 1,
            onClick: () => router.pushUrl({ url: 'pages/ProcessListPage' })
          })
        }

        GridItem() {
          this.QuickActionButton({
            title: '记账热量',
            subtitle: '今日 3 笔',
            icon: $r('sys.symbol.chart.pie.fill'),
            gradientColors: [DT.IOS_GREEN, '#30D158'],
            index: 2,
            onClick: () => router.pushUrl({ url: 'pages/AccountingPage' })
          })
        }

        GridItem() {
          this.QuickActionButton({
            title: '日程管理',
            subtitle: '2 个待办',
            icon: $r('sys.symbol.calendar'),
            gradientColors: [DT.IOS_INDIGO, DT.IOS_PURPLE],
            index: 3,
            onClick: () => router.pushUrl({ url: 'pages/SchedulePage' })
          })
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(SP.M)
      .rowsGap(SP.M)
      .width('100%')
      .height(220)
    }
    .width('100%')
    .padding(SP.L)
    .backgroundColor(this.isDarkMode() ? '#000000' : '#F2F2F7')
    .borderRadius(20)
  }

  @Builder
  AgentDataSection() {
    Column({ space: SP.M }) {
      Row() {
        Text('Agent 数据')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Blank()
      }
      .width('100%')
      .padding({ left: SP.XS, right: SP.XS })

      // Accounting Entry
      this.ListItemCard({
        icon: $r('sys.symbol.chart.pie.fill'),
        iconBgColor: DT.IOS_GREEN + '20',
        iconColor: DT.IOS_GREEN,
        title: '记账热量',
        subtitle: '今日已记录 3 笔消费',
        badge: '650 大卡',
        onClick: () => router.pushUrl({ url: 'pages/AccountingPage' })
      })

      // Schedule Entry
      this.ListItemCard({
        icon: $r('sys.symbol.calendar.badge.clock'),
        iconBgColor: DT.IOS_INDIGO + '20',
        iconColor: DT.IOS_INDIGO,
        title: '日程管理',
        subtitle: '今天有 2 个待办事项',
        badge: '2 待办',
        onClick: () => router.pushUrl({ url: 'pages/SchedulePage' })
      })
    }
    .width('100%')
    .padding(SP.L)
    .backgroundColor(this.isDarkMode() ? '#000000' : '#F2F2F7')
    .borderRadius(20)
  }

  @Builder
  ListItemCard(params: ListItemParams) {
    Row({ space: SP.M }) {
      // Icon
      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(44)
          .height(44)
          .fill(params.iconBgColor)

        SymbolGlyph(params.icon)
          .fontSize(20)
          .fontColor([params.iconColor])
      }
      .width(44)
      .height(44)

      // Content
      Column({ space: SP.XS }) {
        Text(params.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(params.subtitle)
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // Badge + Arrow
      Row({ space: SP.S }) {
        if (params.badge) {
          Text(params.badge)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .backgroundColor(this.isDarkMode() ? '#2C2C2E' : '#E5E5EA')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(12)
        }

        SymbolGlyph($r('sys.symbol.chevron.right'))
          .fontSize(14)
          .fontColor([$r('app.color.text_tertiary')])
      }
    }
    .width('100%')
    .height(64)
    .padding(SP.M)
    .backgroundColor(this.isDarkMode() ? '#1C1C1E' : '#FFFFFF')
    .borderRadius(12)
    .onClick(params.onClick)
  }

  @Builder
  RecentGatewaysSection() {
    Column({ space: SP.M }) {
      Row() {
        Text('最近网关')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Blank()

        Text('查看更多')
          .fontSize(13)
          .fontColor($r('app.color.brand_primary'))
          .onClick(() => {
            this.selectedTabIndex = 1
          })
      }
      .width('100%')
      .padding({ left: SP.XS, right: SP.XS })

      if (this.gatewayViewModel.gateways.length === 0) {
        this.EmptyState({
          icon: $r('sys.symbol.icloud.slash'),
          title: '暂无网关',
          subtitle: '点击添加您的第一个网关',
          actionText: '添加网关',
          onAction: () => router.pushUrl({ url: 'pages/AddGatewayPage' })
        })
      } else {
        ForEach(this.gatewayViewModel.gateways.filter(g => g != null).slice(0, 3), (gateway: Gateway) => {
          GatewayCard({
            gateway: gateway,
            isSelected: this.gatewayViewModel.currentGateway?.id === gateway.id
          })
        }, (gateway: Gateway) => gateway.id)
      }
    }
    .width('100%')
    .padding(SP.L)
    .backgroundColor(this.isDarkMode() ? '#000000' : '#F2F2F7')
    .borderRadius(20)
  }

  @Builder
  EmptyState(params: EmptyStateParams) {
    Column({ space: SP.M }) {
      SymbolGlyph(params.icon)
        .fontSize(48)
        .fontColor([$r('app.color.text_tertiary')])
        .opacity(0.5)

      Text(params.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      Text(params.subtitle)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))

      Button(params.actionText)
        .fontSize(14)
        .fontColor('#FFFFFF')
        .backgroundColor(DT.IOS_BLUE)
        .height(40)
        .padding({ left: SP.L, right: SP.L })
        .borderRadius(20)
        .margin({ top: SP.S })
        .onClick(params.onAction)
    }
    .width('100%')
    .padding(SP.XL)
    .alignItems(HorizontalAlign.Center)
  }

  // ========== Dashboard Content ==========

  @Builder
  DashboardContent() {
    Scroll(this.dashboardScroller) {
      Column({ space: SP.XL }) {
        // Welcome Header
        this.WelcomeHeader()

        // Stats Section
        this.StatsSection()

        // Quick Actions Grid
        this.QuickActionsGrid()

        // Agent Data Section
        this.AgentDataSection()

        // Recent Gateways
        this.RecentGatewaysSection()

        // Bottom safe area
        Column().height(100)
      }
      .width('100%')
      .padding(SP.L)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
    .onWillScroll((xOffset: number, yOffset: number) => {
      const currentY = this.dashboardScroller.currentOffset().yOffset
      const startFade = 0
      const endFade = 100

      if (currentY <= startFade) {
        this.headerOpacity = 0
      } else if (currentY >= endFade) {
        this.headerOpacity = 1
      } else {
        const progress = (currentY - startFade) / (endFade - startFade)
        this.headerOpacity = progress * (2 - progress)
      }
    })
  }

  // ========== Gateways Content ==========

  @Builder
  GatewaysContent() {
    Scroll() {
      Column({ space: SP.L }) {
        // Stats Row
        Row({ space: SP.M }) {
          this.StatCardV2({
            icon: $r('sys.symbol.icloud'),
            value: this.gatewayViewModel.getTotalCount(),
            label: '总网关数',
            color: DT.IOS_BLUE,
            index: 10
          })

          this.StatCardV2({
            icon: $r('sys.symbol.checkmark.circle.fill'),
            value: this.gatewayViewModel.getOnlineCount(),
            label: '在线网关',
            color: DT.IOS_GREEN,
            index: 11
          })

          this.StatCardV2({
            icon: $r('sys.symbol.xmark.circle.fill'),
            value: this.gatewayViewModel.gateways.length - this.gatewayViewModel.getOnlineCount(),
            label: '离线网关',
            color: DT.IOS_ORANGE,
            index: 12
          })
        }
        .width('100%')
        .padding(SP.L)

        // Header
        Row() {
          Text('网关列表')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Blank()

          Button() {
            SymbolGlyph($r('sys.symbol.arrow.clockwise'))
              .fontSize(16)
              .fontColor([$r('app.color.brand_primary')])
          }
          .width(36)
          .height(36)
          .backgroundColor(this.isDarkMode() ? '#1C1C1E' : '#FFFFFF')
          .borderRadius(18)
          .enabled(!this.gatewayViewModel.isLoading)
          .onClick(() => this.gatewayViewModel.refresh())
        }
        .width('100%')
        .padding({ left: SP.L, right: SP.L })

        // List
        if (this.gatewayViewModel.isLoading) {
          this.LoadingState('加载中...')
        } else if (this.gatewayViewModel.gateways.length === 0) {
          this.EmptyState({
            icon: $r('sys.symbol.icloud.slash'),
            title: '暂无网关',
            subtitle: '点击添加网关按钮开始',
            actionText: '添加网关',
            onAction: () => router.pushUrl({ url: 'pages/AddGatewayPage' })
          })
        } else {
          ForEach(this.gatewayViewModel.gateways, (gateway: Gateway) => {
            GatewayCard({
              gateway: gateway,
              isSelected: this.gatewayViewModel.currentGateway?.id === gateway.id,
              onConnect: () => this.gatewayViewModel.connectGateway(gateway),
              onDelete: () => this.gatewayViewModel.deleteGateway(gateway.id)
            })
          }, (gateway: Gateway) => gateway.id)
        }

        Column().height(100)
      }
      .width('100%')
      .padding({ bottom: SP.L })
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  LoadingState(message: string) {
    Column({ space: SP.M }) {
      LoadingProgress()
        .width(40)
        .height(40)
        .color($r('app.color.brand_primary'))

      Text(message)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
    }
    .margin({ top: 50 })
  }

  // ========== Processes Content ==========

  @Builder
  ProcessesContent() {
    Scroll() {
      Column({ space: SP.L }) {
        // Stats
        Row({ space: SP.M }) {
          this.StatCardV2({
            icon: $r('sys.symbol.bolt.fill'),
            value: this.processViewModel.processes.length,
            label: '总进程数',
            color: DT.IOS_BLUE,
            index: 20
          })

          this.StatCardV2({
            icon: $r('sys.symbol.play.fill'),
            value: this.processViewModel.getRunningCount(),
            label: '运行中',
            color: DT.IOS_GREEN,
            index: 21
          })

          this.StatCardV2({
            icon: $r('sys.symbol.memorychip.fill'),
            value: this.processViewModel.getTotalMemoryUsage(),
            label: '内存 MB',
            color: DT.IOS_ORANGE,
            index: 22
          })
        }
        .width('100%')
        .padding(SP.L)

        // Header
        Row() {
          Text('进程列表')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Blank()

          Button() {
            SymbolGlyph($r('sys.symbol.arrow.clockwise'))
              .fontSize(16)
              .fontColor([$r('app.color.brand_primary')])
          }
          .width(36)
          .height(36)
          .backgroundColor(this.isDarkMode() ? '#1C1C1E' : '#FFFFFF')
          .borderRadius(18)
          .enabled(!this.processViewModel.isLoading)
          .onClick(() => this.processViewModel.refresh())
        }
        .width('100%')
        .padding({ left: SP.L, right: SP.L })

        // List
        if (this.processViewModel.isLoading) {
          this.LoadingState('加载中...')
        } else if (this.processViewModel.processes.length === 0) {
          this.EmptyState({
            icon: $r('sys.symbol.bolt.slash.fill'),
            title: '暂无进程',
            subtitle: '连接网关后将显示进程信息',
            actionText: '去连接',
            onAction: () => this.selectedTabIndex = 1
          })
        } else {
          ForEach(this.processViewModel.processes, (process: Process) => {
            ProcessCard({ process: process })
          }, (process: Process) => process.id)
        }

        Column().height(100)
      }
      .width('100%')
      .padding({ bottom: SP.L })
    }
    .width('100%')
    .layoutWeight(1)
  }

  // ========== Agents Content ==========

  @Builder
  AgentsContent() {
    Scroll() {
      Column({ space: SP.L }) {
        // Gateway status banner
        if (!this.agentViewModel.currentGateway) {
          Row() {
            SymbolGlyph($r('sys.symbol.exclamationmark.triangle.fill'))
              .fontSize(16)
              .fontColor([DT.IOS_ORANGE])
              .margin({ right: SP.S })

            Text('请先连接网关以查看 Agents')
              .fontSize(14)
              .fontColor($r('app.color.text_primary'))
          }
          .width('100%')
          .padding(SP.M)
          .backgroundColor(DT.IOS_ORANGE + '15')
          .borderRadius(12)
          .margin({ left: SP.L, right: SP.L, top: SP.L })
          .onClick(() => this.selectedTabIndex = 1)
        } else {
          Row() {
            SymbolGlyph($r('sys.symbol.checkmark.circle.fill'))
              .fontSize(16)
              .fontColor([DT.IOS_GREEN])
              .margin({ right: SP.S })

            Text(`已连接: ${this.agentViewModel.currentGateway.name}`)
              .fontSize(14)
              .fontColor($r('app.color.text_primary'))

            Blank()

            Text(`${this.agentViewModel.currentGateway.host}:${this.agentViewModel.currentGateway.port}`)
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .padding(SP.M)
          .backgroundColor(DT.IOS_GREEN + '10')
          .borderRadius(12)
          .margin({ left: SP.L, right: SP.L, top: SP.L })
        }

        // Stats
        Row({ space: SP.M }) {
          this.StatCardV2({
            icon: $r('sys.symbol.cpu.fill'),
            value: this.agentViewModel.agents.length,
            label: '总Agent数',
            color: DT.IOS_BLUE,
            index: 30
          })

          this.StatCardV2({
            icon: $r('sys.symbol.checkmark.circle.fill'),
            value: this.agentViewModel.getOnlineCount(),
            label: '在线Agent',
            color: DT.IOS_GREEN,
            index: 31
          })

          this.StatCardV2({
            icon: $r('sys.symbol.clock.fill'),
            value: this.agentViewModel.getBusyCount(),
            label: '忙碌Agent',
            color: DT.IOS_ORANGE,
            index: 32
          })
        }
        .width('100%')
        .padding(SP.L)

        // Header
        Row() {
          Text('OpenClaw Agents')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Blank()

          Button() {
            SymbolGlyph($r('sys.symbol.arrow.clockwise'))
              .fontSize(16)
              .fontColor([$r('app.color.brand_primary')])
          }
          .width(36)
          .height(36)
          .backgroundColor(this.isDarkMode() ? '#1C1C1E' : '#FFFFFF')
          .borderRadius(18)
          .enabled(!this.agentViewModel.isLoading && this.agentViewModel.currentGateway !== null)
          .onClick(() => this.agentViewModel.refresh())
        }
        .width('100%')
        .padding({ left: SP.L, right: SP.L })

        // List
        if (this.agentViewModel.isLoading) {
          this.LoadingState('加载中...')
        } else if (this.agentViewModel.agents.length === 0) {
          Column({ space: SP.M }) {
            SymbolGlyph($r('sys.symbol.cpu.fill'))
              .fontSize(48)
              .fontColor([$r('app.color.text_tertiary')])
              .opacity(0.5)

            Text('暂无 Agent')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))

            if (this.agentViewModel.currentGateway) {
              Text(`已连接: ${this.agentViewModel.currentGateway.host}:${this.agentViewModel.currentGateway.port}`)
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
            } else {
              Text('请先连接网关')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
            }

            Button('手动刷新')
              .fontSize(14)
              .fontColor(DT.IOS_BLUE)
              .backgroundColor('transparent')
              .margin({ top: SP.S })
              .onClick(() => this.agentViewModel.refresh())
          }
          .margin({ top: 50 })
          .alignItems(HorizontalAlign.Center)
        } else {
          ForEach(this.agentViewModel.agents, (agent: Agent) => {
            AgentCard({
              agent: agent,
              isSelected: this.agentViewModel.currentAgent?.id === agent.id,
              onItemClick: () => this.agentViewModel.selectAgent(agent),
              onSendMessage: () => {}
            })
          }, (agent: Agent) => agent.id)
        }

        // Agent Data Quick Access
        Column({ space: SP.M }) {
          Text('Agent 数据管理')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .width('100%')

          Row({ space: SP.M }) {
            Button('记账热量')
              .layoutWeight(1)
              .height(48)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .backgroundColor(DT.IOS_GREEN)
              .borderRadius(12)
              .onClick(() => router.pushUrl({ url: 'pages/AccountingPage' }))

            Button('日程管理')
              .layoutWeight(1)
              .height(48)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .backgroundColor(DT.IOS_INDIGO)
              .borderRadius(12)
              .onClick(() => router.pushUrl({ url: 'pages/SchedulePage' }))
          }
          .width('100%')
        }
        .width('100%')
        .padding(SP.L)

        Column().height(100)
      }
      .width('100%')
      .padding({ bottom: SP.L })
    }
    .width('100%')
    .layoutWeight(1)
  }

  // ========== Settings Content ==========

  @Builder
  SettingsContent() {
    Scroll() {
      Column({ space: SP.L }) {
        // Appearance Section
        this.SettingsSectionHeader('外观')

        Column() {
          this.SettingItemBuilder({
            icon: $r('sys.symbol.paintpalette.fill'),
            iconColor: DT.IOS_PURPLE,
            title: '深色模式',
            showToggle: true,
            toggleValue: this.isDarkMode()
          })

          Divider()
            .height(1)
            .color(this.isDarkMode() ? '#2C2C2E' : '#E5E5EA')
            .margin({ left: 52 })

          this.SettingItemBuilder({
            icon: $r('sys.symbol.bell.fill'),
            iconColor: DT.IOS_RED,
            title: '消息通知',
            showToggle: true,
            toggleValue: true
          })

          Divider()
            .height(1)
            .color(this.isDarkMode() ? '#2C2C2E' : '#E5E5EA')
            .margin({ left: 52 })

          this.SettingItemBuilder({
            icon: $r('sys.symbol.arrow.clockwise'),
            iconColor: DT.IOS_BLUE,
            title: '自动刷新',
            showToggle: true,
            toggleValue: true
          })
        }
        .width('100%')
        .backgroundColor(this.isDarkMode() ? '#1C1C1E' : '#FFFFFF')
        .borderRadius(12)

        // Data Section
        this.SettingsSectionHeader('数据管理')

        Column() {
          this.SettingItemBuilder({
            icon: $r('sys.symbol.trash.fill'),
            iconColor: DT.IOS_ORANGE,
            title: '清除缓存',
            showToggle: false,
            onClick: () => {}
          })

          Divider()
            .height(1)
            .color(this.isDarkMode() ? '#2C2C2E' : '#E5E5EA')
            .margin({ left: 52 })

          this.SettingItemBuilder({
            icon: $r('sys.symbol.square.and.arrow.up.fill'),
            iconColor: DT.IOS_GREEN,
            title: '导出数据',
            showToggle: false,
            onClick: () => {}
          })
        }
        .width('100%')
        .backgroundColor(this.isDarkMode() ? '#1C1C1E' : '#FFFFFF')
        .borderRadius(12)

        // About Section
        this.SettingsSectionHeader('关于')

        Column() {
          this.SettingItemBuilder({
            icon: $r('sys.symbol.info.circle.fill'),
            iconColor: DT.IOS_BLUE,
            title: '关于应用',
            showToggle: false,
            onClick: () => router.pushUrl({ url: 'pages/SettingsPage' })
          })

          Divider()
            .height(1)
            .color(this.isDarkMode() ? '#2C2C2E' : '#E5E5EA')
            .margin({ left: 52 })

          this.SettingItemBuilder({
            icon: $r('sys.symbol.star.fill'),
            iconColor: DT.IOS_YELLOW,
            title: '给个好评',
            showToggle: false,
            onClick: () => {}
          })
        }
        .width('100%')
        .backgroundColor(this.isDarkMode() ? '#1C1C1E' : '#FFFFFF')
        .borderRadius(12)

        // Version Info
        Column({ space: SP.XS }) {
          Text('Harmony Claw')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Text('Version 1.0.0')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ top: SP.XXL, bottom: SP.XXL })

        Column().height(100)
      }
      .width('100%')
      .padding(SP.L)
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  SettingsSectionHeader(title: string) {
    Text(title)
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.text_secondary'))
      .width('100%')
      .padding({ left: SP.S, top: SP.M, bottom: SP.XS })
  }

  @Builder
  SettingItemBuilder(params: SettingItemParams) {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(32)
          .height(32)
          .fill(params.iconColor + '15')

        SymbolGlyph(params.icon)
          .fontSize(16)
          .fontColor([params.iconColor])
      }
      .width(32)
      .height(32)

      Text(params.title)
        .fontSize(16)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
        .margin({ left: SP.M })

      if (params.showToggle) {
        Toggle({ type: ToggleType.Switch, isOn: params.toggleValue ?? false })
          .selectedColor(DT.IOS_GREEN)
          .width(51)
          .height(31)
      } else {
        SymbolGlyph($r('sys.symbol.chevron.right'))
          .fontSize(14)
          .fontColor([$r('app.color.text_tertiary')])
      }
    }
    .width('100%')
    .height(52)
    .padding({ left: SP.M, right: SP.M })
    .onClick(() => {
      if (params.onClick) params.onClick()
    })
  }

  // ========== Tab Bar ==========

  @Builder
  TabBarBuilder(icon: Resource, title: string, index: number) {
    Column({ space: 3 }) {
      Stack() {
        // Selected background
        Circle()
          .width(this.selectedTabIndex === index ? 36 : 0)
          .height(this.selectedTabIndex === index ? 36 : 0)
          .fill(this.isDarkMode() ? 'rgba(10, 132, 255, 0.20)' : 'rgba(0, 122, 255, 0.12)')
          .animation({ duration: 200, curve: Curve.EaseOut })

        SymbolGlyph(icon)
          .fontSize(this.selectedTabIndex === index ? 22 : 20)
          .fontColor([
            this.selectedTabIndex === index ? DT.IOS_BLUE :
            (this.isDarkMode() ? 'rgba(255, 255, 255, 0.55)' : 'rgba(0, 0, 0, 0.45)')
          ])
          .fontWeight(this.selectedTabIndex === index ? FontWeight.Medium : FontWeight.Regular)
          .animation({ duration: 200, curve: Curve.EaseOut })
      }
      .width(40)
      .height(32)
      .alignContent(Alignment.Center)

      Text(title)
        .fontSize(10)
        .fontColor([
          this.selectedTabIndex === index ? DT.IOS_BLUE :
          (this.isDarkMode() ? 'rgba(255, 255, 255, 0.50)' : 'rgba(0, 0, 0, 0.40)')
        ])
        .fontWeight(this.selectedTabIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .animation({ duration: 200, curve: Curve.EaseOut })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // ========== Build ==========

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // Tabs Content
      Tabs({ barPosition: BarPosition.End, index: $$this.selectedTabIndex }) {
        TabContent() {
          this.DashboardContent()
        }
        .tabBar(this.TabBarBuilder($r('sys.symbol.house.fill'), '首页', 0))

        TabContent() {
          this.GatewaysContent()
        }
        .tabBar(this.TabBarBuilder($r('sys.symbol.icloud'), '网关', 1))

        TabContent() {
          this.ProcessesContent()
        }
        .tabBar(this.TabBarBuilder($r('sys.symbol.bolt.fill'), '进程', 2))

        TabContent() {
          this.AgentsContent()
        }
        .tabBar(this.TabBarBuilder($r('sys.symbol.cpu.fill'), 'Agent', 3))

        TabContent() {
          this.SettingsContent()
        }
        .tabBar(this.TabBarBuilder($r('sys.symbol.gearshape'), '设置', 4))
      }
      .width('100%')
      .height('100%')
      .vertical(false)
      .scrollable(true)
      .animationDuration(this.tabAnimationDuration)
      .animationCurve(this.tabAnimationCurve)
      .barWidth('100%')
      .barHeight(64)
      .barBackgroundBlurStyle(this.isDarkMode() ? BlurStyle.NONE : BlurStyle.Regular)
      .barBackgroundColor(this.isDarkMode() ? '#000000' : 'rgba(255, 255, 255, 0.80)')
      .barOverlap(true)
      .backgroundColor(this.isDarkMode() ? '#000000' : '#F2F2F7')
      .onChange((index: number) => {
        this.selectedTabIndex = index
      })

      // Header
      Row() {
        Text('Harmony Claw')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Blank()

        if (this.selectedTabIndex === 0 || this.selectedTabIndex === 3) {
          Button() {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(22)
              .fontColor([DT.IOS_BLUE])
              .fontWeight(FontWeight.Medium)
          }
          .width(40)
          .height(40)
          .backgroundColor('transparent')
          .onClick(() => router.pushUrl({ url: 'pages/AddGatewayPage' }))
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: SP.L, right: SP.L })
      .backgroundColor(this.getHeaderBgColor())
      .backgroundBlurStyle(this.isDarkMode() ? BlurStyle.NONE : (this.headerOpacity > 0.5 ? BlurStyle.Thin : BlurStyle.NONE))
      .zIndex(100)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDarkMode() ? '#000000' : '#F2F2F7')
  }

  // Page Transition
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 200, curve: Curve.EaseIn })
      .slide(SlideEffect.Left)
  }

  // Theme utilities
  private updateThemeColors(): void {}

  private setupThemeListener(): void {
    AppStorage.setOrCreate('isSystemDarkMode', false)
  }
}
