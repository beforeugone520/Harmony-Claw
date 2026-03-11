import { Gateway, GatewayStatus } from '../../models/Gateway';
import { Spacing as SP } from '../../constants';
import { DesignTokens as DT } from '../../constants/DesignTokens';
import { DateUtils } from '../../utils/DateUtils';
import { promptAction } from '@kit.ArkUI';

interface DialogResult {
  index: number;
}

@Component
export struct GatewayCard {
  @Prop gateway: Gateway;
  @Prop isSelected: boolean = false;
  @Prop isDark: boolean = false;
  onConnect?: () => void;
  onDelete?: () => void;

  private showDeleteConfirm(): void {
    promptAction.showDialog({
      title: '确认删除网关',
      message: `确定要删除网关 "${this.gateway?.name || '未命名'}" (${this.gateway?.host || 'unknown'}:${this.gateway?.port || 0}) 吗？`,
      buttons: [
        {
          text: '取消',
          color: '#8E8E93'
        },
        {
          text: '删除',
          color: DT.IOS_RED
        }
      ]
    }).then((result: DialogResult) => {
      if (result.index === 1) {
        if (this.onDelete) {
          this.onDelete();
        }
      }
    }).catch(() => {});
  }

  private getStatusColor(): string {
    if (!this.gateway) return this.isDark ? DT.DARK_TEXT_TERTIARY : DT.LIGHT_TEXT_TERTIARY;
    switch (this.gateway.status) {
      case GatewayStatus.ONLINE:
        return DT.IOS_GREEN;
      case GatewayStatus.OFFLINE:
        return this.isDark ? DT.DARK_TEXT_TERTIARY : DT.LIGHT_TEXT_TERTIARY;
      case GatewayStatus.ERROR:
        return DT.IOS_RED;
      case GatewayStatus.CONNECTING:
        return DT.IOS_ORANGE;
      default:
        return this.isDark ? DT.DARK_TEXT_TERTIARY : DT.LIGHT_TEXT_TERTIARY;
    }
  }

  private getStatusText(): string {
    if (!this.gateway) return '未知';
    switch (this.gateway.status) {
      case GatewayStatus.ONLINE:
        return '在线';
      case GatewayStatus.OFFLINE:
        return '离线';
      case GatewayStatus.ERROR:
        return '错误';
      case GatewayStatus.CONNECTING:
        return '连接中';
      default:
        return '未知';
    }
  }

  build() {
    Column({ space: SP.M }) {
      Row() {
        // Icon
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(48)
            .height(48)
            .fill(DT.IOS_BLUE + '20')

          Text('☁️')
            .fontSize(22)
            .fontColor(DT.IOS_BLUE)
        }
        .width(48)
        .height(48)

        // Info
        Column({ space: SP.XS }) {
          Text(this.gateway?.name || '未命名')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.isDark ? DT.DARK_TEXT_PRIMARY : DT.LIGHT_TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`${this.gateway?.host || 'unknown'}:${this.gateway?.port || 0}`)
            .fontSize(13)
            .fontColor(this.isDark ? DT.DARK_TEXT_SECONDARY : DT.LIGHT_TEXT_SECONDARY)

          Text(`v${this.gateway?.version || '1.0'}`)
            .fontSize(11)
            .fontColor(this.isDark ? DT.DARK_TEXT_TERTIARY : DT.LIGHT_TEXT_TERTIARY)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: SP.M })

        // Status
        Column({ space: SP.XS }) {
          Row({ space: SP.XS }) {
            Circle()
              .width(8)
              .height(8)
              .fill(this.getStatusColor())

            Text(this.getStatusText())
              .fontSize(12)
              .fontColor(this.getStatusColor())
              .fontWeight(FontWeight.Medium)
          }

          Text(this.gateway?.lastSeen ? DateUtils.formatRelativeTime(this.gateway.lastSeen) : '未知')
            .fontSize(11)
            .fontColor(this.isDark ? DT.DARK_TEXT_TERTIARY : DT.LIGHT_TEXT_TERTIARY)
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      // Actions
      Row({ space: SP.M }) {
        if (this.gateway?.status === GatewayStatus.ONLINE) {
          Button(this.isSelected ? '已连接' : '连接', { type: ButtonType.Capsule })
            .layoutWeight(1)
            .height(36)
            .fontSize(13)
            .fontColor(this.isSelected ? '#FFFFFF' : '#FFFFFF')
            .backgroundColor(this.isSelected ? DT.IOS_GREEN : DT.IOS_BLUE)
            .enabled(!this.isSelected)
            .onClick((): void => {
              if (this.onConnect) {
                this.onConnect();
              }
            })
        } else {
          Button('刷新状态', { type: ButtonType.Capsule })
            .layoutWeight(1)
            .height(36)
            .fontSize(13)
            .fontColor('#FFFFFF')
            .backgroundColor(DT.IOS_ORANGE)
            .onClick((): void => {
              if (this.onConnect) {
                this.onConnect();
              }
            })
        }

        Button('删除', { type: ButtonType.Capsule })
          .width(70)
          .height(36)
          .fontSize(13)
          .fontColor(DT.IOS_RED)
          .backgroundColor(DT.IOS_RED + '15')
          .onClick((): void => {
            this.showDeleteConfirm();
          })
      }
      .width('100%')
      .margin({ top: SP.S })
    }
    .width('100%')
    .padding(SP.L)
    .backgroundColor(this.isDark ? '#1C1C1E' : '#FFFFFF')
    .borderRadius(16)
    .border({
      width: this.isSelected ? 2 : 0,
      color: DT.IOS_BLUE
    })
    .shadow(this.isDark ? undefined : {
      radius: 8,
      color: 'rgba(0,0,0,0.06)',
      offsetX: 0,
      offsetY: 2
    })
  }
}
