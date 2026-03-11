import { Message, MessageType } from '../../models/Message';
import { Spacing as SP } from '../../constants';
import { DateUtils } from '../../utils/DateUtils';
import { DesignTokens as DT } from '../../constants/DesignTokens';

@Component
export struct MessageBubble {
  @Prop message: Message;
  @Prop isDark: boolean = false;

  private isUserMessage(): boolean {
    return this.message?.sender === 'user';
  }

  private getBubbleColor(): string {
    if (this.isUserMessage()) {
      return DT.BRAND_PRIMARY;
    }
    return this.isDark ? DT.DARK_BG_TERTIARY : DT.LIGHT_BG_TERTIARY;
  }

  private getTextColor(): string {
    if (this.isUserMessage()) {
      return '#FFFFFF';
    }
    return this.isDark ? DT.DARK_TEXT_PRIMARY : DT.LIGHT_TEXT_PRIMARY;
  }

  private getSecondaryTextColor(): string {
    return this.isDark ? DT.DARK_TEXT_TERTIARY : DT.LIGHT_TEXT_TERTIARY;
  }

  build() {
    Row() {
      if (!this.isUserMessage()) {
        // AI Avatar
        Column() {
          Text('AI')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .width(36)
        .height(36)
        .backgroundColor(DT.BRAND_SECONDARY)
        .borderRadius(18)
        .justifyContent(FlexAlign.Center)
        .margin({ right: SP.S })
      }

      Column({ space: SP.XS }) {
        // Content
        Text(this.message?.content ?? '')
          .fontSize(14)
          .fontColor(this.getTextColor())
          .constraintSize({ maxWidth: '80%' })

        // Time
        Text(this.message?.timestamp ? DateUtils.formatTime(this.message.timestamp) : '')
          .fontSize(10)
          .fontColor(this.isUserMessage() ? 'rgba(255,255,255,0.7)' : this.getSecondaryTextColor())
      }
      .alignItems(this.isUserMessage() ? HorizontalAlign.End : HorizontalAlign.Start)
      .padding(SP.M)
      .backgroundColor(this.getBubbleColor())
      .borderRadius({
        topLeft: this.isUserMessage() ? 16 : 4,
        topRight: this.isUserMessage() ? 4 : 16,
        bottomLeft: 16,
        bottomRight: 16
      })

      if (this.isUserMessage()) {
        // User Avatar
        Column() {
          Text('U')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .width(36)
        .height(36)
        .backgroundColor(DT.BRAND_PRIMARY)
        .borderRadius(18)
        .justifyContent(FlexAlign.Center)
        .margin({ left: SP.S })
      }
    }
    .width('100%')
    .justifyContent(this.isUserMessage() ? FlexAlign.End : FlexAlign.Start)
    .padding({ left: SP.M, right: SP.M })
  }
}
