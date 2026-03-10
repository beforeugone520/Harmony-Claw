import { Message, MessageType } from '../../models/Message';
import { Colors, Typography } from '../../styles/DesignTokens';
import { Spacing } from '../../styles/Spacing';
import { DateUtils } from '../../utils/DateUtils';

@Component
export struct MessageBubble {
  @Prop message: Message;

  private isUserMessage(): boolean {
    return this.message?.sender === 'user';
  }

  private getBubbleColor(): ResourceColor {
    return this.isUserMessage() ? Colors.brandPrimary : Colors.backgroundTertiary;
  }

  private getTextColor(): ResourceColor {
    return this.isUserMessage() ? Colors.textInverse : Colors.textPrimary;
  }

  build() {
    Row() {
      if (!this.isUserMessage()) {
        // AI Avatar
        Column() {
          Text('AI')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.textInverse)
        }
        .width(36)
        .height(36)
        .backgroundColor(Colors.brandSecondary)
        .borderRadius(18)
        .justifyContent(FlexAlign.Center)
        .margin({ right: Spacing.sm })
      }

      Column({ space: Spacing.xs }) {
        // Content
        Text(this.message?.content ?? '')
          .fontSize(Typography.sizeBody)
          .fontColor(this.getTextColor())
          .constraintSize({ maxWidth: '80%' })

        // Time
        Text(this.message?.timestamp ? DateUtils.formatTime(this.message.timestamp) : '')
          .fontSize(Typography.sizeOverline)
          .fontColor(this.isUserMessage() ? 'rgba(255,255,255,0.7)' : Colors.textTertiary)
      }
      .alignItems(this.isUserMessage() ? HorizontalAlign.End : HorizontalAlign.Start)
      .padding(Spacing.md)
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
            .fontColor(Colors.textInverse)
        }
        .width(36)
        .height(36)
        .backgroundColor(Colors.brandPrimary)
        .borderRadius(18)
        .justifyContent(FlexAlign.Center)
        .margin({ left: Spacing.sm })
      }
    }
    .width('100%')
    .justifyContent(this.isUserMessage() ? FlexAlign.End : FlexAlign.Start)
    .padding({ left: Spacing.md, right: Spacing.md })
  }
}
