/**
 * AddGatewayPage.ets
 * 添加网关页面 - HarmonyOS 6 风格
 */
import { router } from '@kit.ArkUI'
import { Gateway, GatewayStatus } from '../models/Gateway'
import { GatewayViewModel } from '../viewmodels/GatewayViewModel'
import { DesignTokens as DT, Spacing as SP, Typography as TYP } from '../constants'
import { HmButton, HmInput, HmCard, HmConfirmDialog, ToastManager } from '../components/common'
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

  // 验证 IP 地址格式
  private validateIp(ip: string): boolean {
    const ipRegex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
    return ipRegex.test(ip)
  }

  // 验证端口
  private validatePort(port: string): boolean {
    const portNum = parseInt(port)
    return !isNaN(portNum) && portNum > 0 && portNum <= 65535
  }

  // 测试连接
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
        ? `✅ 连接成功！网关响应正常`
        : `❌ 连接失败，请检查 IP 和端口`

      if (isConnected) {
        ToastManager.success('连接测试成功')
      } else {
        ToastManager.error('连接测试失败')
      }
    } catch (e) {
      this.testSuccess = false
      this.testResult = `❌ 连接异常: ${e instanceof Error ? e.message : '未知错误'}`
      ToastManager.error('连接测试失败')
    } finally {
      this.isTesting = false
    }
  }

  // 保存网关
  private async saveGateway() {
    // 验证输入
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

    ToastManager.loading('正在添加网关...')

    const success = await this.viewModel.addGateway(gateway, false)

    ToastManager.hideLoading()

    if (success) {
      ToastManager.success('网关添加成功')
      router.back()
    } else {
      // 添加失败，显示确认对话框
      this.showConfirmDialog = true
    }
  }

  // 强制保存（跳过验证）
  private async forceSaveGateway() {
    const port = parseInt(this.gatewayPort) || 8333
    const gateway = new Gateway()
    gateway.name = this.gatewayName || `Gateway ${this.viewModel.getTotalCount() + 1}`
    gateway.host = this.gatewayIp
    gateway.port = port

    ToastManager.loading('正在添加...')

    const success = await this.viewModel.addGateway(gateway, true)

    ToastManager.hideLoading()

    if (success) {
      ToastManager.success('网关已添加')
      router.back()
    } else {
      ToastManager.error(this.viewModel.errorMessage || '添加失败')
    }
  }

  build() {
    Navigation() {
      Scroll() {
        Column({ space: SP.L }) {
          // 说明卡片
          HmCard({
            variant: 2, // FILLED
            radius: 1,  // MEDIUM
            padding: { top: SP.M, bottom: SP.M, left: SP.M, right: SP.M }
          }) {
            Column({ space: SP.XS }) {
              Text('添加 OpenClaw 网关')
                .fontSize(TYP.SIZE_H3)
                .fontWeight(TYP.WEIGHT_BOLD)
                .fontColor(DT.LIGHT_TEXT_PRIMARY)

              Text('输入网关的 IP 地址和端口，系统会自动检测连接状态')
                .fontSize(TYP.SIZE_CAPTION)
                .fontColor(DT.LIGHT_TEXT_SECONDARY)
            }
            .alignItems(HorizontalAlign.Start)
          }

          // 表单区域
          HmCard({
            padding: { top: SP.L, bottom: SP.L, left: SP.L, right: SP.L }
          }) {
            Column({ space: SP.L }) {
              // 网关名称
              HmInput({
                label: '网关名称',
                placeholder: '自定义名称（可选）',
                value: $$this.gatewayName,
                maxLength: 50
              })

              // IP 地址
              HmInput({
                label: 'IP 地址 *',
                placeholder: '例如：192.168.1.100',
                value: $$this.gatewayIp,
                maxLength: 15
              })

              // 端口
              HmInput({
                label: '端口 *',
                placeholder: '默认 8333',
                value: $$this.gatewayPort,
                type: 1, // NUMBER
                maxLength: 5
              })

              // 测试结果展示
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

              // 操作按钮
              Row({ space: SP.M }) {
                HmButton({
                  text: this.isTesting ? '测试中...' : '测试连接',
                  type: 1, // SECONDARY
                  width: 120,
                  disabled: this.isTesting || !this.gatewayIp,
                  onClick: () => this.testConnection()
                })

                HmButton({
                  text: '添加网关',
                  type: 0, // PRIMARY
                  width: 140,
                  disabled: !this.gatewayIp || this.viewModel.isLoading,
                  loading: this.viewModel.isLoading,
                  onClick: () => this.saveGateway()
                })
              }
              .width('100%')
              .justifyContent(FlexAlign.End)
            }
          }

          // 提示信息
          Column({ space: SP.S }) {
            Text('提示：')
              .fontSize(TYP.SIZE_CAPTION)
              .fontWeight(TYP.WEIGHT_MEDIUM)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)

            Text('• 确保网关服务已启动并监听对应端口')
              .fontSize(TYP.SIZE_SMALL)
              .fontColor(DT.LIGHT_TEXT_TERTIARY)

            Text('• 手机和网关在同一个局域网内')
              .fontSize(TYP.SIZE_SMALL)
              .fontColor(DT.LIGHT_TEXT_TERTIARY)

            Text('• 默认端口为 8333，如无修改请保持默认')
              .fontSize(TYP.SIZE_SMALL)
              .fontColor(DT.LIGHT_TEXT_TERTIARY)
          }
          .width('100%')
          .padding({ left: SP.S, right: SP.S })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(SP.PAGE_HORIZONTAL)
      }
    }
    .title('添加网关')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .backgroundColor(DT.LIGHT_BG_SECONDARY)
    // 确认对话框
    .overlay(
      HmConfirmDialog({
        visible: this.showConfirmDialog,
        title: '添加失败',
        message: this.viewModel.errorMessage || '无法连接到网关，是否强制添加？',
        confirmText: '强制添加',
        cancelText: '取消',
        danger: true,
        onConfirm: () => {
          this.showConfirmDialog = false
          this.forceSaveGateway()
        },
        onCancel: () => {
          this.showConfirmDialog = false
        }
      })
    )
  }
}
