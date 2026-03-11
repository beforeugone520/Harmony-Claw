import { Agent, AgentStatus } from '../../models/Agent'
import { DesignTokens as DT, Spacing as SP } from '../../constants'

@Component
export struct AgentCard {
  @Prop agent: Agent
  @Prop isSelected: boolean = false
  onItemClick?: () => void
  onSendMessage?: () => void

  private isDarkMode(): boolean {
    try {
      return AppStorage.get<boolean>('isSystemDarkMode') ?? false
    } catch {
      return false
    }
  }

  private getStatusColor(): string {
    switch (this.agent.status) {
      case AgentStatus.ACTIVE:
        return DT.IOS_GREEN
      case AgentStatus.BUSY:
        return DT.IOS_ORANGE
      case AgentStatus.IDLE:
        return DT.IOS_BLUE
      case AgentStatus.ERROR:
        return DT.IOS_RED
      default:
        return '#8E8E93'
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
        return '📊'
      case 'reminder':
        return '⏰'
      case 'coding':
        return '💻'
      default:
        return '🤖'
    }
  }

  private getTypeColor(): string {
    switch (this.agent.type) {
      case 'main':
        return DT.IOS_BLUE
      case 'learning':
        return DT.IOS_PURPLE
      case 'note':
        return DT.IOS_YELLOW
      case 'accounting':
        return DT.IOS_GREEN
      case 'reminder':
        return DT.IOS_ORANGE
      case 'coding':
        return DT.IOS_INDIGO
      default:
        return DT.IOS_BLUE
    }
  }

  build() {
    Column({ space: SP.S }) {
      // Header: icon and name
      Row({ space: SP.M }) {
        // Agent icon
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(48)
            .height(48)
            .fill(this.getTypeColor() + '20')

          Text(this.getTypeIcon())
            .fontSize(22)
            .fontColor(this.getTypeColor())
        }
        .width(48)
        .height(48)

        Column({ space: SP.XS }) {
          // Name and status
          Row({ space: SP.S }) {
            Text(this.agent.displayName)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.isDarkMode() ? DT.DARK_TEXT_PRIMARY : DT.LIGHT_TEXT_PRIMARY)

            // Status indicator
            Row({ space: 4 }) {
              Circle()
                .width(8)
                .height(8)
                .fill(this.getStatusColor())

              Text(this.getStatusText())
                .fontSize(12)
                .fontColor(this.getStatusColor())
                .fontWeight(FontWeight.Medium)
            }
          }

          // Type label
          Text(this.agent.type.toUpperCase())
            .fontSize(10)
            .fontColor(this.isDarkMode() ? DT.DARK_TEXT_TERTIARY : DT.LIGHT_TEXT_TERTIARY)
            .backgroundColor(this.isDarkMode() ? '#2C2C2E' : '#F2F2F7')
            .padding({ left: SP.XS, right: SP.XS, top: 2, bottom: 2 })
            .borderRadius(4)

          // Theme description
          if (this.agent.theme) {
            Text(this.agent.theme)
              .fontSize(12)
              .fontColor(this.isDarkMode() ? DT.DARK_TEXT_SECONDARY : DT.LIGHT_TEXT_SECONDARY)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // Selected indicator
        if (this.isSelected) {
          Text('✓')
            .fontSize(20)
            .fontColor(DT.IOS_BLUE)
        }
      }
      .width('100%')

      // Metrics
      if (this.agent.metrics) {
        Divider()
          .height(1)
          .color(this.isDarkMode() ? '#2C2C2E' : '#E5E5EA')
          .margin({ top: SP.S, bottom: SP.S })

        Row({ space: SP.L }) {
          Column({ space: 2 }) {
            Text(String(this.agent.metrics.totalConversations))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isDarkMode() ? DT.DARK_TEXT_PRIMARY : DT.LIGHT_TEXT_PRIMARY)
            Text('会话')
              .fontSize(11)
              .fontColor(this.isDarkMode() ? DT.DARK_TEXT_TERTIARY : DT.LIGHT_TEXT_TERTIARY)
          }

          Column({ space: 2 }) {
            Text(String(this.agent.metrics.totalMessages))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isDarkMode() ? DT.DARK_TEXT_PRIMARY : DT.LIGHT_TEXT_PRIMARY)
            Text('消息')
              .fontSize(11)
              .fontColor(this.isDarkMode() ? DT.DARK_TEXT_TERTIARY : DT.LIGHT_TEXT_TERTIARY)
          }

          Column({ space: 2 }) {
            Text(`${this.agent.metrics.avgResponseTime}ms`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isDarkMode() ? DT.DARK_TEXT_PRIMARY : DT.LIGHT_TEXT_PRIMARY)
            Text('响应')
              .fontSize(11)
              .fontColor(this.isDarkMode() ? DT.DARK_TEXT_TERTIARY : DT.LIGHT_TEXT_TERTIARY)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
      }

      // Action button
      if (this.agent.status === AgentStatus.ACTIVE || this.agent.status === AgentStatus.IDLE) {
        Divider()
          .height(1)
          .color(this.isDarkMode() ? '#2C2C2E' : '#E5E5EA')
          .margin({ top: SP.S, bottom: SP.S })

        Row({ space: SP.M }) {
          Button('发送消息', { type: ButtonType.Capsule })
            .fontSize(13)
            .fontColor(DT.IOS_BLUE)
            .backgroundColor(DT.IOS_BLUE + '15')
            .height(36)
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
    .backgroundColor(this.isSelected ? (this.isDarkMode() ? '#1C3D5C' : '#E8F4FD') : (this.isDarkMode() ? '#1C1C1E' : '#FFFFFF'))
    .borderRadius(16)
    .border({
      width: this.isSelected ? 2 : 0,
      color: DT.IOS_BLUE
    })
    .shadow(this.isDarkMode() ? undefined : {
      radius: 8,
      color: 'rgba(0,0,0,0.06)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      if (this.onItemClick) this.onItemClick()
    })
  }
}
