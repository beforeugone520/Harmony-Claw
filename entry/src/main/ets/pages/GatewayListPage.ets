import { router } from '@kit.ArkUI';
import { Gateway, GatewayStatus } from '../models/Gateway';
import { GatewayViewModel } from '../viewmodels/GatewayViewModel';
import { GatewayCard } from '../components/gateway/GatewayCard';
import { Colors, Typography } from '../styles/DesignTokens';
import { Spacing, Layout } from '../styles/Spacing';
import { LoadingState } from '../components/LoadingState';
import { EmptyState } from '../components/EmptyState';
import { getHttpService } from '../services/HttpService';
import { getGatewayRepository } from '../repositories/GatewayRepository';

@Entry
@Component
struct GatewayListPage {
  @State viewModel: GatewayViewModel = new GatewayViewModel();
  @State showAddDialog: boolean = false;
  @State newGatewayIp: string = '';
  @State newGatewayPort: string = '8333';
  @State newGatewayName: string = '';
  @State testResult: string = '';

  aboutToAppear() {
    this.viewModel.initialize().catch((e: Error) => {
      console.error(`[GatewayListPage] Failed to initialize: ${JSON.stringify(e)}`);
    });
  }

  // 测试连接后端
  private async testConnection() {
    const http = getHttpService();
    
    // 使用输入框的 IP 和端口
    const host = this.newGatewayIp.length > 0 ? this.newGatewayIp : '192.168.1.100';
    const port = parseInt(this.newGatewayPort) || 8333;
    
    http.setBaseUrl(`http://${host}:${port}`);
    console.log(`[Test] Testing connection to http://${host}:${port}`);
    
    this.testResult = `正在测试 ${host}:${port}...`;
    try {
      const isConnected = await http.checkConnection();
      this.testResult = isConnected ? `✅ ${host}:${port} 连接成功！` : `❌ ${host}:${port} 连接失败`;
    } catch (e) {
      this.testResult = `❌ 错误: ${JSON.stringify(e)}`;
    }
  }

  private async handleRefresh() {
    try {
      await this.viewModel.refresh();
    } catch (e) {
      console.error(`[GatewayListPage] Refresh failed: ${JSON.stringify(e)}`);
    }
  }

  private async handleAddGateway(skipValidation: boolean = false) {
    const port = parseInt(this.newGatewayPort) || 8333;
    const gateway = new Gateway();
    gateway.name = this.newGatewayName || `Gateway ${this.viewModel.getTotalCount() + 1}`;
    gateway.host = this.newGatewayIp;
    gateway.port = port;

    const success = await this.viewModel.addGateway(gateway, skipValidation);
    if (success) {
      this.showAddDialog = false;
      this.newGatewayIp = '';
      this.newGatewayPort = '8333';
      this.newGatewayName = '';
      this.testResult = '';
    }
  }

  private async handleDeleteGateway(id: string) {
    await this.viewModel.deleteGateway(id);
  }

  private async handleConnectGateway(gateway: Gateway) {
    try {
      if (gateway.status === GatewayStatus.ONLINE) {
        // 在线状态：执行连接
        await this.viewModel.connectGateway(gateway);
      } else {
        // 离线状态：刷新状态
        const result = await this.viewModel.checkGatewayStatus(gateway);
        // 通过ViewModel更新网关状态，避免直接修改对象
        await this.viewModel.updateGatewayStatus(gateway, result.status);
        this.testResult = result.error
          ? `状态检测失败: ${result.error}`
          : (result.status === GatewayStatus.ONLINE ? '网关在线' : '网关离线');
      }
    } catch (e) {
      console.error(`[GatewayListPage] handleConnectGateway failed: ${JSON.stringify(e)}`);
    }
  }

  @Builder
  AddGatewayDialog() {
    Column({ space: Spacing.lg }) {
      Text('添加网关')
        .fontSize(Typography.sizeH3)
        .fontWeight(Typography.weightBold)
        .fontColor(Colors.textPrimary)

      TextInput({ placeholder: '网关名称 (可选)', text: $$this.newGatewayName })
        .width('100%')
        .height(44)
        .placeholderColor(Colors.textTertiary)
        .backgroundColor(Colors.backgroundTertiary)
        .borderRadius(8)

      TextInput({ placeholder: 'IP 地址', text: $$this.newGatewayIp })
        .width('100%')
        .height(44)
        .placeholderColor(Colors.textTertiary)
        .backgroundColor(Colors.backgroundTertiary)
        .borderRadius(8)

      TextInput({ placeholder: '端口', text: $$this.newGatewayPort })
        .width('100%')
        .height(44)
        .placeholderColor(Colors.textTertiary)
        .backgroundColor(Colors.backgroundTertiary)
        .borderRadius(8)
        .type(InputType.Number)

      if (this.testResult.length > 0) {
        Text(this.testResult)
          .fontSize(Typography.sizeSmall)
          .fontColor(this.testResult.includes('✅') ? Colors.success : Colors.textSecondary)
          .maxLines(3)
      }

      if (this.viewModel.errorMessage.length > 0) {
        Text(this.viewModel.errorMessage)
          .fontSize(Typography.sizeSmall)
          .fontColor(Colors.error)
          .maxLines(5)

        Button('强制添加 (跳过验证)')
          .width('100%')
          .height(40)
          .backgroundColor(Colors.warning)
          .fontColor(Colors.textInverse)
          .onClick(() => this.handleAddGateway(true))
      }

      Row({ space: Spacing.md }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor(Colors.backgroundTertiary)
          .fontColor(Colors.textPrimary)
          .onClick(() => {
            this.showAddDialog = false;
            this.viewModel.errorMessage = '';
            this.testResult = '';
          })

        Button('添加')
          .layoutWeight(1)
          .height(44)
          .backgroundColor(Colors.brandPrimary)
          .enabled(this.newGatewayIp.length > 0 && !this.viewModel.isLoading)
          .onClick(() => this.handleAddGateway())
      }
      .width('100%')
    }
    .width('80%')
    .padding(Spacing.lg)
    .backgroundColor(Colors.surfaceCard)
    .borderRadius(16)
  }

  build() {
    Stack() {
      Column({ space: 0 }) {
        // Header
        Row() {
          Text('网关管理')
            .fontSize(Typography.sizeH3)
            .fontWeight(Typography.weightBold)
            .fontColor(Colors.textPrimary)

          Blank()

          // 测试连接按钮
          Button('测试')
            .width(60)
            .height(36)
            .backgroundColor(Colors.brandSecondary)
            .fontColor(Colors.textInverse)
            .fontSize(14)
            .margin({ right: Spacing.sm })
            .onClick(() => {
              this.testConnection();
            })

          Button('+')
            .width(40)
            .height(40)
            .backgroundColor(Colors.brandPrimary)
            .fontColor(Colors.textInverse)
            .fontSize(24)
            .onClick(() => {
              this.showAddDialog = true;
            })
        }
        .width('100%')
        .height(Layout.headerHeight)
        .padding({ left: Spacing.lg, right: Spacing.lg })
        .backgroundColor(Colors.backgroundSecondary)

        // Stats
        Row({ space: Spacing.md }) {
          Column({ space: Spacing.xs }) {
            Text(String(this.viewModel.getOnlineCount()))
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.success)
            Text('在线网关')
              .fontSize(Typography.sizeCaption)
              .fontColor(Colors.textSecondary)
          }
          .layoutWeight(1)

          Column({ space: Spacing.xs }) {
            Text(String(this.viewModel.getTotalCount()))
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.brandPrimary)
            Text('总网关数')
              .fontSize(Typography.sizeCaption)
              .fontColor(Colors.textSecondary)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(Spacing.lg)
        .backgroundColor(Colors.surfaceCard)

        // 测试结果
        if (this.testResult.length > 0) {
          Row() {
            Text(this.testResult)
              .fontSize(Typography.sizeSmall)
              .fontColor(this.testResult.includes('成功') ? Colors.success : Colors.error)
              .padding(Spacing.md)
          }
          .width('100%')
          .backgroundColor(this.testResult.includes('成功') ? '#E8F5E9' : '#FFEBEE')
          .borderRadius(8)
          .margin({ left: Spacing.lg, right: Spacing.lg, top: Spacing.md })
        }

        // Content
        if (this.viewModel.isLoading && this.viewModel.gateways.length === 0) {
          LoadingState({ message: '加载中...' })
        } else if (this.viewModel.gateways.length === 0) {
          EmptyState({
            title: '暂无网关',
            message: '点击右上角 + 按钮添加网关'
          })
        } else {
          List({ space: Spacing.md }) {
            ForEach(this.viewModel.gateways.filter(g => g != null && g.id != null), (gateway: Gateway) => {
              ListItem() {
                GatewayCard({
                  gateway: gateway,
                  isSelected: this.viewModel.currentGateway?.id === gateway.id,
                  onConnect: () => { this.handleConnectGateway(gateway); },
                  onDelete: () => { this.handleDeleteGateway(gateway.id); }
                })
              }
            }, (gateway: Gateway) => gateway.id ?? 'unknown')
          }
          .width('100%')
          .padding(Spacing.lg)
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Colors.backgroundPrimary)

      // Add Dialog
      if (this.showAddDialog) {
        Column() {
          this.AddGatewayDialog()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.showAddDialog = false;
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  // 页面转场动画
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 200, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
  }
}
