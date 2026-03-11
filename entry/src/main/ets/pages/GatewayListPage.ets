/**
 * GatewayListPage.ets
 * 网关管理页面 - 优化版
 * 遵循主页设计系统规范
 */
import { router } from '@kit.ArkUI';
import { Gateway, GatewayStatus } from '../models/Gateway';
import { GatewayViewModel } from '../viewmodels/GatewayViewModel';
import { GatewayCard } from '../components/gateway/GatewayCard';
import { DesignTokens as DT, Spacing as SP, Typography as TYP, Animation as ANI } from '../constants';
import { LoadingState } from '../components/LoadingState';
import { EmptyState } from '../components/EmptyState';
import { HmCard } from '../components/common/HmCard';
import { getHttpService } from '../services/HttpService';

@Entry
@Component
struct GatewayListPage {
  @State viewModel: GatewayViewModel = new GatewayViewModel();
  @State showAddDialog: boolean = false;
  @State newGatewayIp: string = '';
  @State newGatewayPort: string = '8333';
  @State newGatewayName: string = '';
  @State testResult: string = '';
  @State isDark: boolean = false;

  // Safe area for immersive mode
  @State topSafeArea: number = 37

  aboutToAppear() {
    this.viewModel.initialize().catch((e: Error) => {
      console.error(`[GatewayListPage] Failed to initialize: ${JSON.stringify(e)}`);
    });
  }

  onPageShow() {
    this.viewModel.refresh().catch((e: Error) => {
      console.error(`[GatewayListPage] Refresh failed: ${JSON.stringify(e)}`);
    });
  }

  // 测试连接后端
  private async testConnection(): Promise<void> {
    const http = getHttpService();
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

  private async handleRefresh(): Promise<void> {
    try {
      await this.viewModel.refresh();
    } catch (e) {
      console.error(`[GatewayListPage] Refresh failed: ${JSON.stringify(e)}`);
    }
  }

  private async handleAddGateway(skipValidation: boolean = false): Promise<void> {
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

  private async handleDeleteGateway(id: string): Promise<void> {
    await this.viewModel.deleteGateway(id);
  }

  private async handleConnectGateway(gateway: Gateway): Promise<void> {
    try {
      if (gateway.status === GatewayStatus.ONLINE) {
        await this.viewModel.connectGateway(gateway);
      } else {
        const result = await this.viewModel.checkGatewayStatus(gateway);
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
  StatCard(title: string, value: string, color: string) {
    Column() {
      HmCard({
        cardPadding: SP.M,
        cardBgColor: DT.getSurfaceColor(this.isDark),
        cardBorderRadius: SP.RADIUS_L,
        shadowLevel: 'resting'
      }) {
        Column({ space: SP.XS }) {
          Text(value)
            .fontSize(28)
            .fontWeight(TYP.WEIGHT_BOLD)
            .fontColor(color)

          Text(title)
            .fontSize(TYP.SIZE_CAPTION)
            .fontColor(DT.getTextSecondary(this.isDark))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  AddGatewayDialog() {
    Column({ space: SP.L }) {
      Text('添加网关')
        .fontSize(TYP.SIZE_H2)
        .fontWeight(TYP.WEIGHT_BOLD)
        .fontColor(DT.getTextPrimary(this.isDark))

      TextInput({ placeholder: '网关名称 (可选)', text: $$this.newGatewayName })
        .width('100%')
        .height(44)
        .placeholderColor(DT.getTextSecondary(this.isDark))
        .backgroundColor(DT.LIGHT_BG_PRIMARY)
        .borderRadius(SP.RADIUS_M)

      TextInput({ placeholder: 'IP 地址', text: $$this.newGatewayIp })
        .width('100%')
        .height(44)
        .placeholderColor(DT.getTextSecondary(this.isDark))
        .backgroundColor(DT.LIGHT_BG_PRIMARY)
        .borderRadius(SP.RADIUS_M)

      TextInput({ placeholder: '端口', text: $$this.newGatewayPort })
        .width('100%')
        .height(44)
        .placeholderColor(DT.getTextSecondary(this.isDark))
        .backgroundColor(DT.LIGHT_BG_PRIMARY)
        .borderRadius(SP.RADIUS_M)
        .type(InputType.Number)

      if (this.testResult.length > 0) {
        Text(this.testResult)
          .fontSize(TYP.SIZE_SMALL)
          .fontColor(this.testResult.includes('✅') ? DT.SUCCESS : DT.ERROR)
          .maxLines(3)
      }

      if (this.viewModel.errorMessage.length > 0) {
        Text(this.viewModel.errorMessage)
          .fontSize(TYP.SIZE_SMALL)
          .fontColor(DT.ERROR)
          .maxLines(5)

        Button('强制添加 (跳过验证)')
          .width('100%')
          .height(40)
          .backgroundColor(DT.WARNING)
          .fontColor('#FFFFFF')
          .borderRadius(SP.RADIUS_M)
          .onClick(() => { this.handleAddGateway(true).catch((e: Error) => console.error(JSON.stringify(e))); })
      }

      Row({ space: SP.M }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor(DT.LIGHT_BG_PRIMARY)
          .fontColor(DT.getTextPrimary(this.isDark))
          .borderRadius(SP.RADIUS_M)
          .onClick((): void => {
            this.showAddDialog = false;
            this.viewModel.errorMessage = '';
            this.testResult = '';
          })

        Button('添加')
          .layoutWeight(1)
          .height(44)
          .backgroundColor(DT.BRAND_PRIMARY)
          .fontColor('#FFFFFF')
          .borderRadius(SP.RADIUS_M)
          .enabled(this.newGatewayIp.length > 0 && !this.viewModel.isLoading)
          .onClick(() => { this.handleAddGateway().catch((err: Error) => console.error(JSON.stringify(err))); })
      }
      .width('100%')
    }
    .width('80%')
    .padding(SP.L)
    .backgroundColor(DT.getSurfaceColor(this.isDark))
    .borderRadius(SP.RADIUS_L)
  }

  build() {
    Stack() {
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

          Text('网关管理')
            .fontSize(TYP.SIZE_H2)
            .fontWeight(TYP.WEIGHT_MEDIUM)
            .fontColor(DT.getTextPrimary(this.isDark))

          Blank()

          // 测试连接按钮
          Button('测试')
            .width(60)
            .height(36)
            .backgroundColor(DT.BRAND_SECONDARY)
            .fontColor('#FFFFFF')
            .fontSize(TYP.SIZE_BODY)
            .borderRadius(SP.RADIUS_M)
            .margin({ right: SP.S })
            .scale({ x: 1, y: 1 })
            .animation(ANI.pressFeedbackFine())
            .onClick((): void => {
              this.testConnection();
            })

          Button('+')
            .width(40)
            .height(40)
            .backgroundColor(DT.BRAND_PRIMARY)
            .fontColor('#FFFFFF')
            .fontSize(24)
            .borderRadius(SP.RADIUS_M)
            .scale({ x: 1, y: 1 })
            .animation(ANI.pressFeedbackFine())
            .onClick((): void => {
              this.showAddDialog = true;
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: SP.S, right: SP.M })
        .backgroundColor(DT.getBackgroundColor(this.isDark))

        // Stats - 使用 HmCard
        Row({ space: SP.M }) {
          this.StatCard('在线网关', String(this.viewModel.getOnlineCount()), DT.SUCCESS);
          this.StatCard('总网关数', String(this.viewModel.getTotalCount()), DT.BRAND_PRIMARY);
        }
        .width('100%')
        .padding(SP.L)

        // 测试结果
        if (this.testResult.length > 0) {
          Column() {
            HmCard({
              cardPadding: SP.M,
              cardBgColor: this.testResult.includes('成功') ? DT.SUCCESS_BG : DT.ERROR_BG,
              cardBorderRadius: SP.RADIUS_M
            }) {
              Text(this.testResult)
                .fontSize(TYP.SIZE_SMALL)
                .fontColor(this.testResult.includes('成功') ? DT.SUCCESS : DT.ERROR)
            }
          }
          .padding({ left: SP.L, right: SP.L, bottom: SP.M })
        }

        // Content
        if (this.viewModel.isLoading && this.viewModel.gateways.length === 0) {
          LoadingState({ message: '加载中...', mode: 'skeleton-list' })
            .layoutWeight(1)
        } else if (this.viewModel.gateways.length === 0) {
          EmptyState({
            icon: '📡',
            title: '暂无网关',
            message: '点击右上角 + 按钮添加网关',
            actionText: '刷新',
            onAction: () => this.handleRefresh()
          })
            .layoutWeight(1)
        } else {
          List({ space: SP.M }) {
            ForEach(this.viewModel.gateways.filter(g => g != null && g.id != null), (gateway: Gateway) => {
              ListItem() {
                GatewayCard({
                  gateway: gateway,
                  isSelected: this.viewModel.currentGateway?.id === gateway.id,
                  onConnect: (): void => { this.handleConnectGateway(gateway); },
                  onDelete: (): void => { this.handleDeleteGateway(gateway.id); }
                })
              }
            }, (gateway: Gateway) => gateway.id ?? 'unknown')
          }
          .width('100%')
          .padding(SP.L)
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(DT.getBackgroundColor(this.isDark))

      // Add Dialog
      if (this.showAddDialog) {
        Column() {
          this.AddGatewayDialog()
        }
        .width('100%')
        .height('100%')
        .backgroundColor(DT.OVERLAY_LIGHT)
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
