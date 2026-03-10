import { router } from '@kit.ArkUI'
import { Gateway } from '../models/Gateway'
import { GatewayViewModel } from '../viewmodels/GatewayViewModel'
import { DesignTokens as DT, Spacing as SP, Typography as TYP } from '../constants'
import { HmButton, HmConfirmDialog, ToastManager } from '../components/common'
import { getHttpService } from '../services/HttpService'

@Entry
@Component
struct AddGatewayPage {
  @State viewModel: GatewayViewModel = new GatewayViewModel()
  @State gatewayName: string = ''
  @State gatewayIp: string = ''
  @State gatewayPort: string = '8333'
  @State isTesting: boolean = false
  @State testResult: string = ''
  @State testSuccess: boolean = false
  @State showConfirmDialog: boolean = false

  aboutToAppear() {
    this.viewModel.initialize().catch((e: Error) => {
      console.error(`[AddGatewayPage] Failed to initialize: ${e.message}`)
    })
  }

  private validateIp(ip: string): boolean {
    const ipRegex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
    return ipRegex.test(ip)
  }

  private validatePort(port: string): boolean {
    const portNum = parseInt(port)
    return !isNaN(portNum) && portNum > 0 && portNum <= 65535
  }

  private async testConnection() {
    if (!this.gatewayIp) {
      ToastManager.warning('请输入 IP 地址')
      return
    }

    if (!this.validateIp(this.gatewayIp)) {
      ToastManager.error('IP 地址格式不正确')
      return
    }

    const port = parseInt(this.gatewayPort) || 8333
    this.isTesting = true
    this.testResult = '正在测试连接...'
    this.testSuccess = false

    try {
      const http = getHttpService()
      http.setBaseUrl(`http://${this.gatewayIp}:${port}`)
      const isConnected = await http.checkConnection()

      this.testSuccess = isConnected
      this.testResult = isConnected
        ? `✅ 连接成功！`
        : `❌ 连接失败`

      if (isConnected) {
        ToastManager.success('连接测试成功')
      } else {
        ToastManager.error('连接测试失败')
      }
    } catch (e) {
      this.testSuccess = false
      this.testResult = `❌ 连接异常`
      ToastManager.error('连接测试失败')
    } finally {
      this.isTesting = false
    }
  }

  private async saveGateway(skipValidation: boolean = false) {
    if (!this.gatewayIp) {
      ToastManager.warning('请输入 IP 地址')
      return
    }

    if (!this.validateIp(this.gatewayIp)) {
      ToastManager.error('IP 地址格式不正确')
      return
    }

    if (!this.validatePort(this.gatewayPort)) {
      ToastManager.error('端口范围应为 1-65535')
      return
    }

    const port = parseInt(this.gatewayPort)
    const gateway = new Gateway()
    gateway.name = this.gatewayName || `Gateway ${this.viewModel.getTotalCount() + 1}`
    gateway.host = this.gatewayIp
    gateway.port = port

    ToastManager.loading('正在添加...')
    const success = await this.viewModel.addGateway(gateway, skipValidation)
    ToastManager.hideLoading()

    if (success) {
      ToastManager.success('网关添加成功')
      router.back()
    } else if (!skipValidation) {
      this.showConfirmDialog = true
    } else {
      ToastManager.error(this.viewModel.errorMessage || '添加失败')
    }
  }

  build() {
    Column({ space: SP.L }) {
      // 标题
      Row() {
        Text('添加网关')
          .fontSize(TYP.SIZE_H2)
          .fontWeight(TYP.WEIGHT_BOLD)
          .fontColor(DT.LIGHT_TEXT_PRIMARY)

        Blank()

        Button('X')
          .width(36)
          .height(36)
          .backgroundColor('transparent')
          .fontColor(DT.LIGHT_TEXT_SECONDARY)
          .onClick(() => router.back())
      }
      .width('100%')
      .height(56)
      .padding({ left: SP.L, right: SP.L })
      .backgroundColor(DT.LIGHT_BG_PRIMARY)

      // 表单内容
      Column({ space: SP.L }) {
        // 说明文字
        Text('输入网关的 IP 地址和端口')
          .fontSize(TYP.SIZE_CAPTION)
          .fontColor(DT.LIGHT_TEXT_SECONDARY)
          .width('100%')

        // 网关名称
        Column({ space: SP.XS }) {
          Text('网关名称')
            .fontSize(TYP.SIZE_CAPTION)
            .fontColor(DT.LIGHT_TEXT_SECONDARY)
          TextInput({ placeholder: '自定义名称（可选）' })
            .placeholderColor(DT.LIGHT_TEXT_TERTIARY)
            .fontSize(TYP.SIZE_BODY)
            .width('100%')
            .height(48)
            .backgroundColor(DT.LIGHT_BG_PRIMARY)
            .borderRadius(SP.RADIUS_M)
            .maxLength(50)
            .onChange((value: string) => { this.gatewayName = value })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // IP 地址
        Column({ space: SP.XS }) {
          Text('IP 地址 *')
            .fontSize(TYP.SIZE_CAPTION)
            .fontColor(DT.LIGHT_TEXT_SECONDARY)
          TextInput({ placeholder: '例如：192.168.1.100' })
            .placeholderColor(DT.LIGHT_TEXT_TERTIARY)
            .fontSize(TYP.SIZE_BODY)
            .width('100%')
            .height(48)
            .backgroundColor(DT.LIGHT_BG_PRIMARY)
            .borderRadius(SP.RADIUS_M)
            .maxLength(15)
            .onChange((value: string) => { this.gatewayIp = value })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 端口
        Column({ space: SP.XS }) {
          Text('端口 *')
            .fontSize(TYP.SIZE_CAPTION)
            .fontColor(DT.LIGHT_TEXT_SECONDARY)
          TextInput({ placeholder: '默认 8333' })
            .placeholderColor(DT.LIGHT_TEXT_TERTIARY)
            .fontSize(TYP.SIZE_BODY)
            .width('100%')
            .height(48)
            .backgroundColor(DT.LIGHT_BG_PRIMARY)
            .borderRadius(SP.RADIUS_M)
            .maxLength(5)
            .type(InputType.Number)
            .onChange((value: string) => { this.gatewayPort = value })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 测试结果
        if (this.testResult) {
          Row() {
            Text(this.testResult)
              .fontSize(TYP.SIZE_SMALL)
              .fontColor(this.testSuccess ? DT.SUCCESS : DT.ERROR)
          }
          .width('100%')
          .padding(SP.M)
          .backgroundColor(this.testSuccess ? DT.SUCCESS_BG : DT.ERROR_BG)
          .borderRadius(SP.RADIUS_S)
        }

        // 错误信息
        if (this.viewModel.errorMessage) {
          Row() {
            Text(this.viewModel.errorMessage)
              .fontSize(TYP.SIZE_SMALL)
              .fontColor(DT.ERROR)
          }
          .width('100%')
          .padding(SP.M)
          .backgroundColor(DT.ERROR_BG)
          .borderRadius(SP.RADIUS_S)
        }

        // 按钮
        Row({ space: SP.M }) {
          HmButton({
            btnText: this.isTesting ? '测试中...' : '测试连接',
            btnType: 1,
            btnWidth: 120,
            btnDisabled: this.isTesting || !this.gatewayIp,
            onBtnClick: (): void => { this.testConnection() }
          })

          HmButton({
            btnText: '添加网关',
            btnType: 0,
            btnWidth: 140,
            btnDisabled: !this.gatewayIp || this.viewModel.isLoading,
            btnLoading: this.viewModel.isLoading,
            onBtnClick: (): void => { this.saveGateway() }
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.End)

        // 提示信息
        Column({ space: SP.S }) {
          Text('提示：')
            .fontSize(TYP.SIZE_CAPTION)
            .fontWeight(TYP.WEIGHT_MEDIUM)
            .fontColor(DT.LIGHT_TEXT_SECONDARY)

          Text('• 确保网关服务已启动')
            .fontSize(TYP.SIZE_SMALL)
            .fontColor(DT.LIGHT_TEXT_TERTIARY)

          Text('• 手机和网关在同一个局域网')
            .fontSize(TYP.SIZE_SMALL)
            .fontColor(DT.LIGHT_TEXT_TERTIARY)

          Text('• 默认端口为 8333')
            .fontSize(TYP.SIZE_SMALL)
            .fontColor(DT.LIGHT_TEXT_TERTIARY)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .layoutWeight(1)
      .padding(SP.L)
      .backgroundColor(DT.LIGHT_BG_SECONDARY)

      // 确认对话框
      if (this.showConfirmDialog) {
        Column() {
          HmConfirmDialog({
            confirmVisible: true,
            confirmTitle: '添加失败',
            confirmMessage: this.viewModel.errorMessage || '无法连接到网关，是否强制添加？',
            confirmBtnText: '强制添加',
            cancelBtnText: '取消',
            isDanger: true,
            onConfirm: (): void => {
              this.showConfirmDialog = false
              this.saveGateway(true)
            },
            onCancel: (): void => { this.showConfirmDialog = false }
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .position({ x: 0, y: 0 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DT.LIGHT_BG_SECONDARY)
  }
}
