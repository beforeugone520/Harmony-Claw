import { Agent, AgentStatus } from '../../models/Agent'
import { DesignTokens as DT, Spacing as SP, Typography as TYP } from '../../constants'

@Component
export struct AgentCard {
  @Prop agent: Agent
  @Prop isSelected: boolean = false
  onItemClick?: () => void
  onSendMessage?: () => void

  private getStatusColor(): ResourceColor {
    switch (this.agent.status) {
      case AgentStatus.ACTIVE:
        return DT.SUCCESS
      case AgentStatus.BUSY:
        return DT.WARNING
      case AgentStatus.IDLE:
        return DT.INFO
      case AgentStatus.ERROR:
        return DT.ERROR
      default:
        return DT.LIGHT_TEXT_TERTIARY
    }
  }

  private getStatusText(): string {
    switch (this.agent.status) {
      case AgentStatus.ACTIVE:
        return '在线'
      case AgentStatus.BUSY:
        return '忙碌'
      case AgentStatus.IDLE:
        return '空闲'
      case AgentStatus.ERROR:
        return '错误'
      case AgentStatus.OFFLINE:
        return '离线'
      default:
        return '未知'
    }
  }

  private getTypeIcon(): string {
    switch (this.agent.type) {
      case 'main':
        return '🏠'
      case 'learning':
        return '📚'
      case 'note':
        return '📝'
      case 'accounting':
        return '💰'
      case 'reminder':
        return '⏰'
      case 'coding':
        return '💻'
      default:
        return '🤖'
    }
  }

  build() {
    Column({ space: SP.S }) {
      // 头部：图标和名称
      Row({ space: SP.M }) {
        // Agent 图标
        Text(this.agent.emoji || this.getTypeIcon())
          .fontSize(40)
          .width(56)
          .height(56)
          .textAlign(TextAlign.Center)
          .backgroundColor(DT.LIGHT_BG_SECONDARY)
          .borderRadius(SP.RADIUS_M)

        Column({ space: SP.XS }) {
          // 名称和状态
          Row({ space: SP.S }) {
            Text(this.agent.displayName)
              .fontSize(TYP.SIZE_H3)
              .fontWeight(TYP.WEIGHT_BOLD)
              .fontColor(DT.LIGHT_TEXT_PRIMARY)

            // 状态指示器
            Row({ space: 4 }) {
              Circle()
                .width(8)
                .height(8)
                .fill(this.getStatusColor())

              Text(this.getStatusText())
                .fontSize(TYP.SIZE_SMALL)
                .fontColor(this.getStatusColor())
            }
          }

          // 类型标签
          Text(this.agent.type.toUpperCase())
            .fontSize(TYP.SIZE_CAPTION)
            .fontColor(DT.LIGHT_TEXT_TERTIARY)
            .backgroundColor(DT.LIGHT_BG_SECONDARY)
            .padding({ left: SP.XS, right: SP.XS, top: 2, bottom: 2 })
            .borderRadius(SP.RADIUS_XS)

          // 主题描述
          if (this.agent.theme) {
            Text(this.agent.theme)
              .fontSize(TYP.SIZE_CAPTION)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 选中指示器
        if (this.isSelected) {
          Circle()
            .width(12)
            .height(12)
            .fill(DT.BRAND_PRIMARY)
        }
      }
      .width('100%')

      // 指标信息
      if (this.agent.metrics) {
        Divider().height(1).color(DT.LIGHT_BG_SECONDARY).margin({ top: SP.S, bottom: SP.S })

        Row({ space: SP.L }) {
          Column({ space: 2 }) {
            Text(String(this.agent.metrics.totalConversations))
              .fontSize(TYP.SIZE_BODY)
              .fontWeight(TYP.WEIGHT_BOLD)
              .fontColor(DT.LIGHT_TEXT_PRIMARY)
            Text('会话')
              .fontSize(TYP.SIZE_CAPTION)
              .fontColor(DT.LIGHT_TEXT_TERTIARY)
          }

          Column({ space: 2 }) {
            Text(String(this.agent.metrics.totalMessages))
              .fontSize(TYP.SIZE_BODY)
              .fontWeight(TYP.WEIGHT_BOLD)
              .fontColor(DT.LIGHT_TEXT_PRIMARY)
            Text('消息')
              .fontSize(TYP.SIZE_CAPTION)
              .fontColor(DT.LIGHT_TEXT_TERTIARY)
          }

          Column({ space: 2 }) {
            Text(`${this.agent.metrics.avgResponseTime}ms`)
              .fontSize(TYP.SIZE_BODY)
              .fontWeight(TYP.WEIGHT_BOLD)
              .fontColor(DT.LIGHT_TEXT_PRIMARY)
            Text('响应')
              .fontSize(TYP.SIZE_CAPTION)
              .fontColor(DT.LIGHT_TEXT_TERTIARY)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
      }

      // 操作按钮
      if (this.agent.status === AgentStatus.ACTIVE || this.agent.status === AgentStatus.IDLE) {
        Divider().height(1).color(DT.LIGHT_BG_SECONDARY).margin({ top: SP.S, bottom: SP.S })

        Row({ space: SP.M }) {
          Button('发送消息', { type: ButtonType.Capsule })
            .fontSize(TYP.SIZE_SMALL)
            .fontColor(DT.BRAND_PRIMARY)
            .backgroundColor(DT.BRAND_LIGHT)
            .height(32)
            .layoutWeight(1)
            .onClick(() => {
              if (this.onSendMessage) this.onSendMessage()
            })
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(SP.M)
    .backgroundColor(this.isSelected ? DT.BRAND_LIGHT : DT.LIGHT_BG_PRIMARY)
    .borderRadius(SP.RADIUS_M)
    .shadow({ radius: 4, color: DT.SHADOW_LIGHT, offsetX: 0, offsetY: 1 })
    .onClick(() => {
      if (this.onItemClick) this.onItemClick()
    })
  }
}
