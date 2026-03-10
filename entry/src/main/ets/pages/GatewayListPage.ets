import { router } from '@kit.ArkUI';
import { Gateway, GatewayStatus } from '../models/Gateway';
import { GatewayViewModel } from '../viewmodels/GatewayViewModel';
import { GatewayCard } from '../components/gateway/GatewayCard';
import { Spacing as SP } from '../constants';
import { LoadingState } from '../components/LoadingState';
import { EmptyState } from '../components/EmptyState';
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
  aboutToAppear() {
    this.viewModel.initialize().catch((e: Error) => {
      console.error(`[GatewayListPage] Failed to initialize: ${JSON.stringify(e)}`);
    });
  }

  // 测试连接后端
  private async testConnection(): Promise<void> {
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
    Column({ space: SP.L }) {
      Text('添加网关')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      TextInput({ placeholder: '网关名称 (可选)', text: $$this.newGatewayName })
        .width('100%')
        .height(44)
        .placeholderColor($r('app.color.text_tertiary'))
        .backgroundColor($r('app.color.background_tertiary'))
        .borderRadius(8)

      TextInput({ placeholder: 'IP 地址', text: $$this.newGatewayIp })
        .width('100%')
        .height(44)
        .placeholderColor($r('app.color.text_tertiary'))
        .backgroundColor($r('app.color.background_tertiary'))
        .borderRadius(8)

      TextInput({ placeholder: '端口', text: $$this.newGatewayPort })
        .width('100%')
        .height(44)
        .placeholderColor($r('app.color.text_tertiary'))
        .backgroundColor($r('app.color.background_tertiary'))
        .borderRadius(8)
        .type(InputType.Number)

      if (this.testResult.length > 0) {
        Text(this.testResult)
          .fontSize(12)
          .fontColor(this.testResult.includes('✅') ? $r('app.color.success') : $r('app.color.text_secondary'))
          .maxLines(3)
      }

      if (this.viewModel.errorMessage.length > 0) {
        Text(this.viewModel.errorMessage)
          .fontSize(12)
          .fontColor($r('app.color.error'))
          .maxLines(5)

        Button('强制添加 (跳过验证)')
          .width('100%')
          .height(40)
          .backgroundColor($r('app.color.warning'))
          .fontColor($r('app.color.text_inverse'))
          .onClick(() => { this.handleAddGateway(true).catch((e: Error) => console.error(JSON.stringify(e))); })
      }

      Row({ space: SP.M }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor($r('app.color.background_tertiary'))
          .fontColor($r('app.color.text_primary'))
          .onClick((): void => {
            this.showAddDialog = false;
            this.viewModel.errorMessage = '';
            this.testResult = '';
          })

        Button('添加')
          .layoutWeight(1)
          .height(44)
          .backgroundColor($r('app.color.brand_primary'))
          .enabled(this.newGatewayIp.length > 0 && !this.viewModel.isLoading)
          .onClick(() => { this.handleAddGateway().catch((err: Error) => console.error(JSON.stringify(err))); })
      }
      .width('100%')
    }
    .width('80%')
    .padding(SP.L)
    .backgroundColor($r('app.color.surface_card'))
    .borderRadius(16)
  }

  build() {
    Stack() {
      Column({ space: 0 }) {
        // Header
        Row() {
          Text('网关管理')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Blank()

          // 测试连接按钮
          Button('测试')
            .width(60)
            .height(36)
            .backgroundColor($r('app.color.brand_secondary'))
            .fontColor($r('app.color.text_inverse'))
            .fontSize(14)
            .margin({ right: SP.S })
            .onClick((): void => {
              this.testConnection();
            })

          Button('+')
            .width(40)
            .height(40)
            .backgroundColor($r('app.color.brand_primary'))
            .fontColor($r('app.color.text_inverse'))
            .fontSize(24)
            .onClick((): void => {
              router.pushUrl({ url: 'pages/AddGatewayPage' })
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: SP.L, right: SP.L })
        .backgroundColor($r('app.color.background_secondary'))

        // Stats
        Row({ space: SP.M }) {
          Column({ space: SP.XS }) {
            Text(String(this.viewModel.getOnlineCount()))
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.success'))
            Text('在线网关')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
          }
          .layoutWeight(1)

          Column({ space: SP.XS }) {
            Text(String(this.viewModel.getTotalCount()))
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.brand_primary'))
            Text('总网关数')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(SP.L)
        .backgroundColor($r('app.color.surface_card'))

        // 测试结果
        if (this.testResult.length > 0) {
          Row() {
            Text(this.testResult)
              .fontSize(12)
              .fontColor(this.testResult.includes('成功') ? $r('app.color.success') : $r('app.color.error'))
              .padding(SP.M)
          }
          .width('100%')
          .backgroundColor(this.testResult.includes('成功') ? '#E8F5E9' : '#FFEBEE')
          .borderRadius(8)
          .margin({ left: SP.L, right: SP.L, top: SP.M })
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
      .backgroundColor($r('app.color.background_primary'))

      // Add Dialog
      if (this.showAddDialog) {
        Column() {
          this.AddGatewayDialog()
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.overlay_light'))
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
