import { Spacing as SP } from '../../constants';

@Component
export struct ChatInput {
  @State inputText: string = '';
  onSend?: (text: string) => void;

  private canSend(): boolean {
    return this.inputText.trim().length > 0;
  }

  private handleSend(): void {
    if (this.canSend() && this.onSend) {
      this.onSend(this.inputText.trim());
      this.inputText = '';
    }
  }

  build() {
    Row({ space: SP.M }) {
      TextInput({ placeholder: '输入消息...', text: $$this.inputText })
        .placeholderColor($r('app.color.text_tertiary'))
        .fontSize(14)
        .height(44)
        .backgroundColor($r('app.color.background_tertiary'))
        .borderRadius(22)
        .padding({ left: SP.M, right: SP.M })
        .layoutWeight(1)

      Button('发送')
        .width(80)
        .height(44)
        .backgroundColor(this.canSend() ? $r('app.color.brand_primary') : $r('app.color.background_tertiary'))
        .fontColor(this.canSend() ? $r('app.color.text_inverse') : $r('app.color.text_tertiary'))
        .fontSize(14)
        .enabled(this.canSend())
        .onClick(() => this.handleSend())
    }
    .width('100%')
    .height(56)
    .padding({ left: SP.L, right: SP.L })
    .backgroundColor($r('app.color.background_secondary'))
    .border({ width: { top: 1 }, color: $r('app.color.border_light') })
  }
}
