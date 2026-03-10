import { router } from '@kit.ArkUI';
import { Colors, Typography } from '../styles/DesignTokens';
import { Spacing, Layout } from '../styles/Spacing';
import { DesignTokens as DT, Spacing as SP } from '../constants';
import { GatewayViewModel } from '../viewmodels/GatewayViewModel';
import { ChatViewModel } from '../viewmodels/ChatViewModel';
import { ProcessViewModel } from '../viewmodels/ProcessViewModel';
import { AgentViewModel } from '../viewmodels/AgentViewModel';
import { getOpenClawAPIService } from '../services/OpenClawAPIService';
import { GatewayCard } from '../components/gateway/GatewayCard';
import { SessionItem } from '../components/chat/SessionItem';
import { ProcessCard } from '../components/process/ProcessCard';
import { AgentCard } from '../components/agent/AgentCard';
import { Gateway, GatewayStatus } from '../models/Gateway';
import { Session } from '../models/Session';
import { Process } from '../models/Process';
import { Agent } from '../models/Agent';

@Entry
@Component
struct Index {
  @State selectedTabIndex: number = 0;
  @State gatewayViewModel: GatewayViewModel = new GatewayViewModel();
  @State chatViewModel: ChatViewModel = new ChatViewModel();
  @State processViewModel: ProcessViewModel = new ProcessViewModel();
  @State agentViewModel: AgentViewModel = new AgentViewModel();

  // 动态模糊状态
  @State headerOpacity: number = 0
  @State headerBlurStyle: BlurStyle = BlurStyle.NONE

  aboutToAppear() {
    this.initializeViewModels();
  }

  // 页面显示时重新同步网关状态（从其他页面返回时）
  onPageShow() {
    this.syncGatewayState();
  }

  private async initializeViewModels(): Promise<void> {
    try {
      await this.gatewayViewModel.initialize();
      await this.processViewModel.initialize();

      // If there's a current gateway, set it for agent view model
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
      // 从全局 API Service 获取当前连接的网关
      const apiService = getOpenClawAPIService();
      const currentGateway = apiService.getCurrentGateway();

      if (currentGateway) {
        console.log(`[Index] API service has gateway: ${currentGateway.name}`);
        // 更新 AgentViewModel 的网关
        if (this.agentViewModel.currentGateway?.id !== currentGateway.id) {
          console.log(`[Index] Syncing gateway to AgentViewModel: ${currentGateway.name}`);
          await this.agentViewModel.setGateway(currentGateway);
        } else {
          console.log('[Index] Gateway already synced, refreshing agents...');
          await this.agentViewModel.refresh();
        }
      } else {
        console.log('[Index] No gateway connected in API service');
        // 检查 GatewayViewModel 中是否有网关
        if (this.gatewayViewModel.currentGateway) {
          console.log(`[Index] Using gateway from GatewayViewModel: ${this.gatewayViewModel.currentGateway.name}`);
          await this.agentViewModel.setGateway(this.gatewayViewModel.currentGateway);
        }
      }

      // 刷新网关列表状态
      await this.gatewayViewModel.refresh();

      // 刷新进程数据（从已连接的网关获取真实进程）
      if (this.gatewayViewModel.currentGateway?.status === GatewayStatus.ONLINE) {
        console.log('[Index] Refreshing processes from gateway...');
        await this.processViewModel.refresh();
      }
    } catch (e) {
      console.error(`[Index] Failed to sync gateway state: ${JSON.stringify(e)}`);
    }
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

          Column({ space: SP.XS }) {
            Text(String(this.agentViewModel.getOnlineCount()))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(DT.INFO)
            Text('在线Agent')
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
    Scroll() {
      Column({ space: SP.L }) {
        // 网关统计
        Row({ space: SP.M }) {
          Column({ space: SP.XS }) {
            Text(String(this.gatewayViewModel.getTotalCount()))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(DT.BRAND_PRIMARY)
            Text('总网关数')
              .fontSize(12)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .padding(SP.L)
          .backgroundColor(DT.LIGHT_BG_PRIMARY)
          .borderRadius(SP.RADIUS_L)

          Column({ space: SP.XS }) {
            Text(String(this.gatewayViewModel.getOnlineCount()))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(DT.SUCCESS)
            Text('在线网关')
              .fontSize(12)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .padding(SP.L)
          .backgroundColor(DT.LIGHT_BG_PRIMARY)
          .borderRadius(SP.RADIUS_L)

          Column({ space: SP.XS }) {
            Text(String(this.gatewayViewModel.gateways.length - this.gatewayViewModel.getOnlineCount()))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(DT.WARNING)
            Text('离线网关')
              .fontSize(12)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .padding(SP.L)
          .backgroundColor(DT.LIGHT_BG_PRIMARY)
          .borderRadius(SP.RADIUS_L)
        }
        .width('100%')
        .padding(SP.L)

        // 网关列表标题
        Row() {
          Text('网关列表')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(DT.LIGHT_TEXT_PRIMARY)
          Blank()
          Button('刷新')
            .fontSize(12)
            .fontColor(DT.BRAND_PRIMARY)
            .backgroundColor('transparent')
            .enabled(!this.gatewayViewModel.isLoading)
            .onClick(() => {
              this.gatewayViewModel.refresh()
            })
        }
        .width('100%')
        .padding({ left: SP.L, right: SP.L })

        // 网关列表
        if (this.gatewayViewModel.isLoading) {
          Column({ space: SP.S }) {
            Text('加载中...')
              .fontSize(14)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
          }
          .margin({ top: 50 })
        } else if (this.gatewayViewModel.gateways.length === 0) {
          Column({ space: SP.S }) {
            Text('暂无网关')
              .fontSize(14)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
            Text('点击添加网关按钮开始')
              .fontSize(12)
              .fontColor(DT.LIGHT_TEXT_TERTIARY)
            Button('添加网关')
              .fontSize(12)
              .fontColor(DT.BRAND_PRIMARY)
              .backgroundColor('transparent')
              .margin({ top: SP.S })
              .onClick(() => {
                router.pushUrl({ url: 'pages/AddGatewayPage' })
              })
          }
          .margin({ top: 50 })
          .alignItems(HorizontalAlign.Center)
        } else {
          ForEach(this.gatewayViewModel.gateways, (gateway: Gateway) => {
            GatewayCard({
              gateway: gateway,
              isSelected: this.gatewayViewModel.currentGateway?.id === gateway.id,
              onConnect: () => {
                this.gatewayViewModel.connectGateway(gateway)
              },
              onDelete: () => {
                this.gatewayViewModel.deleteGateway(gateway.id)
              }
            })
          }, (gateway: Gateway) => gateway.id)
        }

        // 底部安全间距
        Column().height(20)
      }
      .width('100%')
      .padding({ bottom: SP.L })
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  ProcessesContent() {
    Scroll() {
      Column({ space: SP.L }) {
        // 进程统计
        Row({ space: SP.M }) {
          Column({ space: SP.XS }) {
            Text(String(this.processViewModel.processes.length))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(DT.BRAND_PRIMARY)
            Text('总进程数')
              .fontSize(12)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .padding(SP.L)
          .backgroundColor(DT.LIGHT_BG_PRIMARY)
          .borderRadius(SP.RADIUS_L)

          Column({ space: SP.XS }) {
            Text(String(this.processViewModel.getRunningCount()))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(DT.SUCCESS)
            Text('运行中')
              .fontSize(12)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .padding(SP.L)
          .backgroundColor(DT.LIGHT_BG_PRIMARY)
          .borderRadius(SP.RADIUS_L)

          Column({ space: SP.XS }) {
            Text(`${this.processViewModel.getTotalMemoryUsage().toFixed(0)}MB`)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(DT.WARNING)
            Text('内存占用')
              .fontSize(12)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .padding(SP.L)
          .backgroundColor(DT.LIGHT_BG_PRIMARY)
          .borderRadius(SP.RADIUS_L)
        }
        .width('100%')
        .padding(SP.L)

        // 进程列表标题
        Row() {
          Text('进程列表')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(DT.LIGHT_TEXT_PRIMARY)
          Blank()
          Button('刷新')
            .fontSize(12)
            .fontColor(DT.BRAND_PRIMARY)
            .backgroundColor('transparent')
            .enabled(!this.processViewModel.isLoading)
            .onClick(() => {
              this.processViewModel.refresh()
            })
        }
        .width('100%')
        .padding({ left: SP.L, right: SP.L })

        // 进程列表
        if (this.processViewModel.isLoading) {
          Column({ space: SP.S }) {
            Text('加载中...')
              .fontSize(14)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
          }
          .margin({ top: 50 })
        } else if (this.processViewModel.processes.length === 0) {
          Column({ space: SP.S }) {
            Text('暂无进程')
              .fontSize(14)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
            Text('连接网关后将显示进程信息')
              .fontSize(12)
              .fontColor(DT.LIGHT_TEXT_TERTIARY)
          }
          .margin({ top: 50 })
          .alignItems(HorizontalAlign.Center)
        } else {
          ForEach(this.processViewModel.processes, (process: Process) => {
            ProcessCard({
              process: process
            })
          }, (process: Process) => process.id)
        }

        // 底部安全间距
        Column().height(20)
      }
      .width('100%')
      .padding({ bottom: SP.L })
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  AgentsContent() {
    Scroll() {
      Column({ space: SP.L }) {
        // 网关连接状态提示
        if (!this.agentViewModel.currentGateway) {
          Row() {
            Text('⚠️ 请先连接网关以查看 Agents')
              .fontSize(14)
              .fontColor(DT.WARNING)
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .padding(SP.M)
          .backgroundColor('#FFF8E1')
          .borderRadius(SP.RADIUS_M)
          .margin({ left: SP.L, right: SP.L, top: SP.L })
          .onClick(() => {
            this.selectedTabIndex = 1 // 切换到网关标签
          })
        } else {
          Row() {
            Text(`已连接: ${this.agentViewModel.currentGateway.name}`)
              .fontSize(12)
              .fontColor(DT.SUCCESS)
            Blank()
            Text(`${this.agentViewModel.currentGateway.host}:${this.agentViewModel.currentGateway.port}`)
              .fontSize(12)
              .fontColor(DT.LIGHT_TEXT_TERTIARY)
          }
          .width('100%')
          .padding({ left: SP.M, right: SP.M })
          .margin({ left: SP.L, right: SP.L, top: SP.L })
        }

        // Agent 统计
        Row({ space: SP.M }) {
          Column({ space: SP.XS }) {
            Text(String(this.agentViewModel.agents.length))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(DT.BRAND_PRIMARY)
            Text('总Agent数')
              .fontSize(12)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .padding(SP.L)
          .backgroundColor(DT.LIGHT_BG_PRIMARY)
          .borderRadius(SP.RADIUS_L)

          Column({ space: SP.XS }) {
            Text(String(this.agentViewModel.getOnlineCount()))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(DT.SUCCESS)
            Text('在线Agent')
              .fontSize(12)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .padding(SP.L)
          .backgroundColor(DT.LIGHT_BG_PRIMARY)
          .borderRadius(SP.RADIUS_L)

          Column({ space: SP.XS }) {
            Text(String(this.agentViewModel.getBusyCount()))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(DT.WARNING)
            Text('忙碌Agent')
              .fontSize(12)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .padding(SP.L)
          .backgroundColor(DT.LIGHT_BG_PRIMARY)
          .borderRadius(SP.RADIUS_L)
        }
        .width('100%')
        .padding(SP.L)

        // Agent 列表标题
        Row() {
          Text('OpenClaw Agents')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(DT.LIGHT_TEXT_PRIMARY)
          Blank()
          Button('刷新')
            .fontSize(12)
            .fontColor(DT.BRAND_PRIMARY)
            .backgroundColor('transparent')
            .enabled(!this.agentViewModel.isLoading && this.agentViewModel.currentGateway !== null)
            .onClick(() => {
              this.agentViewModel.refresh()
            })
        }
        .width('100%')
        .padding({ left: SP.L, right: SP.L })

        // Agent 列表
        if (this.agentViewModel.isLoading) {
          Column({ space: SP.S }) {
            Text('加载中...')
              .fontSize(14)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
            // 显示调试信息
            if (this.agentViewModel.currentGateway) {
              Text(`正在从 ${this.agentViewModel.currentGateway.host}:${this.agentViewModel.currentGateway.port} 加载...`)
                .fontSize(10)
                .fontColor(DT.LIGHT_TEXT_TERTIARY)
            }
          }
          .margin({ top: 50 })
        } else if (this.agentViewModel.agents.length === 0) {
          Column({ space: SP.S }) {
            Text('暂无 Agent')
              .fontSize(14)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
            // 显示调试信息
            if (this.agentViewModel.currentGateway) {
              Text(`已连接: ${this.agentViewModel.currentGateway.host}:${this.agentViewModel.currentGateway.port}`)
                .fontSize(10)
                .fontColor(DT.LIGHT_TEXT_TERTIARY)
              Text('点击刷新按钮重试')
                .fontSize(10)
                .fontColor(DT.BRAND_PRIMARY)
            } else {
              Text('请先连接网关')
                .fontSize(10)
                .fontColor(DT.WARNING)
            }
            // 手动刷新按钮
            Button('手动刷新')
              .fontSize(12)
              .fontColor(DT.BRAND_PRIMARY)
              .backgroundColor('transparent')
              .margin({ top: SP.S })
              .onClick(() => {
                this.agentViewModel.refresh()
              })
          }
          .margin({ top: 50 })
          .alignItems(HorizontalAlign.Center)
        } else {
          ForEach(this.agentViewModel.agents, (agent: Agent) => {
            AgentCard({
              agent: agent,
              isSelected: this.agentViewModel.currentAgent?.id === agent.id,
              onItemClick: () => {
                this.agentViewModel.selectAgent(agent)
              },
              onSendMessage: () => {
                // TODO: 跳转到 Agent 对话页面
              }
            })
          }, (agent: Agent) => agent.id)
        }

        // 底部安全间距
        Column().height(20)
      }
      .width('100%')
      .padding({ bottom: SP.L })
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  SettingsContent() {
    Scroll() {
      Column({ space: SP.L }) {
        // 外观设置分组
        Column({ space: SP.M }) {
          Text('外观')
            .fontSize(12)
            .fontColor(DT.LIGHT_TEXT_TERTIARY)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .padding({ left: SP.S })

          Column() {
            this.SettingItemBuilder('🎨', '深色模式', true, false)
            Divider().height(1).color(DT.LIGHT_BG_SECONDARY).margin({ left: 44 })
            this.SettingItemBuilder('🔔', '消息通知', true, true)
            Divider().height(1).color(DT.LIGHT_BG_SECONDARY).margin({ left: 44 })
            this.SettingItemBuilder('🔄', '自动刷新', true, true)
          }
          .backgroundColor(DT.LIGHT_BG_PRIMARY)
          .borderRadius(SP.RADIUS_M)
        }
        .width('100%')

        // 数据管理分组
        Column({ space: SP.M }) {
          Text('数据管理')
            .fontSize(12)
            .fontColor(DT.LIGHT_TEXT_TERTIARY)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .padding({ left: SP.S })

          Column() {
            this.SettingItemBuilder('🗑', '清除缓存', false, false, () => {
              // TODO: 清除缓存
            })
            Divider().height(1).color(DT.LIGHT_BG_SECONDARY).margin({ left: 44 })
            this.SettingItemBuilder('📤', '导出数据', false, false, () => {
              // TODO: 导出数据
            })
          }
          .backgroundColor(DT.LIGHT_BG_PRIMARY)
          .borderRadius(SP.RADIUS_M)
        }
        .width('100%')

        // 关于分组
        Column({ space: SP.M }) {
          Text('关于')
            .fontSize(12)
            .fontColor(DT.LIGHT_TEXT_TERTIARY)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .padding({ left: SP.S })

          Column() {
            this.SettingItemBuilder('ℹ️', '关于应用', false, false, () => {
              // TODO: 关于页面
            })
            Divider().height(1).color(DT.LIGHT_BG_SECONDARY).margin({ left: 44 })
            this.SettingItemBuilder('⭐', '给个好评', false, false, () => {
              // TODO: 应用商店
            })
          }
          .backgroundColor(DT.LIGHT_BG_PRIMARY)
          .borderRadius(SP.RADIUS_M)
        }
        .width('100%')

        // 版本信息
        Column({ space: SP.XS }) {
          Text('Harmony Claw')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(DT.LIGHT_TEXT_PRIMARY)
          Text('Version 1.0.0')
            .fontSize(12)
            .fontColor(DT.LIGHT_TEXT_TERTIARY)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ top: SP.XL, bottom: SP.XL })
      }
      .width('100%')
      .padding(SP.L)
    }
    .width('100%')
    .layoutWeight(1)
  }

  // 设置项构建器
  @Builder
  SettingItemBuilder(icon: string, title: string, showToggle: boolean, toggleValue: boolean, onClick?: () => void) {
    Row() {
      Text(icon)
        .fontSize(20)
        .width(32)
        .textAlign(TextAlign.Center)

      Text(title)
        .fontSize(15)
        .fontColor(DT.LIGHT_TEXT_PRIMARY)
        .layoutWeight(1)
        .margin({ left: SP.S })

      if (showToggle) {
        Toggle({ type: ToggleType.Switch, isOn: toggleValue })
          .selectedColor(DT.BRAND_PRIMARY)
          .width(48)
          .height(28)
      } else {
        Text('›')
          .fontSize(20)
          .fontColor(DT.LIGHT_TEXT_TERTIARY)
      }
    }
    .width('100%')
    .height(52)
    .padding({ left: SP.M, right: SP.M })
    .onClick(() => {
      if (onClick) onClick()
    })
  }

  // 获取动态标题栏背景色
  private getHeaderBgColor(): ResourceColor {
    const alpha = Math.floor(this.headerOpacity * 0.85 * 255)
    return `rgba(255,255,255,${alpha / 255})`
  }

  // Tab 切换动画配置 - 使用 FastOutSlowIn 实现类弹簧效果
  private tabAnimationDuration: number = 350
  private tabAnimationCurve: Curve = Curve.FastOutSlowIn

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
          this.AgentsContent()
        }
        .tabBar(this.TabBarBuilder('🤖', 'Agent', 3))

        TabContent() {
          this.SettingsContent()
        }
        .tabBar(this.TabBarBuilder('⚙️', '设置', 4))
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
      .padding({ top: Layout.headerHeight })
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

        if (this.selectedTabIndex === 0 || this.selectedTabIndex === 3) {
          Button() {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(22)
              .fontColor([DT.BRAND_PRIMARY])
              .fontWeight(FontWeight.Medium)
          }
          .width(40)
          .height(40)
          .backgroundColor('transparent')
          .onClick(() => {
            router.pushUrl({ url: 'pages/AddGatewayPage' });
          })
        }
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
