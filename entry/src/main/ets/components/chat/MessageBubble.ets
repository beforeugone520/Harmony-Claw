import { Message, MessageType } from '../../models/Message';
import { Spacing as SP } from '../../constants';
import { DateUtils } from '../../utils/DateUtils';

@Component
export struct MessageBubble {
  @Prop message: Message;

  private isUserMessage(): boolean {
    return this.message?.sender === 'user';
  }

  private getBubbleColor(): ResourceColor {
    return this.isUserMessage() ? $r('app.color.brand_primary') : $r('app.color.background_tertiary');
  }

  private getTextColor(): ResourceColor {
    return this.isUserMessage() ? $r('app.color.text_inverse') : $r('app.color.text_primary');
  }

  build() {
    Row() {
      if (!this.isUserMessage()) {
        // AI Avatar
        Column() {
          Text('AI')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_inverse'))
        }
        .width(36)
        .height(36)
        .backgroundColor($r('app.color.brand_secondary'))
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
          .fontColor(this.isUserMessage() ? 'rgba(255,255,255,0.7)' : $r('app.color.text_tertiary'))
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
            .fontColor($r('app.color.text_inverse'))
        }
        .width(36)
        .height(36)
        .backgroundColor($r('app.color.brand_primary'))
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
